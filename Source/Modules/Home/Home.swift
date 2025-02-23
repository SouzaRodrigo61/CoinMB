//
//  Home.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit

enum Home {
    static func builder() -> UIViewController {
        let viewModel = ViewModel()
        let viewController = ViewController(viewModel: viewModel)

        return viewController
    }
}
