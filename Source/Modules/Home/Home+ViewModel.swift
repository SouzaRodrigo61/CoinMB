//
//  HomeController.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import UIKit
import Combine

extension Home {
    class ViewModel: Identifiable {
        @Published var currentRates: CurrentRates?
        @Published var icons: ExchangeIcons?
        @Published var error: NetworkError?

        private let repository: Repository
        
        var cancellables = Set<AnyCancellable>()
        
        init(repository: Repository = .init()) {
            self.repository = repository
        }

        func fetchCurrentRates(with crypto: String) {
            repository.fetchCurrentRate(crypto: crypto) { [weak self] result in
                switch result {
                case .success(let currentRates):
                    self?.currentRates = currentRates
                case .failure(let error):
                    self?.error = error
                }
            }
            
            repository.fetchExchangeIcon(with: 44) { [weak self] result in
                switch result {
                case .success(let icons):
                    self?.icons = icons
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}

extension Home.ViewModel { 
    enum NetworkError: Error {
        case decode(msg: String, error: String)
        case network(Manager.Network.NetworkError)
    }

    struct CurrentRates: Codable {
        let assetIdBase: String
        let rates: [Rate]
        
        struct Rate: Codable {
            let time: String
            let assetIdQuote: String
            let rate: Double
            
            enum CodingKeys: String, CodingKey {
                case time
                case assetIdQuote = "asset_id_quote"
                case rate
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case assetIdBase = "asset_id_base"
            case rates
        }
    }
    
    typealias ExchangeIcons = [ExchangeIcon]
    
    struct ExchangeIcon: Codable {
        let exchangeId: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case exchangeId = "exchange_id"
            case url
        }
    }
}
