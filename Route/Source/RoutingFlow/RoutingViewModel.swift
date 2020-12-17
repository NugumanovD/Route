//
//  RoutingViewModel.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 10.12.2020.
//

import Foundation
import Mapbox
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class RoutingViewModel {
    
    //MARK: - Private properties
    
    private var pointsStack: [Waypoint] = [Waypoint]()
    private let routingModel: RoutingModel
    
    //MARK: - Class Properties
    
    var navigationMapViewDelegate: NavigationMapViewDelegate?
    var shouldDisplayRoute: (() -> Void)?
    var shouldRemoveRoute: (() -> Void)?
    
    //MARK: - Init & dealloc methods
    
    init(model: RoutingModel) {
        self.routingModel = model
        navigationMapViewDelegate = NavigationMapViewDelegateImpl()
        setupBindigs()
    }
    
    func loadPointsWithDataBase(userLocation: CLLocationCoordinate2D?) {
        guard let userLocation = userLocation else { return }
        if !routingModel.getAllPoints().isEmpty {
            pointsStack = routingModel.getAllPoints()
            let userLocation = Waypoint(coordinate: userLocation, coordinateAccuracy: -1, name: "Start")
            pointsStack.insert(userLocation, at: 0)
            shouldDisplayRoute?()
        }
    }
    
    func addPointToRoute(withDestination destination: CLLocationCoordinate2D, from origin: CLLocationCoordinate2D) {
        
        if pointsStack.count <= 10 {
            let waypoint = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
            pointsStack.append(waypoint)
            routingModel.addPoint(withItem: waypoint)
            
            if !pointsStack.contains(where: { $0.name == "Start"}) && pointsStack.count == 1 {
                let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
                pointsStack.insert(origin, at: 0)
            }
            shouldDisplayRoute?()
        }
    }
    
    func getPointStack() -> [Waypoint] {
        return pointsStack
    }
    
    func removeAllPoints() {
        routingModel.removeAllPoints()
        pointsStack.removeAll()
    }
}

// MARK: - Private Extension RoutingViewModel

private extension RoutingViewModel {
    func deletePoints() {
        if let lastIndex = pointsStack.lastIndex(where: { $0 == pointsStack.last }) {
            if lastIndex > 1 {
                pointsStack.remove(at: lastIndex)
                shouldDisplayRoute?()
            } else {
                pointsStack.removeAll()
                shouldRemoveRoute?()
            }
            routingModel.deleteLastPoint()
        }
    }
    
    
    func setupBindigs() {
        navigationMapViewDelegate?.updateUserLocation = { [weak self] userLocation in
            self?.loadPointsWithDataBase(userLocation: userLocation)
        }
        
        navigationMapViewDelegate?.didSelectToAnnotation = { [weak self] _, _ in
            self?.deletePoints()
        }
        
        navigationMapViewDelegate?.didChangeLocationAuthorization = { manager in
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("authorizedWhenInUse")
            case .denied:
                print("denied")
            case .notDetermined:
                
                print("ND: - GEO use is NEVER")
            case .restricted:
                print("restricted")
            default:
                break
            }
        }
    }
}
