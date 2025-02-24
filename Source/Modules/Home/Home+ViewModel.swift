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
        @Published var error: Repository.NetworkError?
        @Published var icons: Repository.ExchangeIcons?

        @Published var model: Model?

        @Published var selectedCrypto: String = "btc"
        @Published var selectedCurrency: String = "brl"
        @Published var selectedStartDate: Date = Calendar.current.date(byAdding: .day, value: -90, to: .now) ?? .now
        @Published var selectedEndDate: Date = .now

        private let repository: Repository
        
        var cancellables = Set<AnyCancellable>()
        
        init(repository: Repository = .init()) {
            self.repository = repository

            self.model = .init(
                rates: [],
                periods: [],
                currentCrypto: selectedCrypto
            )
        }

        func fetchCurrentRates() {
            fetchExchangeIcon()
            fetchCurrentRate(crypto: selectedCrypto)
            fetchExchangePeriod(
                sourceAsset: selectedCrypto,
                targetAsset: selectedCurrency,
                startDate: selectedStartDate,
                endDate: selectedEndDate
            )
        }

        func fetchCurrentRate(crypto: String) {
            repository.fetchCurrentRate(crypto: crypto) { [weak self] result in
                switch result {
                case .success(let currentRates):
                    self?.model?.rates = currentRates.rates
                case .failure(let error):
                    self?.error = error
                }
            }
        }
        func fetchExchangePeriod(
            sourceAsset: String,
            targetAsset: String,
            startDate: Date,
            endDate: Date
        ) {
            repository.fetchExchangePeriod(
                sourceAsset: sourceAsset,
                targetAsset: targetAsset,
                startedDate: startDate,
                endDate: endDate
            ) { [weak self] result in
                switch result {
                case .success(let periods):
                    self?.model?.periods = periods
                case .failure(let error):
                    self?.error = error
                }
            }
        }

        func fetchExchangeIcon() {
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
    struct Model: Equatable, Hashable {
        var rates: [Home.Repository.CurrentRates.Rate]
        var periods: [Home.Repository.ExchangePeriod]
        let currentCrypto: String
        
        struct RateInfo: Equatable, Hashable {
            let currency: String
            let value: Double
            let time: String
        }
        
        struct PeriodInfo: Equatable, Hashable {
            let openValue: Double
            let closeValue: Double
            let highValue: Double
            let lowValue: Double
            let startTime: String
            let endTime: String
        }
        
        var formattedRates: [RateInfo] {
            rates.map { rate in
                RateInfo(
                    currency: rate.assetIdQuote,
                    value: rate.rate,
                    time: rate.time
                )
            }
        }
        
        var formattedPeriods: [PeriodInfo] {
            periods.map { period in
                PeriodInfo(
                    openValue: period.rateOpen,
                    closeValue: period.rateClose,
                    highValue: period.rateHigh,
                    lowValue: period.rateLow,
                    startTime: period.timePeriodStart,
                    endTime: period.timePeriodEnd
                )
            }
        }
    }
}
