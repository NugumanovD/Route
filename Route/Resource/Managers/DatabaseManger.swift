//
//  DatabaseManger.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 10.12.2020.
//

import Foundation
import RealmSwift
import CoreLocation
import MapboxDirections

protocol LocalStorable {
    func getAllPoints() -> [WaypointModel]
    func addPoint(withItem item: Waypoint)
    func deleteLastPoint()
    func removeAllPoints()
}

class DatabaseManger: LocalStorable {
    
    var realm: Realm!
    init() {
        do {
            try self.realm = Realm()
        } catch {
            self.realm = nil
        }
    }
    
    func getAllPoints() -> [WaypointModel] {
        return realm.objects(PointEntity.self).map({ $0.convertTo() })
    }
    
    func addPoint(withItem item: Waypoint) {
        let pointEntity = PointEntity()
        pointEntity.latitude = item.coordinate.latitude
        pointEntity.longitude = item.coordinate.longitude
        
        try? self.realm.write {
            self.realm.add(pointEntity)
        }
    }
    
    func deleteLastPoint() {
        try? self.realm.write {
            guard let lastObject = realm.objects(PointEntity.self).last else { return }
            self.realm.delete(lastObject)
        }
    }
    
    func removeAllPoints() {
        let allObjects = realm.objects(PointEntity.self)
        try? self.realm.write {
            self.realm.delete(allObjects)
        }
    }
}

