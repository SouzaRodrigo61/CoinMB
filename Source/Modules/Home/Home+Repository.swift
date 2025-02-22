//
//  Home+Repository.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/25.
//

import Foundation

extension Home { 
    typealias CurrentRates = Result<ViewModel.CurrentRates, ViewModel.NetworkError>
    typealias ResultCurrentRates = (CurrentRates) -> Void
    
    typealias ExchangeIcon = Result<ViewModel.ExchangeIcons, ViewModel.NetworkError>
    typealias ResultExchangeIcon = (ExchangeIcon) -> Void
    
    struct Repository { 
        let maketRateNetwork: Manager.Network
        let exchangeNetwork: Manager.Network

        init(
            maketRateNetwork: Manager.Network = .marketRateLive, 
            exchangeNetwork: Manager.Network = .exchangeRateLive
        ) {
            self.maketRateNetwork = maketRateNetwork
            self.exchangeNetwork = exchangeNetwork
        }

        func fetchCurrentRate(crypto: String, completion: @escaping ResultCurrentRates) {
            maketRateNetwork.get("/v1/exchangerate/\(crypto)") { result in
                switch result {
                case .success(let data):
                    do {
                        let products: ViewModel.CurrentRates = try JSONDecoder().decode(
                            ViewModel.CurrentRates.self,
                            from: data
                        )
                        completion(.success(products))
                    } catch let error {
                        completion(
                            .failure(
                                .decode(
                                    msg: "Failure for decoding data",
                                    error: error.localizedDescription
                                )
                            )
                        )
                    }
                case .failure(let error):
                    completion(.failure(.network(error)))
                }
            }
        }
        
        func fetchExchangeIcon(with size: Int, completion: @escaping ResultExchangeIcon) { 
            maketRateNetwork.get("/v1/exchanges/icons/\(size)") { result in
                switch result {
                case .success(let data):
                    do {
                        let products: ViewModel.ExchangeIcons = try JSONDecoder().decode(
                            ViewModel.ExchangeIcons.self,
                            from: data
                        )
                        completion(.success(products))
                    } catch let error {
                        completion(
                            .failure(
                                .decode(
                                    msg: "Failure for decoding data",
                                    error: error.localizedDescription
                                )
                            )
                        )
                    }
                case .failure(let error):
                    completion(.failure(.network(error)))
                }
            }
        }
    }
}
