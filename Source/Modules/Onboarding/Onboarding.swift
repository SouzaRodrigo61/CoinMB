//
//  Onboarding.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 20/02/2025.
//

import UIKit

enum Onboarding {

    static func builder() -> UIViewController {
        let viewModel = ViewModel()
        let viewController = ViewController(model: viewModel)

        return viewController
    }
}
