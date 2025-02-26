//
//  Home+Tests.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import XCTest
import Combine
@testable import CoinMB

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
            if endpoint.contains("exchangerate") {
                completion(.success(mockCurrentRateData))
            } else if endpoint.contains("period") {
                completion(.success(mockExchangePeriodData))
            } else if endpoint.contains("icons") {
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
                "time_period_start": "2016-01-01T00:00:00.0000000Z",
                "time_period_end": "2016-01-01T00:01:00.0000000Z",
                "time_open": "2016-01-01T00:00:00.0000000Z",
                "time_close": "2016-01-01T00:00:00.0000000Z",
                "rate_open": 430.586617904731,
                "rate_high": 430.586617904731,
                "rate_low": 430.586617904731,
                "rate_close": 430.586617904731
            },
            {
                "time_period_start": "2016-01-01T00:01:00.0000000Z",
                "time_period_end": "2016-01-01T00:02:00.0000000Z",
                "time_open": "2016-01-01T00:01:00.0000000Z",
                "time_close": "2016-01-01T00:01:00.0000000Z",
                "rate_open": 430.38999999999993,
                "rate_high": 430.38999999999993,
                "rate_low": 430.38999999999993,
                "rate_close": 430.38999999999993
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

final class HomeTests: XCTestCase {
    func testFetchCurrentRates_Success() {
        // Given
        let sut = Home.ViewModel(repository: .mockSuccess)
        let ratesExpectation = XCTestExpectation(description: "Fetch rates")
        let iconsExpectation = XCTestExpectation(description: "Fetch icons")
        var cancellables = Set<AnyCancellable>()
        
        // When
        sut.$model
            .dropFirst()
            .sink { model in
                guard let model = model else { return }
                
                // Verificando rates
                if !model.rates.isEmpty {
                    XCTAssertEqual(model.rates.first?.rate, 3258.88)
                    XCTAssertEqual(model.rates.count, 4)
                    ratesExpectation.fulfill()
                }
                
                // Verificando icons
                if !model.icons.isEmpty {
                    XCTAssertEqual(model.icons.count, 3)
                    iconsExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        sut.fetchCurrentRates()
        
        // Aguardando ambas as expectativas
        wait(for: [ratesExpectation, iconsExpectation], timeout: 2)
    }
    
    func testFetchCurrentRates_Failure() {
        // Given
        let sut = Home.ViewModel(repository: .mockFailure)
        let expectation = XCTestExpectation(description: "Fetch current rates failure")
        var cancellables = Set<AnyCancellable>()
        
        sut.$currentRateError
            .dropFirst()
            .sink { error in
                XCTAssertNotNil(error)
                XCTAssertEqual(error, .network(.invalidResponse))
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        sut.fetchCurrentRates()
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testUpdateTimeFilter() {

        let sut = Home.ViewModel(repository: .mockSuccess)
        
        sut.updateTimeFilter(.oneWeek)
        
        XCTAssertEqual(sut.selectedEndDate.timeIntervalSinceReferenceDate,
                       Date.now.timeIntervalSinceReferenceDate, accuracy: 1)
        
        let calendar = Calendar.current
        let expectedStartDate = calendar.date(byAdding: .day, value: -7, to: .now)!
        XCTAssertEqual(sut.selectedStartDate.timeIntervalSinceReferenceDate, 
                      expectedStartDate.timeIntervalSinceReferenceDate, 
                      accuracy: 1)
    }
}
