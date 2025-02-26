//
//  Detail.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit

enum Detail { 

    static func builder() -> UIViewController {
        let viewModel = ViewModel()
        let viewController = ViewController(model: viewModel)

        return viewController
    }
}
