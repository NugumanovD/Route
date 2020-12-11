//
//  PointEntity.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 11.12.2020.
//

import RealmSwift
import CoreLocation

class PointEntity: Object {
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var latitude: Double = 0.0
}

extension PointEntity {
    func convertTo() -> WaypointModel {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return WaypointModel(coordinate: coordinate)
    }
}
