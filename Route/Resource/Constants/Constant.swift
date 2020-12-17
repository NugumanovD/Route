//
//  Constant.swift
//  Route
//
//  Created by Nugumanov Dmitriy on 11.12.2020.
//

import Foundation

struct Constant {
    enum StoryboardName {
        static let routing = "Routing"
    }
    
    enum ViewControllerIdentifier {
        static let routingVC = "RoutingViewController"
    }
    
    enum MapViewStyle {
        static let layerId = "route-style"
        static let sourceId = "route-source"
    }
    
    private init() {}
}

