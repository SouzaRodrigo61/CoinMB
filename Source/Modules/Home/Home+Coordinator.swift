//
//  Home.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit

extension Coordinating where A == UINavigationController {

    static func coordinatorHome() -> Self {
        return Self { navigationController in
            let viewController = Home.builder()
            navigationController.pushViewController(viewController, animated: false)
        }
    }

    static var home: Self {
        coordinatorHome()
    }
}
