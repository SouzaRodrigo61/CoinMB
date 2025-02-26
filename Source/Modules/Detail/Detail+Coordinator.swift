//
//  Detail.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit

extension Coordinating where A == UINavigationController {

    static func coordinatorDetail(with rate: Home.Repository.CurrentRates.Rate) -> Self {
        return Self { navigationController in
            let viewController = Detail.builder(with: rate)
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
