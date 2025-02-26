//
//  Detail.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit

enum Detail { 

    static func builder(with rate: Home.Repository.CurrentRates.Rate) -> UIViewController {
        let viewModel = ViewModel(rate: rate)
        let viewController = ViewController(model: viewModel)

        return viewController
    }
}
