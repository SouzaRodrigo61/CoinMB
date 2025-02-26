//
//  Home+RepositoryMock.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import Foundation

// Mock do Repository
extension Home.Repository {

    static let mockSuccess = Self(
        maketRateNetwork: Manager.Network.mockSuccess,
        exchangeNetwork: Manager.Network.mockSuccess
    )
    
    static let mockFailure = Self(
        maketRateNetwork: Manager.Network.mockFailure,
        exchangeNetwork: Manager.Network.mockFailure
    )
}

// Mock do Network Manager
extension Manager.Network {
    static let mockSuccess = Self(
        get: { endpoint, _, completion in
            if endpoint == "/v1/exchangerate/btc" {
                completion(.success(mockCurrentRateData))
            } else if endpoint.hasPrefix("/v1/exchangerate/") && endpoint.contains("/history") {
                completion(.success(mockExchangePeriodData))
            } else if endpoint.hasPrefix("/v1/assets/icons/") {
                completion(.success(mockIconsData))
            }
        },
        post: { _, _, _ in },
        put: { _, _, _ in },
        delete: { _, _ in }
    )
    
    static let mockFailure = Self(
        get: { _, _, completion in
            completion(.failure(.invalidResponse))
        },
        post: { _, _, _ in },
        put: { _, _, _ in },
        delete: { _, _ in }
    )
    
    private static var mockCurrentRateData: Data {
        let data = """
        {
            "asset_id_base": "btc",
            "rates": [
                {
                    "asset_id_quote": "USD",
                    "rate": 3258.88,
                    "time": "2024-02-21T00:00:00.000Z"
                },
                {
                    "asset_id_quote": "EUR",
                    "rate": 2782.52,
                    "time": "2024-02-21T00:00:00.000Z"
                },
                {
                    "asset_id_quote": "CNY",
                    "rate": 21756.29,
                    "time": "2024-02-21T00:00:00.000Z"
                },
                {
                    "asset_id_quote": "GBP",
                    "rate": 2509.60,
                    "time": "2024-02-21T00:00:00.000Z"
                }
            ]
        }
        """
        return Data(data.utf8)
    }
    
    private static var mockExchangePeriodData: Data {
        let data = """
        [
            {
                "time_period_start": "2024-12-23T00:00:00.0000000Z",
                "time_period_end": "2025-01-02T00:00:00.0000000Z",
                "time_open": "2025-01-01T00:00:02.8000000Z",
                "time_close": "2025-01-01T23:59:59.3000000Z",
                "rate_open": 582277.1036697753,
                "rate_high": 592635.3658540217,
                "rate_low": 576593.9920982684,
                "rate_close": 588440.152401636
            },
            {
                "time_period_start": "2025-01-02T00:00:00.0000000Z",
                "time_period_end": "2025-01-12T00:00:00.0000000Z",
                "time_open": "2025-01-02T00:00:01.3000000Z",
                "time_close": "2025-01-11T23:59:57.6000000Z",
                "rate_open": 588421.7815971613,
                "rate_high": 640877.5772333927,
                "rate_low": 552695.6626844619,
                "rate_close": 581550.4374415462
            },
            {
                "time_period_start": "2025-01-12T00:00:00.0000000Z",
                "time_period_end": "2025-01-22T00:00:00.0000000Z",
                "time_open": "2025-01-12T00:00:28.3000000Z",
                "time_close": "2025-01-21T23:59:59.7000000Z",
                "rate_open": 581537.4072236775,
                "rate_high": 672393.8177099396,
                "rate_low": 534430.7411088842,
                "rate_close": 640731.1034273928
            },
            {
                "time_period_start": "2025-01-22T00:00:00.0000000Z",
                "time_period_end": "2025-02-01T00:00:00.0000000Z",
                "time_open": "2025-01-22T00:00:00.0000000Z",
                "time_close": "2025-01-31T23:59:59.9000000Z",
                "rate_open": 640731.1348329989,
                "rate_high": 648553.8258221563,
                "rate_low": 565929.7753392654,
                "rate_close": 598148.4087830748
            }
        ]
        """
        return Data(data.utf8)
    }
    
    private static var mockIconsData: Data {
        let data = """
        [
            {
                "asset_id": "BTC",
                "url": "https://s3.eu-central-1.amazonaws.com/bbxt-static-icons/type-id/png_16/f231d7382689406f9a50dde841418c64.png"
            },
            {
                "asset_id": "ETH",
                "url": "https://s3.eu-central-1.amazonaws.com/bbxt-static-icons/type-id/png_16/04836ff3bc4d4d95820e0155594dca86.png"
            },
            {
                "asset_id": "USD",
                "url": "https://s3.eu-central-1.amazonaws.com/bbxt-static-icons/type-id/png_16/4873707f25fe4de3b4bca6fa5c631011.png"
            }
        ]
        """
        return Data(data.utf8)
    }
}
