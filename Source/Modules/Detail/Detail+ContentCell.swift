//
//  Detail+ContentCell.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 26/02/2025.
//

import UIKit
import SnapKit

extension Detail {
    final class ContentCell: UITableViewCell {
        
        // MARK: - Properties
        
        static let identifier = String(describing: ContentCell.self)
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = .label
            label.numberOfLines = 0
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
            return label
        }()
        
        private let priceLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 18, weight: .bold)
            label.textColor = .label
            return label
        }()
        
        private let changePercentLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .medium)
            return label
        }()
        
        private let volumeLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .secondaryLabel
            return label
        }()
        
        private let infoStackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 12
            stack.distribution = .fillEqually
            return stack
        }()
        
        private let stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 4
            stack.alignment = .leading
            return stack
        }()
        
        // MARK: - Initializers
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Methods
        
        private func setupViews() {
            contentView.addSubview(stackView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(subtitleLabel)
            
            infoStackView.addArrangedSubview(priceLabel)
            infoStackView.addArrangedSubview(changePercentLabel)
            infoStackView.addArrangedSubview(volumeLabel)
            stackView.addArrangedSubview(infoStackView)
            
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(16)
            }
        }
        
        func configure(with model: Home.Repository.CurrentRates.Rate) {
            titleLabel.text = model.assetIdQuote
            
            // Formatação da data
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            dateFormatter.locale = Locale(identifier: "pt_BR")
            subtitleLabel.text = dateFormatter.string(from: model.time)
            
            // Formatação da moeda
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = Locale(identifier: "en")
            priceLabel.text = numberFormatter.string(from: NSNumber(value: model.rate))
        }
        
        private func formatVolume(_ volume: Double) -> String {
            switch volume {
            case 1_000_000...:
                return String(format: "%.2fM", volume / 1_000_000)
            case 1_000...:
                return String(format: "%.2fK", volume / 1_000)
            default:
                return String(format: "%.2f", volume)
            }
        }
    }
}
