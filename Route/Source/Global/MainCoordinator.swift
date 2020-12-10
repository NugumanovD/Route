//
//  MainCoordinator.swift
//  Route
//
//  Created by Nuguamnov Dmitriy on 10.12.2020.
//

import UIKit

protocol Coordinator {
    func start()
}

class MainCoordinator: Coordinator {
    
    var window: UIWindow?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showRoutingFlow()
    }
    
    private func showRoutingFlow() {
        let routingViewController = RoutingViewController.makeMemeDetailVC(viewModel: RoutingViewModel())
        
        self.window?.rootViewController = routingViewController
        self.window?.makeKeyAndVisible()
    }
}
