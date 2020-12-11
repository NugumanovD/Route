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
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var navigationMapView: NavigationMapView!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var deleteRouteButton: UIButton!
    @IBOutlet weak var navigateRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteRouteRightConstraint: NSLayoutConstraint!
    
    //MARK: - Private properties
    
    private var routeOptions: NavigationRouteOptions?
    private var route: Route?
    private var routingViewModel: RoutingViewModel?
    private var navigationMapViewDelegate: NavigationMapViewDelegate?
    
    //MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapViewDelegate = routingViewModel?.navigationMapViewDelegate
        configureNagiteButton()
        configureNavigationMapView()
        setupBindings()
    }
    
    static func makeRoutingViewController(viewModel: RoutingViewModel) -> UIViewController {
        guard let routingViewController = UIStoryboard(name: Constant.StoryboardName.routing, bundle: nil)
                .instantiateViewController(withIdentifier: Constant.ViewControllerIdentifier.routingVC) as? RoutingViewController else {
            return UIViewController()
        }
        routingViewController.routingViewModel = viewModel
        return routingViewController
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            showAlert(withMessage: "Что хотите удалить весь маршрут?") {
                self.routingViewModel?.removeAllPoints()
                self.removeRoute()
            }
        default:
            break
        }
    }
    
    //MARK: - IBAction funcs
    
    @IBAction func didTapDeleteRoute(_ sender: UIButton) {
        showAlert(withMessage: "Что хотите удалить весь маршрут?\n\n Если потрясти устройство так же можно удалить маршрут") {
            self.routingViewModel?.removeAllPoints()
            self.removeRoute()
        }
    }
    
    @IBAction func didTapNavigate(_ sender: UIButton) {
        guard let route = route, let routeOptions = routeOptions else {
            return
        }
        let navigationViewController = NavigationViewController(for: route, routeIndex: 1, routeOptions: routeOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }
}

// MARK: - Private Extension RoutingViewController
private extension RoutingViewController {
    
    func configureNavigationMapView() {
        navigationMapView.delegate = navigationMapViewDelegate
        navigationMapView.showsUserLocation = true
        navigationMapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_ :)))
        navigationMapView.addGestureRecognizer(longPress)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.routingViewModel?.loadPointsWithDataBase(userLocation: self.navigationMapView?.userLocation?.coordinate)
        }
    }
    
    func configureNagiteButton() {
        deleteRouteButton.layer.cornerRadius = deleteRouteButton.frame.width / 2
        navigateButton.layer.cornerRadius = navigateButton.frame.width / 2
        navigateRightConstraint.constant = -(navigateButton.frame.width)
        deleteRouteRightConstraint.constant = -(deleteRouteButton.frame.width)
    }
    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: navigationMapView)
        let coordinate = navigationMapView.convert(point, toCoordinateFrom: navigationMapView)
        
        if let origin = navigationMapView.userLocation?.coordinate {
            routingViewModel?.addPointToRoute(withDestination: coordinate, from: origin)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }
    
    func setupBindings() {
        routingViewModel?.shouldDisplayRoute = { [weak self] in
            self?.displayRoute()
        }
        
        routingViewModel?.shouldRemoveRoute = { [weak self] in
            self?.removeRoute()
        }
    }
    
    func displayRoute() {
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
                strongSelf.showNavigateButton()
                strongSelf.showDeleteRouteButton()
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
    
    func removeRoute() {
        guard let style = self.navigationMapView.style?.layer(withIdentifier: Constant.MapViewStyle.layerId) else { return }
        self.navigationMapView.style?.removeLayer(style)
        self.navigationMapView.style?.sources.removeAll()
        self.navigationMapView.removeWaypoints()
        self.hideNavigateButton()
        self.hideDeleteRouteButton()
    }
    
    func showNavigateButton() {
        navigateRightConstraint.constant = navigateButton.frame.width / 2
        UIView.animate(withDuration: 0.33,
                       delay: 0.2,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showDeleteRouteButton() {
        deleteRouteRightConstraint.constant = deleteRouteButton.frame.width / 2
        UIView.animate(withDuration: 0.33,
                       delay: 0.3,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideNavigateButton() {
        navigateRightConstraint.constant = -(navigateButton.frame.width)
        UIView.animate(withDuration: 0.33) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideDeleteRouteButton() {
        deleteRouteRightConstraint.constant = -(deleteRouteButton.frame.width)
        UIView.animate(withDuration: 0.33, delay: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func drawRoute(route: Route) {
        guard let routeShape = route.shape, routeShape.coordinates.count > 0 else { return }
        var routeCoordinates = routeShape.coordinates
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: UInt(routeCoordinates.count))
        
        if let source = navigationMapView.style?.source(withIdentifier: Constant.MapViewStyle.sourceId) as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: Constant.MapViewStyle.sourceId, features: [polyline], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: Constant.MapViewStyle.layerId, source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            navigationMapView.style?.addSource(source)
            navigationMapView.style?.addLayer(lineStyle)
        }
    }
    
    func showAlert(withMessage message: String, complation: @escaping () -> Void) {
        let alert = UIAlertController(title: "Вы уверены", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            complation()
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
}
