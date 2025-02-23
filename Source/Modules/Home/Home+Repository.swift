//
//  Home+Repository.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/25.
//

import Foundation

extension Home { 
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

        func fetchCurrentRate(crypto: String, completion: @escaping ResponseCurrentRates) {
            maketRateNetwork.get("/v1/exchangerate/\(crypto)", nil) { result in
                switch result {
                case .success(let data):
                    do {
                        let products: CurrentRates = try JSONDecoder().decode(
                            CurrentRates.self,
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
        
        func fetchAllExchange(completion: @escaping ResponseExchanges) {             
            maketRateNetwork.get("/v1/exchanges", nil) { result in
                switch result {
                case .success(let data):
                    do {
                        let exchanges: Exchanges = try JSONDecoder().decode(
                            Exchanges.self,
                            from: data
                        )
                        completion(.success(exchanges))
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
        
        func fetchExchangeIcon(with size: Int, completion: @escaping ResponseExchangeIcons) { 
            maketRateNetwork.get("/v1/exchanges/icons/\(size)", nil) { result in
                switch result {
                case .success(let data):
                    do {
                        let icons: ExchangeIcons = try JSONDecoder().decode(
                            ExchangeIcons.self,
                            from: data
                        )
                        completion(.success(icons))
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
        
        func fetchExchangePeriod(
            sourceAsset: String = "btc",
            targetAsset: String = "usd",
            startedDate: Date = Calendar.current.date(byAdding: .day, value: -10000, to: .now) ?? .now,
            endDate: Date = .now,
            completion: @escaping ResponseExchangePeriods
        ) {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate]
            
            let startDateString = dateFormatter.string(from: startedDate)
            let endDateString = dateFormatter.string(from: endDate)
            
            let endpoint = "/v1/exchangerate/\(sourceAsset)/\(targetAsset)/history"
            
            let parameters = [
                "period_id": "1day",
                "time_start": startDateString,
                "time_end": endDateString
            ]
            
            maketRateNetwork.get(endpoint, parameters) { result in
                switch result {
                case .success(let data):
                    do {
                        let icons: ExchangePeriods = try JSONDecoder().decode(
                            ExchangePeriods.self,
                            from: data
                        )
                        completion(.success(icons))
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

extension Home.Repository { 
    enum NetworkError: Error {
        case decode(msg: String, error: String)
        case network(Manager.Network.NetworkError)
    }
    struct CurrentRates: Codable, Equatable, Hashable {
        let assetIdBase: String
        let rates: [Rate]
        
        struct Rate: Codable, Equatable, Hashable {
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
    struct ExchangeIcon: Codable, Equatable, Hashable {
        let exchangeId: String
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case exchangeId = "exchange_id"
            case url
        }
    }
    
    typealias Exchanges = [Exchange]
    struct Exchange: Codable, Equatable, Hashable { 
        let exchangeId: String
        let website: String
        let name: String
        let dataQuoteStart: String
        let dataQuoteEnd: String
        let dataOrderbookStart: String
        let dataOrderbookEnd: String
        let dataTradeStart: String
        let dataTradeEnd: String
        let dataSymbolsCount: Int
        let volume1HrsUsd: Double
        let volume1DayUsd: Double
        let volume1MthUsd: Double
        let rank: Int
        
        enum CodingKeys: String, CodingKey {
            case exchangeId = "exchange_id"
            case website
            case name
            case dataQuoteStart = "data_quote_start"
            case dataQuoteEnd = "data_quote_end"
            case dataOrderbookStart = "data_orderbook_start"
            case dataOrderbookEnd = "data_orderbook_end"
            case dataTradeStart = "data_trade_start"
            case dataTradeEnd = "data_trade_end"
            case dataSymbolsCount = "data_symbols_count"
            case volume1HrsUsd = "volume_1hrs_usd"
            case volume1DayUsd = "volume_1day_usd"
            case volume1MthUsd = "volume_1mth_usd"
            case rank
        }
    }
    
    typealias ExchangePeriods = [ExchangePeriod]
    struct ExchangePeriod: Codable, Equatable, Hashable { 
        let timePeriodStart: String
        let timePeriodEnd: String
        let timeOpen: String
        let timeClose: String
        let rateOpen: Double
        let rateHigh: Double
        let rateLow: Double
        let rateClose: Double
        
        enum CodingKeys: String, CodingKey {
            case timePeriodStart = "time_period_start"
            case timePeriodEnd = "time_period_end"
            case timeOpen = "time_open"
            case timeClose = "time_close"
            case rateOpen = "rate_open"
            case rateHigh = "rate_high"
            case rateLow = "rate_low"
            case rateClose = "rate_close"
        }
    }
}

extension Home.Repository { 
    
    typealias ResultCurrentRates = Result<CurrentRates, NetworkError>
    typealias ResponseCurrentRates = (ResultCurrentRates) -> Void
    
    typealias ResultExchangeIcons = Result<ExchangeIcons, NetworkError>
    typealias ResponseExchangeIcons = (ResultExchangeIcons) -> Void
    
    typealias ResultExchanges = Result<Exchanges, NetworkError>
    typealias ResponseExchanges = (ResultExchanges) -> Void
    
    typealias ResultExchangePeriods = Result<ExchangePeriods, NetworkError>
    typealias ResponseExchangePeriods = (ResultExchangePeriods) -> Void
}
