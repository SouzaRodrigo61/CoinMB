//
//  HomeHeaderCell.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 23/02/2025.
//

import UIKit
import SnapKit

extension Home { 
    class HeaderCell: UICollectionReusableView {        
        static let reuseIdentifier = "Home.HeaderCell"
        
        // MARK: - UI Components
        
        private lazy var containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            return view
        }()
        
        private lazy var cryptoNameLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            return label
        }()
        
        private lazy var amountLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 32, weight: .bold)
            label.textColor = .label
            label.textAlignment = .center
            return label
        }()
        
        private lazy var trendImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .label
            return imageView
        }()
        
        private lazy var chartView: LineChartView = {
            let view = LineChartView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let blurEffectView: UIVisualEffectView = {
            let blur = UIBlurEffect(style: .prominent)
            let view = UIVisualEffectView(effect: blur)
            view.alpha = 0
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        private let bottomGradientLayer: CAGradientLayer = {
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            return gradient
        }()
        
        private lazy var timeFilterView: TimeFilterView = {
            let view = TimeFilterView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private var originalAmount: Double = 0
        private var chartData: [Home.Repository.ExchangePeriod] = []
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
            setupConstraints()
            setupChartView()
            setupTimeFilterView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        
        private func setupView() {
            addSubview(containerView)
            containerView.addSubview(cryptoNameLabel)
            containerView.addSubview(amountLabel)
            containerView.addSubview(chartView)
            containerView.addSubview(blurEffectView)
            containerView.addSubview(timeFilterView)
            containerView.addSubview(trendImageView)
        }

        private func setupChartView() {
            chartView.onPointSelected = { [weak self] index, value in
                guard let self = self,
                      index < self.chartData.count else { return }
                let period = self.chartData[index]
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                
                if let date = dateFormatter.date(from: period.timeClose) {
                    self.updateAmount(value: Double(value), date: date)
                }
            }

            chartView.onDragBegan = { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3, animations: {
                    self.timeFilterView.alpha = 0
                    self.timeFilterView.transform = CGAffineTransform(translationX: 0, y: 44)
                }) { _ in
                    self.timeFilterView.isHidden = true
                }
            }

            chartView.onDragEnded = { [weak self] in
                guard let self = self else { return }
                self.timeFilterView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.timeFilterView.alpha = 1
                    self.timeFilterView.transform = .identity
                    self.resetAmountDisplay()
                }
            }
        }

        private func setupTimeFilterView() {
            timeFilterView.onFilterSelected = { [weak self] filter in
                // Aqui você pode adicionar a lógica para filtrar os dados do gráfico
                switch filter {
                case .oneDay:
                    dump("Filtrar por 1 dia")
                case .oneWeek:
                    dump("Filtrar por 1 semana")
                case .oneMonth:
                    dump("Filtrar por 1 mês")
                case .sixMonths:
                    dump("Filtrar por 6 meses")
                case .oneYear:
                    dump("Filtrar por 1 ano")
                case .fiveYears:
                    dump("Filtrar por 5 anos")
                }
            }
        }
        
        private func setupConstraints() {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            cryptoNameLabel.snp.makeConstraints { make in
                make.bottom.equalTo(amountLabel.snp.top).offset(-4)
                make.leading.trailing.equalToSuperview().inset(16)
            }
            
            amountLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(52)
                make.centerX.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview().inset(16)
            }
            
            chartView.snp.makeConstraints { make in
                make.top.equalTo(amountLabel.snp.bottom).offset(0)
                make.leading.trailing.equalToSuperview().inset(0)
                make.height.equalTo(200)
                make.bottom.equalToSuperview().inset(16)
            }
            
            timeFilterView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalToSuperview().inset(8)
                make.height.equalTo(44)
            }
            
            blurEffectView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            trendImageView.snp.makeConstraints { make in
                make.centerY.equalTo(amountLabel)
                make.leading.equalTo(amountLabel.snp.trailing).offset(8)
                make.width.height.equalTo(24)
            }
        }
        
        override func layoutSubviews() {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            super.layoutSubviews()
            let gradientHeight = bounds.height * 0.4
            bottomGradientLayer.frame = CGRect(
                x: 0,
                y: bounds.height - gradientHeight, width: bounds.width, height: gradientHeight
            )
            CATransaction.commit()
        }

        func updateBlur(alpha: CGFloat) {
            blurEffectView.alpha = alpha
            timeFilterView.alpha = 1 - alpha
        }
        
        // MARK: - Configuration
        func configure(model: [Home.Repository.ExchangePeriod], cryptoName: String = "Bitcoin") {
            guard let dayOperation = model.last else { return }
            originalAmount = dayOperation.rateClose
            chartData = model
            cryptoNameLabel.text = cryptoName
            amountLabel.text = "USD \(String(format: "%.2f", originalAmount))"
            chartView.dataPoints = model.map { CGFloat($0.rateClose) }
        }

        private func updateAmount(value: Double, date: Date? = nil) {
            let isHigher = value > originalAmount
            let isEqual = value == originalAmount
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.currencySymbol = "USD"
            numberFormatter.minimumFractionDigits = 2
            
            let formattedValue = numberFormatter.string(from: NSNumber(value: value)) ?? "USD 0.00"
            
            if let date = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
                let dateString = dateFormatter.string(from: date)
                
                amountLabel.text = formattedValue
                cryptoNameLabel.text = dateString
                
                // Animar a transição
                UIView.animate(withDuration: 0.2) {
                    self.amountLabel.alpha = 0
                    self.cryptoNameLabel.alpha = 0
                    self.amountLabel.text = formattedValue
                    self.cryptoNameLabel.text = dateString
                }
            } else {
                // Restaurar labels originais
                UIView.animate(withDuration: 0.2) {
                    self.amountLabel.alpha = 1
                    self.cryptoNameLabel.alpha = 1
                    self.amountLabel.text = formattedValue
                    self.cryptoNameLabel.text = "Bitcoin"
                }
                amountLabel.text = formattedValue
            }
            
            let color = isEqual ? UIColor.label : (isHigher ? .systemGreen : .systemRed)
            amountLabel.textColor = color
            cryptoNameLabel.textColor = color
            
            let imageName = isEqual ? "" : (isHigher ? "chevron.up" : "chevron.down")
            trendImageView.image = imageName.isEmpty ? nil : UIImage(systemName: imageName)
            trendImageView.tintColor = color
        }

        private func resetAmountDisplay() {
            updateAmount(value: originalAmount)
        }
    } 
}
