//
//  NavigationMapDelegate.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 10.12.2020.
//

import Mapbox
import MapboxCoreNavigation

protocol NavigationMapViewDelegate: class, MGLMapViewDelegate {
    var didSelectToAnnotation: ((_ mapView: MGLMapView, _ annotation: MGLAnnotation) -> Void)? { get set }
    var didChangeLocationAuthorization: ((_ manager: MGLLocationManager) -> Void)? { get set }
    var updateUserLocation: ((CLLocationCoordinate2D?) -> Void)? { get set }
}

class NavigationMapViewDelegateImpl: NSObject, NavigationMapViewDelegate {
    
    private var userLocation: CLLocationCoordinate2D?
    
    var didSelectToAnnotation: ((_ mapView: MGLMapView, _ annotation: MGLAnnotation) -> Void)?
    var didChangeLocationAuthorization: ((_ manager: MGLLocationManager) -> Void)?
    var updateUserLocation: ((CLLocationCoordinate2D?) -> Void)?
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        didSelectToAnnotation?(mapView, annotation)
    }
    
    func mapView(_ mapView: MGLMapView, didChangeLocationManagerAuthorization manager: MGLLocationManager) {
        manager.requestAlwaysAuthorization()
        manager.setDesiredAccuracy?(kCLLocationAccuracyBest)
        mapView.showsUserLocation = true
        didChangeLocationAuthorization?(manager)
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        if self.userLocation == nil {
            self.userLocation = userLocation?.coordinate
            updateUserLocation?(self.userLocation)
        }
        
        print("ND: - USERLOCATION WAS UPDATE")
    }
}
