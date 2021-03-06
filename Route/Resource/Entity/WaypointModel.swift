//
//  WaypointModel.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 11.12.2020.
//

import CoreLocation
import MapboxDirections

struct WaypointModel {
    var coordinate: CLLocationCoordinate2D
}

extension WaypointModel {
    func convertTo() -> Waypoint {
        return Waypoint(coordinate: coordinate)
    }
}
