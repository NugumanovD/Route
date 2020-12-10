//
//  ViewController.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 10.12.2020.
//

import UIKit
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class RoutingViewController: UIViewController {

    @IBOutlet weak var navigationMapView: NavigationMapView!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var navigateBottomConstraint: NSLayoutConstraint!
    
    private var routeOptions: NavigationRouteOptions?
    private var route: Route?
    
    private var routingViewModel: RoutingViewModel?
    private var navigationMapViewDelegate: NavigationMapViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapViewDelegate = routingViewModel?.navigationMapViewDelegate
        configureNagiteButton()
        configureNavigationMapView()
        setupBindings()
    }
    
    static func makeMemeDetailVC(viewModel: RoutingViewModel) -> UIViewController {
        guard let routingViewController = UIStoryboard(name: "Routing", bundle: nil).instantiateViewController(withIdentifier: "RoutingViewController") as? RoutingViewController else { return UIViewController() }
        routingViewController.routingViewModel = viewModel
        return routingViewController
    }
    
    private func configureNavigationMapView() {
        navigationMapView.delegate = navigationMapViewDelegate
        
        navigationMapView.showsUserLocation = true
        navigationMapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_ :)))
        navigationMapView.addGestureRecognizer(longPress)
    }
    
    private func configureNagiteButton() {
        navigateButton.layer.cornerRadius = 10
        navigateButton.setTitle("Проложить маршрут", for: .normal)
        navigateBottomConstraint.constant = -(navigateButton.frame.height * 2)
    }
    
    private func removeRoute() {
        guard let style = self.navigationMapView.style?.layer(withIdentifier: "route-style") else { return }
        self.navigationMapView.style?.removeLayer(style)
        self.navigationMapView.style?.sources.removeAll()
        self.navigationMapView.removeWaypoints()
        
    }
    
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: navigationMapView)
        let coordinate = navigationMapView.convert(point, toCoordinateFrom: navigationMapView)
        
        if let origin = navigationMapView.userLocation?.coordinate {
            routingViewModel?.addPointToRoute(withDestination: coordinate)
            routingViewModel?.calculateRoute(from: origin)
//            displayRoute()
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }
    
    private func setupBindings() {
        routingViewModel?.shouldDisplayRoute = { [weak self] in
            self?.displayRoute()
        }
        
        routingViewModel?.shouldRemoveRoute = { [weak self] in
            self?.removeRoute()
        }
    }

    private func displayRoute() {
        guard let pointStack = routingViewModel?.getPointStack() else { return }
        let routeOptions = NavigationRouteOptions(waypoints: pointStack)
        routeOptions.profileIdentifier = .walking
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }
                
                strongSelf.route = route
                strongSelf.routeOptions = routeOptions
                strongSelf.drawRoute(route: route)
                strongSelf.navigationMapView.showWaypoints(on: route)
                
                if let annotation = strongSelf.navigationMapView.annotations?.first as? MGLPointAnnotation {
                    annotation.title = "Delete Point"
                    strongSelf.navigationMapView.selectAnnotation(annotation, animated: true, completionHandler: nil)
                }
            }
        }
    }
    
    func drawRoute(route: Route) {
        guard let routeShape = route.shape, routeShape.coordinates.count > 0 else { return }
        var routeCoordinates = routeShape.coordinates
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
        
        if let source = navigationMapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            navigationMapView.style?.addSource(source)
            navigationMapView.style?.addLayer(lineStyle)
        }
    }
    
    @IBAction func didTapNavigate(_ sender: UIButton) {
        navigateBottomConstraint.constant = -(navigateButton.frame.height * 2)
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }
}
