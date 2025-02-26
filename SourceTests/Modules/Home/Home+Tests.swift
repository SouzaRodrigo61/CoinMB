//
//  Home+Tests.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 21/02/2025.
//

import XCTest
import Combine
@testable import CoinMB


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
