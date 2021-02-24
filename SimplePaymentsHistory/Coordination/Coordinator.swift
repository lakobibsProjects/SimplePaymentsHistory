//
//  Coordinator.swift
//  GitInfo
//
//  Created by user166683 on 8/19/20.
//  Copyright © 2020 Lakobib. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
