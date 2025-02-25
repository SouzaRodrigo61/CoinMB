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
            view.addSubview(closeButton)
            view.addSubview(cryptoContainer)
            view.addSubview(rangeContainer)
            view.addSubview(searchButton)
            
            cryptoContainer.addSubview(cryptoLabel)
            rangeContainer.addSubview(rangeLabel)
            
            setupConstraints()
        }
        
        private func setupConstraints() {
            blurView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            closeButton.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
                make.leading.equalToSuperview().offset(16)
                make.size.equalTo(32)
            }
            
            cryptoContainer.snp.makeConstraints { make in
                make.top.equalTo(closeButton.snp.bottom).offset(24)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(56)
            }
            
            cryptoLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
            }
            
            rangeContainer.snp.makeConstraints { make in
                make.top.equalTo(cryptoContainer.snp.bottom).offset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(56)
            }
            
            rangeLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
            }
            
            searchButton.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
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
            // Captura o frame atual do cryptoContainer
            let currentFrame = cryptoContainer.frame
            
            // Atualiza o frame do sourceButton caso ele tenha se movido
            let updatedSourceFrame = sourceButton?.convert(sourceButton?.bounds ?? .zero, to: nil) ?? sourceButtonFrame
            
            // Remove todas as constraints exceto do cryptoContainer
            rangeContainer.snp.removeConstraints()
            searchButton.snp.removeConstraints()
            closeButton.snp.removeConstraints()
            
            // Configura o frame atual manualmente
            cryptoContainer.frame = currentFrame
            
            // Anima para a posição final
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                // Remove as constraints do cryptoContainer durante a animação
                self.cryptoContainer.snp.removeConstraints()
                self.cryptoContainer.frame = updatedSourceFrame
                self.cryptoContainer.layer.cornerRadius = self.sourceButton?.layer.cornerRadius ?? 16
                
                // Fade out dos outros elementos
                self.blurView.alpha = 0
                self.rangeContainer.alpha = 0
                self.searchButton.alpha = 0
                self.closeButton.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        }
        
        func animateAppearance() {
            // Guarda o frame inicial
            let initialFrame = sourceButtonFrame
            
            // Configura estado inicial
            cryptoContainer.frame = initialFrame
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                self.blurView.alpha = 1
                self.rangeContainer.alpha = 1
                self.searchButton.alpha = 1
                self.closeButton.alpha = 1
                
                // Anima para a posição final usando constraints
                self.setupConstraints()
                self.view.layoutIfNeeded()
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
