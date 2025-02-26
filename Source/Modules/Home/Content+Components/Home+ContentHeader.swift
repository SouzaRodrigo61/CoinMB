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
        
        // MARK: - Properties
        private let searchButtonId = "searchButton"
        
        private lazy var searchButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .secondarySystemBackground
            button.layer.cornerRadius = 24
            button.layer.shadowColor = UIColor.tertiarySystemBackground.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            
            let searchImage = UIImage(systemName: "magnifyingglass")
            let searchLabel = "Iniciar busca"
            
            let attributedString = NSMutableAttributedString()
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = searchImage?.withTintColor(.label)
            attributedString.append(NSAttributedString(attachment: imageAttachment))
            attributedString.append(NSAttributedString(string: "  \(searchLabel)"))
            
            button.setAttributedTitle(attributedString, for: .normal)
            button.setTitleColor(.label, for: .normal)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            
            button.accessibilityIdentifier = searchButtonId
            return button
        }()
        
        private lazy var filterButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .secondarySystemBackground
            button.layer.cornerRadius = 24
            button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
            button.tintColor = .label
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.1
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowRadius = 4
            return button
        }()
        
        // MARK: - Callbacks
        var onSearchTapped: (() -> Void)?
        var onFilterTapped: (() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            backgroundColor = .systemBackground
            
            addSubview(searchButton)
            addSubview(filterButton)
            
            setupConstraints()
            setupActions()
        }
        
        private func setupConstraints() {
            searchButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.height.equalTo(48)
            }
            
            filterButton.snp.makeConstraints { make in
                make.leading.equalTo(searchButton.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.height.equalTo(48)
                make.width.equalTo(48)
            }
        }
        
        private func setupAction() { 
            
        }
        
        private func setupActions() {
            searchButton.addTarget(self, action: #selector(handleSearchTap), for: .touchUpInside)
            filterButton.addTarget(self, action: #selector(handleFilterTap), for: .touchUpInside)
        }
        
        @objc private func handleSearchTap() {
            guard let parentViewController = self.findViewController() else { return }
            
            let searchOverlay = SearchOverlayViewController()
            searchOverlay.modalPresentationStyle = .overFullScreen
            searchOverlay.sourceButton = searchButton
            searchOverlay.sourceButtonFrame = searchButton.convert(searchButton.bounds, to: nil)
            
            parentViewController.present(searchOverlay, animated: false) {
                searchOverlay.animateAppearance()
            }
        }
        
        @objc private func handleFilterTap() {
            onFilterTapped?()
        }
        
        func configure(title: String, subtitle: String) {
            //            titleLabel.text = title
            //            subtitleLabel.text = subtitle
            //            subtitleLabel.isHidden = subtitle.isEmpty
        }
    }
}

// Adicione esta extensão helper para encontrar o viewController
private extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
