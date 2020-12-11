//
//  RoutingModel.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 10.12.2020.
//

import Foundation
import MapboxDirections

class RoutingModel {
    
    private let localStorage: LocalStorable
    
    //MARK: - Init & dealloc methods
    
    init(localStorage: LocalStorable) {
        self.localStorage = localStorage
    }
    
    //MARK: - Class functions
    
    func getAllPoints() -> [Waypoint] {
        let waypoints = localStorage.getAllPoints().map({ $0.convertTo() })
        return waypoints
    }
    
    func addPoint(withItem item: Waypoint) {
        localStorage.addPoint(withItem: item)
    }
    
    func deleteLastPoint() {
        localStorage.deleteLastPoint()
    }
    
    func removeAllPoints() {
        localStorage.removeAllPoints()
    }
}
