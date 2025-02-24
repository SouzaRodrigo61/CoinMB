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
        
        private lazy var amountLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 32, weight: .bold)
            label.textColor = .label
            label.textAlignment = .center
            return label
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
            containerView.addSubview(amountLabel)
            containerView.addSubview(chartView)
            containerView.addSubview(blurEffectView)
            containerView.addSubview(timeFilterView)
        }

        private func setupChartView() {
            chartView.onPointSelected = { [weak self] index, value in
                dump(value, name: "Point Selected -> index: \(index)")
                // self?.handlePointSelected(index: index, value: value)
            }

            chartView.onDragBegan = { [weak self] in
                UIView.animate(withDuration: 0.3, animations: {
                    self?.timeFilterView.alpha = 0
                    self?.timeFilterView.transform = CGAffineTransform(translationX: 0, y: 44)
                }) { _ in
                    self?.timeFilterView.isHidden = true
                }
            }

            chartView.onDragEnded = { [weak self] in
                self?.timeFilterView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self?.timeFilterView.alpha = 1
                    self?.timeFilterView.transform = .identity
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
            
            amountLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(32)
                make.leading.trailing.equalToSuperview().inset(0)
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
        }
        
        // MARK: - Configuration
        
        func configure(model: [Home.Repository.ExchangePeriod]) {
            guard let dayOperation = model.last else { return }
            
            dump(dayOperation, name: "DayOperation - Configure")
            
            amountLabel.text = "R$ \(String(format: "%.2f", dayOperation.rateClose))"
            chartView.dataPoints = model.map { CGFloat($0.rateClose) }
        }
    } 
}
