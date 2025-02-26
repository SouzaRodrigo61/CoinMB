//
//  Detail.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit

extension Coordinating where A == UINavigationController {

    static func coordinatorDetail() -> Self {
        return Self { navigationController in
            let viewController = Detail.builder()
            navigationController.pushViewController(viewController, animated: false)
        }
    }

    static var detail: Self {
        coordinatorDetail()
    }
}
