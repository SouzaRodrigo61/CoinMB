//
//  DetailController.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit
import Combine

extension Detail {
    class ViewModel: Identifiable { 
        @Published var rate: Home.Repository.CurrentRates.Rate
        var cancellables = Set<AnyCancellable>()
        
        init(rate: Home.Repository.CurrentRates.Rate) {
            self.rate = rate
        }
    }
}
