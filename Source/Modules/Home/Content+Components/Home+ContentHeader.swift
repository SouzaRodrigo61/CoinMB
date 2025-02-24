//
//  Home+ContentHeader.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/25.
//

import UIKit
import SnapKit

extension Home { 
    final class ContentHeader: UICollectionReusableView { 
        static let reuseIdentifier = "Home.ContentHeader"
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .bold)
            label.textColor = .label
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 12, weight: .regular)
            label.textColor = .secondaryLabel
            return label
        }()
        
        private let actionButton: UIButton = {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            button.tintColor = .label
            return button
        }()
        
        private let separatorView: UIView = {
            let view = UIView()
            view.backgroundColor = .separator
            return view
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .systemBackground
            
            addSubview(titleLabel)
            addSubview(subtitleLabel)
            addSubview(actionButton)
            addSubview(separatorView)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.leading.equalToSuperview().offset(16)
                make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
            }
            
            subtitleLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.leading.equalTo(titleLabel)
                make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
                make.bottom.equalToSuperview().inset(16)
            }
            
            actionButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().inset(16)
            }
        }
        
        func configure(title: String, subtitle: String) {
            titleLabel.text = title
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = subtitle.isEmpty
        }
    }
}
