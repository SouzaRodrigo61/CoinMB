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
        // MARK: - Properties
        var sourceButton: UIButton?
        var sourceButtonFrame: CGRect = .zero
        
        // Propriedades para controle do drag
        private var initialTouchPoint: CGPoint = .zero
        private var initialOverlayTransform: CGAffineTransform = .identity
        
        private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
        private let matchGeometryNamespace = "SearchOverlay"
        
        // MARK: - UI Components
        private lazy var blurView = makeBlurView()
        private lazy var overlayContainer = makeOverlayContainer()
        private lazy var closeButton = makeCloseButton()
        private lazy var titleLabel = makeTitleLabel()
        private lazy var searchContainer = makeSearchContainer()
        private lazy var searchTextField = makeSearchTextField()
        private lazy var optionsStackView = makeOptionsStackView()
        private lazy var whenContainer = makeWhenContainer()
        private lazy var whoContainer = makeWhoContainer()
        private lazy var whenLabel = makeWhenLabel()
        private lazy var whenValueLabel = makeWhenValueLabel()
        private lazy var whoLabel = makeWhoLabel()
        private lazy var whoValueLabel = makeWhoValueLabel()
        private lazy var searchButton = makeSearchButton()
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupViews()
            setupGestures()
            setupInitialState()
        }
    }
}

// MARK: - UI Components Creation
private extension Home.SearchOverlayViewController {
    func makeBlurView() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.alpha = 0
        return view
    }
    
    func makeOverlayContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.alpha = 0
        return view
    }
    
    func makeCloseButton() -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.alpha = 0
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }
    
    func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.text = "Para onde?"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }
    
    func makeSearchContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }
    
    func makeSearchTextField() -> UITextField {
        let tf = UITextField()
        tf.placeholder = "Buscar criptomoedas"
        tf.font = .systemFont(ofSize: 16, weight: .regular)
        tf.textColor = .label
        tf.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        tf.leftViewMode = .always
        return tf
    }
    
    func makeOptionsStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        return stack
    }
    
    func makeWhenContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }
    
    func makeWhoContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }
    
    func makeWhenLabel() -> UILabel {
        let label = UILabel()
        label.text = "When"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }
    
    func makeWhenValueLabel() -> UILabel {
        let label = UILabel()
        label.text = "Any week"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }
    
    func makeWhoLabel() -> UILabel {
        let label = UILabel()
        label.text = "Who"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }
    
    func makeWhoValueLabel() -> UILabel {
        let label = UILabel()
        label.text = "Add guests"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }
    
    func makeSearchButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Search", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(handleSearch), for: .touchUpInside)
        return button
    }
}

// MARK: - Setup
private extension Home.SearchOverlayViewController {
    func setupViews() {
        view.backgroundColor = .clear
        
        view.addSubview(blurView)
        view.addSubview(overlayContainer)
        
        overlayContainer.addSubview(closeButton)
        overlayContainer.addSubview(titleLabel)
        overlayContainer.addSubview(searchContainer)
        overlayContainer.addSubview(optionsStackView)
        overlayContainer.addSubview(whenContainer)
        overlayContainer.addSubview(whoContainer)
        overlayContainer.addSubview(searchButton)
        
        searchContainer.addSubview(searchTextField)
        whenContainer.addSubview(whenLabel)
        whenContainer.addSubview(whenValueLabel)
        whoContainer.addSubview(whoLabel)
        whoContainer.addSubview(whoValueLabel)
        
        setupConstraints()
        setupOptions()
    }
    
    func setupConstraints() {
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        overlayContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(overlayContainer).offset(16)
            make.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(24)
            make.leading.trailing.equalTo(overlayContainer).inset(16)
        }
        
        searchContainer.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalTo(overlayContainer).inset(16)
            make.height.equalTo(56)
        }
        
        searchTextField.snp.makeConstraints { make in
            make.edges.equalTo(searchContainer).inset(16)
        }
        
        optionsStackView.snp.makeConstraints { make in
            make.top.equalTo(searchContainer.snp.bottom).offset(24)
            make.leading.trailing.equalTo(overlayContainer).inset(16)
            make.height.equalTo(120)
        }
        
        whenContainer.snp.makeConstraints { make in
            make.top.equalTo(optionsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalTo(overlayContainer).inset(16)
            make.height.equalTo(56)
        }
        
        whenLabel.snp.makeConstraints { make in
            make.leading.equalTo(whenContainer).offset(16)
            make.centerY.equalTo(whenContainer)
        }
        
        whenValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(whenContainer).offset(-16)
            make.centerY.equalTo(whenContainer)
        }
        
        whoContainer.snp.makeConstraints { make in
            make.top.equalTo(whenContainer.snp.bottom).offset(12)
            make.leading.trailing.equalTo(overlayContainer).inset(16)
            make.height.equalTo(56)
        }
        
        whoLabel.snp.makeConstraints { make in
            make.leading.equalTo(whoContainer).offset(16)
            make.centerY.equalTo(whoContainer)
        }
        
        whoValueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(whoContainer).offset(-16)
            make.centerY.equalTo(whoContainer)
        }
        
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(whoContainer.snp.bottom).offset(24)
            make.leading.trailing.equalTo(overlayContainer).inset(16)
            make.height.equalTo(48)
        }
    }
    
    func setupGestures() {
        // Adiciona o pan gesture para drag
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        overlayContainer.addGestureRecognizer(panGesture)
        
        // Adiciona tap no blur para dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBlurTap))
        blurView.addGestureRecognizer(tapGesture)
        
        let whenTap = UITapGestureRecognizer(target: self, action: #selector(handleWhenTap))
        whenContainer.addGestureRecognizer(whenTap)
        
        let whoTap = UITapGestureRecognizer(target: self, action: #selector(handleWhoTap))
        whoContainer.addGestureRecognizer(whoTap)
    }
    
    func setupInitialState() {
        // Configura alpha inicial dos elementos
        blurView.alpha = 0
        overlayContainer.alpha = 0
        closeButton.alpha = 0
        searchButton.alpha = 0
    }
    
    func setupOptions() {
        let options = ["Todas", "Bitcoin", "Ethereum"]
        options.forEach { option in
            let optionView = createOptionView(title: option)
            optionsStackView.addArrangedSubview(optionView)
        }
    }
    
    func createOptionView(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray5.cgColor
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOptionTap(_:)))
        container.addGestureRecognizer(tap)
        
        return container
    }
}

// MARK: - Handlers
private extension Home.SearchOverlayViewController {
    @objc func handleClose() {
        dismissWithAnimation()
    }
    
    @objc func handleSearch() {
        dismissWithAnimation()
    }
    
    @objc func handleBlurTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !overlayContainer.frame.contains(location) {
            dismissWithAnimation()
        }
    }
    
    @objc func handleWhenTap() {
        // Implementar lógica para seleção de data
    }
    
    @objc func handleWhoTap() {
        // Implementar lógica para seleção de convidados
    }
    
    @objc func handleOptionTap(_ gesture: UITapGestureRecognizer) {
        guard let optionView = gesture.view else { return }
        // Implementar a lógica de seleção aqui
    }
}

// MARK: - Animations
extension Home.SearchOverlayViewController {
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
    
    func dismissWithAnimation(velocity: CGPoint? = nil) {
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
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
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
}

// MARK: - UISearchBarDelegate
extension Home.SearchOverlayViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissWithAnimation()
    }
}
