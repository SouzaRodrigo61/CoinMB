//
//  Home+ContentCell.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 23/02/25.
//

import UIKit
import SnapKit

extension Home { 
    class ContentCell: UICollectionViewCell { 
        static let reuseIdentifier = "Home.ContentCell"
        
        // MARK: - UI Components
        private lazy var containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 12
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private lazy var iconImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 15 // Para um tamanho de 30x30
            return imageView
        }()
        
        private lazy var assetLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private lazy var rateLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 14, weight: .regular)
            label.textColor = .secondaryLabel
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        // MARK: - Init
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        
        private func setupView() {
            contentView.addSubview(containerView)
            containerView.addSubview(iconImageView)
            containerView.addSubview(assetLabel)
            containerView.addSubview(rateLabel)
            
            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(8)
            }
            
            iconImageView.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(12)
                make.centerY.equalToSuperview()
                make.size.equalTo(30)
            }
            
            assetLabel.snp.makeConstraints { make in
                make.top.trailing.equalToSuperview().inset(12)
                make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            }
            
            rateLabel.snp.makeConstraints { make in
                make.top.equalTo(assetLabel.snp.bottom).offset(4)
                make.leading.equalTo(iconImageView.snp.trailing).offset(12)
                make.trailing.bottom.equalToSuperview().inset(12)
            }
        }
        
        // MARK: - Configuration
        
        private var currentImageURL: String?
        
        func configure(with model: Home.Repository.CurrentRates.Rate, iconUrl: String? = nil) {
            assetLabel.text = model.assetIdQuote
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            
            if let formattedRate = formatter.string(from: NSNumber(value: model.rate)) {
                rateLabel.text = formattedRate
            } else {
                rateLabel.text = String(format: "%.2f", model.rate)
            }

            // Limpa a imagem atual antes de carregar a nova
            iconImageView.image = nil
            
            if let iconUrl = iconUrl {
                loadImage(from: iconUrl)
            }
        }
        
        private func loadImage(from urlString: String) {
            // Guarda a URL atual
            self.currentImageURL = urlString
            
            ImageCache.shared.loadImage(from: urlString) { [weak self] image in
                DispatchQueue.main.async {
                    // Só atualiza a imagem se esta célula ainda estiver esperando por esta URL específica
                    if self?.currentImageURL == urlString, 
                       let image = image {
                        self?.iconImageView.image = image
                    }
                }
            }
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            currentImageURL = nil
            iconImageView.image = nil
        }
    }
}
