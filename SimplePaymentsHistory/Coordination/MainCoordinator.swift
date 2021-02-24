
//
//  MainCoordinator.swift
//  GitInfo
//
//  Created by user166683 on 8/19/20.
//  Copyright © 2020 Lakobib. All rights reserved.
//

import Foundation

import UIKit

class MainCoordinator: NSObject, Coordinator, UINavigationControllerDelegate {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        navigationController.delegate = self
        let vc = AuthView()
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: false)
    }
    
    func paymentHistory(token: String){
        navigationController.delegate = self
        let vc = PaymentHistoryView()
        vc.coordinator = self
        vc.token = token
        
        navigationController.pushViewController(vc, animated: false)
    }
}
