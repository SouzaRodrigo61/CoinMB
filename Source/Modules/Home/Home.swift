//
//  Home.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit

enum Home {
    static func builder() -> UIViewController {
        var viewModel = ViewModel()

        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            viewModel = ViewModel(repository: .mockSuccess)
        }
        
        let viewController = ViewController(viewModel: viewModel)

        return viewController
    }
}
