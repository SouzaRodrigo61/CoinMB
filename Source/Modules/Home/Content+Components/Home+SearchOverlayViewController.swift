//
//  SearchOverlayViewController.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 25/02/25.
//

import UIKit
import SnapKit

extension Home { 
    class SearchOverlayViewController: UIViewController {
        // Propriedades para hero animation
        var sourceButton: UIButton?
        var sourceButtonFrame: CGRect = .zero
        
        private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
        private let matchGeometryNamespace = "SearchOverlay"
        
        private lazy var blurView: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            let view = UIVisualEffectView(effect: blurEffect)
            view.alpha = 0
            return view
        }()
        
        private lazy var overlayContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 16
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            view.alpha = 0
            return view
        }()
        
        private lazy var closeButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            button.tintColor = .gray
            button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
            return button
        }()
        
        private lazy var cryptoContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 16
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            return view
        }()
        
        private lazy var rangeContainer: UIView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 16
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.1
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            return view
        }()
        
        private lazy var cryptoLabel: UILabel = {
            let label = UILabel()
            label.text = "Qual criptomoeda?"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            return label
        }()
        
        private lazy var rangeLabel: UILabel = {
            let label = UILabel()
            label.text = "Faixa de valor"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            return label
        }()
        
        private lazy var searchButton: UIButton = {
            let button = UIButton()
            button.backgroundColor = .systemBlue
            button.setTitle("Buscar", for: .normal)
            button.layer.cornerRadius = 24
            button.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)
            return button
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupViews()
            setupGestures()
            setupInitialState()
        }
        
        private func setupViews() {
            view.backgroundColor = .clear
            
            view.addSubview(blurView)
            view.addSubview(overlayContainer)
            
            overlayContainer.addSubview(closeButton)
            overlayContainer.addSubview(cryptoContainer)
            overlayContainer.addSubview(rangeContainer)
            overlayContainer.addSubview(searchButton)
            
            cryptoContainer.addSubview(cryptoLabel)
            rangeContainer.addSubview(rangeLabel)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            blurView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            overlayContainer.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(16)
            }
            
            closeButton.snp.makeConstraints { make in
                make.top.equalTo(overlayContainer).offset(16)
                make.leading.equalTo(overlayContainer).offset(16)
                make.size.equalTo(32)
            }
            
            cryptoContainer.snp.makeConstraints { make in
                make.top.equalTo(closeButton.snp.bottom).offset(24)
                make.leading.trailing.equalTo(overlayContainer).inset(16)
                make.height.equalTo(56)
            }
            
            cryptoLabel.snp.makeConstraints { make in
                make.leading.equalTo(cryptoContainer).offset(16)
                make.centerY.equalTo(cryptoContainer)
            }
            
            rangeContainer.snp.makeConstraints { make in
                make.top.equalTo(cryptoContainer.snp.bottom).offset(16)
                make.leading.trailing.equalTo(overlayContainer).inset(16)
                make.height.equalTo(56)
            }
            
            rangeLabel.snp.makeConstraints { make in
                make.leading.equalTo(rangeContainer).offset(16)
                make.centerY.equalTo(rangeContainer)
            }
            
            searchButton.snp.makeConstraints { make in
                make.leading.trailing.equalTo(overlayContainer).inset(16)
                make.bottom.equalTo(overlayContainer).offset(-16)
                make.height.equalTo(48)
            }
        }
        
        private func setupGestures() {
            let cryptoTap = UITapGestureRecognizer(target: self, action: #selector(handleCryptoTap))
            cryptoContainer.addGestureRecognizer(cryptoTap)
            
            let rangeTap = UITapGestureRecognizer(target: self, action: #selector(handleRangeTap))
            rangeContainer.addGestureRecognizer(rangeTap)
        }
        
        private func setupInitialState() {
            // Configura o estado inicial do cryptoContainer para match com o botão de origem
            cryptoContainer.frame = sourceButtonFrame
            cryptoContainer.layer.cornerRadius = sourceButton?.layer.cornerRadius ?? 16
            
            // Configura alpha inicial dos outros elementos
            blurView.alpha = 0
            rangeContainer.alpha = 0
            searchButton.alpha = 0
            closeButton.alpha = 0
        }
        
        @objc private func handleCryptoTap() {
            animateContainer(cryptoContainer, isExpanding: true)
        }
        
        @objc private func handleRangeTap() {
            animateContainer(rangeContainer, isExpanding: true)
        }
        
        private func animateContainer(_ container: UIView, isExpanding: Bool) {
            UIView.animate(withDuration: 0.3) {
                container.snp.updateConstraints { make in
                    make.height.equalTo(isExpanding ? 300 : 56)
                }
                self.view.layoutIfNeeded()
            }
        }
        
        @objc private func handleClose() {
            dismissWithAnimation()
        }
        
        @objc private func handleSearch() {
            // Implementar lógica de busca
            dismissWithAnimation()
        }
        
        private func dismissWithAnimation() {
            UIView.animate(withDuration: 0.2, animations: {
                self.blurView.alpha = 0
                self.overlayContainer.alpha = 0
                self.overlayContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.dismiss(animated: false)
            }
        }
        
        func animateAppearance() {
            blurView.alpha = 0
            overlayContainer.alpha = 0
            overlayContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.blurView.alpha = 1
                self.overlayContainer.alpha = 1
                self.overlayContainer.transform = .identity
            }
        }
    }
}

extension Home.SearchOverlayViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissWithAnimation()
    }
}
