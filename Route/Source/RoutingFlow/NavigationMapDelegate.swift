//
//  NavigationMapDelegate.swift
//  Route
//
//  Created by Rush LLC on 10.12.2020.
//

import Mapbox
import MapboxCoreNavigation

protocol NavigationMapViewDelegate: class, MGLMapViewDelegate {
    var didSelectToAnnotation: ((_ mapView: MGLMapView, _ annotation: MGLAnnotation) -> Void)? { get set }
}

class NavigationMapViewDelegateImpl: NSObject, NavigationMapViewDelegate {
    
    var didSelectToAnnotation: ((_ mapView: MGLMapView, _ annotation: MGLAnnotation) -> Void)?
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        didSelectToAnnotation?(mapView, annotation)
    }
}
