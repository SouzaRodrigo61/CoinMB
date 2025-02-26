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
        
        // Propriedades para controle do drag
        private var initialTouchPoint: CGPoint = .zero
        private var initialOverlayTransform: CGAffineTransform = .identity
        
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
            view.backgroundColor = .clear
            view.layer.cornerRadius = 16
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            view.alpha = 0
            return view
        }()
        
        private lazy var closeButton: UIButton = {
            let button = UIButton()
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            button.tintColor = .gray
            button.alpha = 0
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
        
        private lazy var cryptoTextField: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Selecione uma criptomoeda"
            tf.font = .systemFont(ofSize: 16, weight: .medium)
            tf.textColor = .label
            tf.isUserInteractionEnabled = false // Impede edição direta
            tf.text = "Bitcoin" // Valor pré-selecionado
            
            // Ícone de seta
            let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
            arrowImageView.tintColor = .secondaryLabel
            tf.rightView = arrowImageView
            tf.rightViewMode = .always
            
            return tf
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
            button.alpha = 0
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
            
            cryptoContainer.addSubview(cryptoTextField)
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
                make.top.equalTo(view.safeAreaLayoutGuide)
                make.trailing.equalTo(overlayContainer).offset(-16)
                make.size.equalTo(32)
            }
            
            cryptoContainer.snp.makeConstraints { make in
                make.top.equalTo(closeButton.snp.bottom).offset(24)
                make.leading.trailing.equalTo(overlayContainer).inset(16)
                make.height.equalTo(56)
            }
            
            cryptoTextField.snp.makeConstraints { make in
                make.leading.trailing.equalTo(cryptoContainer).inset(16)
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
            
            // Adiciona o pan gesture para drag
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            overlayContainer.addGestureRecognizer(panGesture)
            
            // Adiciona tap no blur para dismiss
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBlurTap))
            blurView.addGestureRecognizer(tapGesture)
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
        
        @objc private func handleBlurTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: view)
            if !overlayContainer.frame.contains(location) {
                dismissWithAnimation()
            }
        }
        
        @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            let touchPoint = gesture.location(in: view)
            
            switch gesture.state {
            case .began:
                initialTouchPoint = touchPoint
                initialOverlayTransform = overlayContainer.transform
                
            case .changed:
                let xOffset = touchPoint.x - initialTouchPoint.x
                let yOffset = touchPoint.y - initialTouchPoint.y
                
                // Calcula o progresso baseado no maior offset (x ou y)
                let progress = min(1, max(abs(xOffset), abs(yOffset)) / 200)
                
                // Aplica transformação e escala
                let scale = 1.0 - (progress * 0.2)
                let translation = CGAffineTransform(translationX: xOffset, y: yOffset)
                let scaling = CGAffineTransform(scaleX: scale, y: scale)
                
                // Adiciona uma leve rotação baseada na direção do drag
                let angle = (xOffset / 500) * (.pi / 8) // máximo de 22.5 graus
                let rotation = CGAffineTransform(rotationAngle: angle)
                
                // Combina todas as transformações
                overlayContainer.transform = translation
                    .concatenating(scaling)
                    .concatenating(rotation)
                
                // Ajusta opacidades
                blurView.alpha = 1 - progress
                closeButton.alpha = 1 - progress
                searchButton.alpha = 1 - progress
                
            case .ended, .cancelled:
                let velocity = gesture.velocity(in: view)
                let xOffset = touchPoint.x - initialTouchPoint.x
                let yOffset = touchPoint.y - initialTouchPoint.y
                
                // Verifica se deve dismissar baseado na velocidade ou distância
                let shouldDismiss = abs(velocity.x) > 500 || abs(velocity.y) > 500 ||
                                  abs(xOffset) > 200 || abs(yOffset) > 200
                
                if shouldDismiss {
                    // Determina a direção do dismiss
                    let isHorizontal = abs(velocity.x) > abs(velocity.y)
                    let dismissVelocity = CGPoint(
                        x: isHorizontal ? velocity.x : 0,
                        y: isHorizontal ? 0 : velocity.y
                    )
                    dismissWithAnimation(velocity: dismissVelocity)
                } else {
                    // Retorna à posição original com animação spring
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                        self.overlayContainer.transform = .identity
                        self.blurView.alpha = 1
                        self.closeButton.alpha = 1
                        self.searchButton.alpha = 1
                    }
                }
                
            default:
                break
            }
        }
        
        private func dismissWithAnimation(velocity: CGPoint? = nil) {
            let duration = velocity != nil ? 0.2 : 0.3
            
            // Primeiro, fade out dos botões
            UIView.animate(withDuration: duration * 0.5) {
                self.closeButton.alpha = 0
                self.searchButton.alpha = 0
            }
            
            // Depois, animação de saída do container
            UIView.animate(withDuration: duration, delay: duration * 0.5, options: .curveEaseIn) {
                if let velocity = velocity {
                    let translation = CGAffineTransform(translationX: 0,
                                                      y: velocity.y > 0 ? self.view.bounds.height : -self.view.bounds.height)
                    let scale = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.overlayContainer.transform = translation.concatenating(scale)
                } else {
                    // Se tiver sourceButton, anima de volta para ele
                    if let sourceFrame = self.sourceButton?.convert(self.sourceButton?.bounds ?? .zero, to: nil) {
                        self.overlayContainer.transform = CGAffineTransform(translationX: sourceFrame.midX - self.view.bounds.width/2,
                                                                          y: sourceFrame.midY - self.view.bounds.height/2)
                            .concatenating(CGAffineTransform(scaleX: 0.3, y: 0.3))
                    } else {
                        self.overlayContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }
                }
                
                self.blurView.alpha = 0
                self.overlayContainer.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        }
        
        func animateAppearance() {
            // Estado inicial
            blurView.alpha = 0
            overlayContainer.alpha = 0
            closeButton.alpha = 0
            searchButton.alpha = 0
            
            // Posição inicial baseada no botão de origem
            if let sourceFrame = sourceButton?.convert(sourceButton?.bounds ?? .zero, to: nil) {
                overlayContainer.transform = CGAffineTransform(translationX: sourceFrame.midX - view.bounds.width/2,
                                                             y: sourceFrame.midY - view.bounds.height/2)
                    .concatenating(CGAffineTransform(scaleX: 0.3, y: 0.3))
            } else {
                overlayContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    .concatenating(CGAffineTransform(translationX: 0, y: 50))
            }
            
            // Animação de entrada
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.blurView.alpha = 1
                self.overlayContainer.alpha = 1
                self.overlayContainer.transform = .identity
            }
            
            // Fade in dos botões
            UIView.animate(withDuration: 0.3, delay: 0.2) {
                self.closeButton.alpha = 1
                self.searchButton.alpha = 1
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
