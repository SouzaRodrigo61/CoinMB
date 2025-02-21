//
//  Onboarding.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 20/02/2025.
//

import UIKit

extension Coordinating where A == UINavigationController {

    static func coordinatorOnboarding() -> Self {
        return Self { navigationController in
            let viewController = Onboarding.builder()
            navigationController.pushViewController(viewController, animated: false)
        }
    }
}
