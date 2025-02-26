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
        @Published var currentRateError: Repository.NetworkError?
        @Published var exchangePeriodError: Repository.NetworkError?
        @Published var exchangeIconError: Repository.NetworkError?

        @Published var model: Model?

        @Published var selectedCrypto: String = "btc"
        @Published var selectedCurrency: String = "brl"
        @Published var selectedStartDate: Date = Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now
        @Published var selectedEndDate: Date = .now

        private let repository: Repository
        
        var cancellables = Set<AnyCancellable>()
        
        init(repository: Repository = .init()) {
            self.repository = repository

            self.model = .init(
                rates: [],
                periods: [],
                icons: [],
                currentCrypto: selectedCrypto
            )
        }

        func fetchCurrentRates() {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self else { return }
                fetchCurrentRate(crypto: selectedCrypto)
                fetchExchangeIcon()
                fetchExchangePeriod(
                    sourceAsset: selectedCrypto,
                    targetAsset: selectedCurrency,
                    startDate: selectedStartDate,
                    endDate: selectedEndDate
                )
            }
        }

        func fetchCurrentRate(crypto: String) {
            repository.fetchCurrentRate(crypto: crypto) { [weak self] result in
                switch result {
                case .success(let currentRates):
                    self?.model?.rates = currentRates.rates
                case .failure(let error):
                    self?.currentRateError = error
                }
            }
        }
        func fetchExchangePeriod(
            sourceAsset: String,
            targetAsset: String,
            startDate: Date,
            endDate: Date,
            periodId: String = "4HRS"
        ) {
            repository.fetchExchangePeriod(
                sourceAsset: sourceAsset,
                targetAsset: targetAsset,
                startedDate: startDate,
                endDate: endDate,
                periodId: periodId
            ) { [weak self] result in
                switch result {
                case .success(let periods):
                    self?.model?.periods = periods
                case .failure(let error):
                    self?.exchangePeriodError = error
                }
            }
        }

        func fetchExchangeIcon() {
            repository.fetchExchangeIcon(with: 44) { [weak self] result in
                switch result {
                case .success(let icons):
                    self?.model?.icons = icons
                case .failure(let error):
                    self?.exchangeIconError = error
                }
            }
        }

        func updateTimeFilter(_ filter: Home.TimeFilterView.TimeFilter) {
            let calendar = Calendar.current
            
            let startDate: Date
            var periodId = "1DAY"
            
            switch filter {
            case .oneDay:
                startDate = calendar.date(byAdding: .day, value: -3, to: .now) ?? .now
                periodId = "1HRS"
            case .oneWeek:
                startDate = calendar.date(byAdding: .day, value: -7, to: .now) ?? .now
                periodId = "4HRS"
            case .oneMonth:
                startDate = calendar.date(byAdding: .month, value: -1, to: .now) ?? .now
            case .sixMonths:
                startDate = calendar.date(byAdding: .month, value: -6, to: .now) ?? .now
                periodId = "10DAY"
            case .oneYear:
                startDate = calendar.date(byAdding: .year, value: -1, to: .now) ?? .now
                periodId = "10DAY"
            case .fiveYears:
                startDate = calendar.date(byAdding: .year, value: -5, to: .now) ?? .now
                periodId = "10DAY"
            }
            
            selectedStartDate = startDate
            selectedEndDate = .now
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self else { return }
                fetchExchangePeriod(
                    sourceAsset: selectedCrypto,
                    targetAsset: selectedCurrency,
                    startDate: startDate,
                    endDate: .now,
                    periodId: periodId
                )
            }
        }
        
        private func formatDateForDisplay(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            return formatter.string(from: date)
        }
        
        private func filterPeriods(periods: [Repository.ExchangePeriod], startDate: Date, endDate: Date) -> [Repository.ExchangePeriod] {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            
            return periods.filter { period in
                guard let periodStart = formatter.date(from: period.timePeriodStart),
                      let periodEnd = formatter.date(from: period.timePeriodEnd) else {
                    return false
                }
                
                return periodStart >= startDate && periodEnd <= endDate
            }
        }
    }
}

extension Home.ViewModel { 
    struct Model: Equatable, Hashable {
        var rates: [Home.Repository.CurrentRates.Rate]
        var periods: Home.Repository.ExchangePeriods
        var icons: Home.Repository.ExchangeIcons
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
