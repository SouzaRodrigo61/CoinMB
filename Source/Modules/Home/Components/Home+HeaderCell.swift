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
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
            setupConstraints()
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
                make.height.equalTo(100)
                make.bottom.equalToSuperview().inset(0)
            }
            
            blurEffectView.snp.makeConstraints { make in
                make.top.trailing.leading.bottom.equalToSuperview()
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
