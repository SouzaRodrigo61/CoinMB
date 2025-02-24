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
        
        // MARK: - Properties
        var onTimeFilterSelected: ((Home.TimeFilterView.TimeFilter) -> Void)?
        
        // MARK: - UI Components
        
        private lazy var containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            return view
        }()
        
        private lazy var containerCryptoView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 16
            view.clipsToBounds = true
            
            // Sombra suave
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 6
            view.layer.shadowOpacity = 0.1
            
            return view
        }()
        
        private lazy var cryptoNameLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            return label
        }()
        
        private lazy var amountLabel: Home.RollingCounterLabel = {
            let label = Home.RollingCounterLabel()
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
            containerView.addSubview(containerCryptoView)
            
            containerCryptoView.addSubview(cryptoNameLabel)
            containerCryptoView.addSubview(amountLabel)
            containerCryptoView.addSubview(trendImageView)
            
            containerView.addSubview(chartView)
            containerView.addSubview(blurEffectView)
            containerView.addSubview(timeFilterView)
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
                // Agora podemos chamar o callback corretamente
                self?.onTimeFilterSelected?(filter)
            }
        }
        
        private func setupConstraints() {
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            containerCryptoView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaLayoutGuide).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalToSuperview()
            }
            
            cryptoNameLabel.snp.makeConstraints { make in
                make.top.equalTo(containerCryptoView).offset(12)
                make.leading.trailing.equalTo(containerCryptoView).inset(16)
            }
            
            amountLabel.snp.makeConstraints { make in
                make.top.equalTo(cryptoNameLabel.snp.bottom).offset(4)
                make.centerX.equalTo(containerCryptoView)
            }
            
            trendImageView.snp.makeConstraints { make in
                make.centerY.equalTo(amountLabel)
                make.leading.equalTo(amountLabel.snp.trailing).offset(8)
                make.width.height.equalTo(20) // Ícone um pouco menor
            }
            
            chartView.snp.makeConstraints { make in
                make.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(180)
            }
            
            timeFilterView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(safeAreaLayoutGuide).inset(8) // Respeitar safe area
                make.height.equalTo(44)
            }
            
            blurEffectView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
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
            amountLabel.setValue(originalAmount, animated: false)
            chartView.dataPoints = model.map { CGFloat($0.rateClose) }
        }

        private func updateAmount(value: Double, date: Date? = nil) {
            let isHigher = value > originalAmount
            let isEqual = value == originalAmount
            
            if let date = date {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM yyyy"
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                
                let dateString = dateFormatter.string(from: date)
                let timeString = timeFormatter.string(from: date)
                
                UIView.animate(withDuration: 0.3, 
                              delay: 0,
                              options: .curveEaseInOut) {
                    self.cryptoNameLabel.transform = CGAffineTransform(translationX: 0, y: -5)
                    self.cryptoNameLabel.text = "\(dateString) às \(timeString)"
                    self.cryptoNameLabel.alpha = 0.8
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.cryptoNameLabel.transform = .identity
                    }
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.cryptoNameLabel.transform = .identity
                    self.cryptoNameLabel.alpha = 1
                    self.cryptoNameLabel.text = "Bitcoin"
                }
            }
            
            let color = isEqual ? UIColor.label : (isHigher ? .systemGreen : .systemRed)
            amountLabel.textColor = color
            amountLabel.setValue(value, animated: true)
            cryptoNameLabel.textColor = color.withAlphaComponent(0.8)
            
            let imageName = isEqual ? "" : (isHigher ? "chevron.up" : "chevron.down")
            trendImageView.image = imageName.isEmpty ? nil : UIImage(systemName: imageName)
            trendImageView.tintColor = color
        }

        private func resetAmountDisplay() {
            updateAmount(value: originalAmount)
        }
    } 
}
