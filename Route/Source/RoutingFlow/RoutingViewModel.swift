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
    
    private var pointsStack: [Waypoint] = [Waypoint]()
    
    var navigationMapViewDelegate: NavigationMapViewDelegate?
    var shouldDisplayRoute: (() -> Void)?
    var shouldRemoveRoute: (() -> Void)?
    
    init() {
        navigationMapViewDelegate = NavigationMapViewDelegateImpl()
        deletePoint()
    }
    
    func addPointToRoute(withDestination destination: CLLocationCoordinate2D) {
        if pointsStack.count <= 10 {
            pointsStack.append(Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish"))
        } else {
            // TODO: - показать алерт
        }
        print(pointsStack.count)
    }
    
    func calculateRoute(from origin: CLLocationCoordinate2D) {
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        if pointsStack.count == 1 {
            pointsStack.insert(origin, at: 0)
        }
        shouldDisplayRoute?()
    }
    
    func getPointStack() -> [Waypoint] {
        return pointsStack
    }
    
    func deletePoint() {
        navigationMapViewDelegate?.didSelectToAnnotation = { [weak self] _, _ in
            if let lastIndex = self?.pointsStack.lastIndex(where: { $0 == self?.pointsStack.last }) {
                if lastIndex > 1 {
                    self?.pointsStack.remove(at: lastIndex)
                    self?.shouldDisplayRoute?()
                } else {
                    self?.pointsStack.removeAll()
                    self?.shouldRemoveRoute?()
                }
            }
        }
    }
}
