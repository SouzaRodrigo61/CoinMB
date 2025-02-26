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
        let textField = UITextField()
        textField.placeholder = "Buscar criptomoedas"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        textField.leftViewMode = .always
        return textField
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
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        overlayContainer.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBlurTap))
        blurView.addGestureRecognizer(tapGesture)
        
        let whenTap = UITapGestureRecognizer(target: self, action: #selector(handleWhenTap))
        whenContainer.addGestureRecognizer(whenTap)
        
        let whoTap = UITapGestureRecognizer(target: self, action: #selector(handleWhoTap))
        whoContainer.addGestureRecognizer(whoTap)
    }
    
    func setupInitialState() {
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
    }
    
    @objc func handleWhoTap() {
    }
    
    @objc func handleOptionTap(_ gesture: UITapGestureRecognizer) {
    }
}

// MARK: - Animations
extension Home.SearchOverlayViewController {
    func animateAppearance() {
        blurView.alpha = 0
        overlayContainer.alpha = 0
        closeButton.alpha = 0
        searchButton.alpha = 0
        
        if let sourceButton = sourceButton,
           let sourceFrame = sourceButton.superview?.convert(sourceButton.frame, to: nil) {
            
            let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            let translateX = sourceFrame.midX - view.bounds.width/2
            let translateY = sourceFrame.midY - view.bounds.height/2
            let translationTransform = CGAffineTransform(translationX: translateX, y: translateY)
            
            overlayContainer.transform = scaleTransform.concatenating(translationTransform)
        } else {
            overlayContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
            self.blurView.alpha = 1
            self.overlayContainer.alpha = 1
            self.overlayContainer.transform = .identity
            self.closeButton.alpha = 1
            self.searchButton.alpha = 1
        }
    }
    
    func dismissWithAnimation(velocity: CGPoint? = nil) {
        let duration: TimeInterval = 0.5
        
        if let sourceButton = sourceButton,
           let sourceFrame = sourceButton.superview?.convert(sourceButton.frame, to: nil) {
            
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                let translateX = sourceFrame.midX - self.view.bounds.width/2
                let translateY = sourceFrame.midY - self.view.bounds.height/2
                let translationTransform = CGAffineTransform(translationX: translateX, y: translateY)
                
                self.overlayContainer.transform = scaleTransform.concatenating(translationTransform)
                
                self.overlayContainer.alpha = 1
                
                self.blurView.alpha = 0
                self.closeButton.alpha = 0
                self.searchButton.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        } else {
            UIView.animate(withDuration: duration) {
                self.overlayContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                self.overlayContainer.alpha = 1
                self.blurView.alpha = 0
                self.closeButton.alpha = 0
                self.searchButton.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
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
            
            let progress = min(1, max(abs(xOffset), abs(yOffset)) / 200)
            
            let scale = 1.0 - (progress * 0.2)
            let translation = CGAffineTransform(translationX: xOffset, y: yOffset)
            let scaling = CGAffineTransform(scaleX: scale, y: scale)
            
            let angle = (xOffset / 500) * (.pi / 8)
            let rotation = CGAffineTransform(rotationAngle: angle)
            
            overlayContainer.transform = translation
                .concatenating(scaling)
                .concatenating(rotation)
            
            let minBlurAlpha: CGFloat = 0.5
            let minOverlayAlpha: CGFloat = 0.8
            blurView.alpha = max(minBlurAlpha, 1 - progress)
            overlayContainer.alpha = max(minOverlayAlpha, 1 - progress)
            closeButton.alpha = 1 - progress
            searchButton.alpha = 1 - progress
            
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            let xOffset = touchPoint.x - initialTouchPoint.x
            let yOffset = touchPoint.y - initialTouchPoint.y
            
            let shouldDismiss = abs(velocity.x) > 500 || abs(velocity.y) > 500 ||
                              abs(xOffset) > 200 || abs(yOffset) > 200
            
            if shouldDismiss {
                let isHorizontal = abs(velocity.x) > abs(velocity.y)
                let dismissVelocity = CGPoint(
                    x: isHorizontal ? velocity.x : 0,
                    y: isHorizontal ? 0 : velocity.y
                )
                dismissWithAnimation(velocity: dismissVelocity)
            } else {
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
