// 
//  TimeFilterView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/25.
//

import UIKit
import SnapKit

extension Home { 
    
    class TimeFilterView: UIView {
        // MARK: - Properties
        private let scrollView = UIScrollView()
        private let stackView = UIStackView()
        private let selectionIndicator = UIView()
        private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        
        private var buttons: [UIButton] = []
        private var currentSelectedButton: UIButton?
        private var isDragging = false
        
        var onFilterSelected: ((TimeFilter) -> Void)?
        
        enum TimeFilter: String, CaseIterable {
            case oneDay = "1D"
            case oneWeek = "1S"
            case oneMonth = "1M"
            case sixMonths = "6M"
            case oneYear = "1A"
            case fiveYears = "5A"
            case all = "All"
        }
        
        // Constantes de design
        private enum Design {
            static let cornerRadius: CGFloat = 24
            static let buttonHeight: CGFloat = 36
            static let buttonWidth: CGFloat = 48
            static let stackViewSpacing: CGFloat = 12
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 8
            
            // Novas constantes de animação
            static let normalAnimationDuration: TimeInterval = 0.5
            static let dragAnimationDuration: TimeInterval = 0.25
            static let springDamping: CGFloat = 0.7
            static let springVelocity: CGFloat = 0.3
        }
        
        // MARK: - Init
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }
        
        // MARK: - Setup
        private func setupView() {
            backgroundColor = .systemGray6.withAlphaComponent(0.8)
            layer.cornerRadius = Design.cornerRadius
            clipsToBounds = true
            
            // Adicionar efeito de blur
            let blurEffect = UIBlurEffect(style: .systemMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            insertSubview(blurView, at: 0)
            
            setupScrollView()
            setupStackView()
            setupSelectionIndicator()
            setupButtons()
            setupGestureRecognizer()
            feedbackGenerator.prepare()
        }
        
        private func setupScrollView() {
            addSubview(scrollView)
            scrollView.showsHorizontalScrollIndicator = false
            
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        private func setupStackView() {
            scrollView.addSubview(stackView)
            stackView.axis = .horizontal
            stackView.spacing = Design.stackViewSpacing
            stackView.alignment = .center
            stackView.distribution = .equalSpacing
            
            stackView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(scrollView).offset(Design.horizontalPadding)
                make.trailing.equalTo(scrollView).offset(-Design.horizontalPadding)
                make.height.equalTo(Design.buttonHeight)
            }
        }
        
        private func setupSelectionIndicator() {
            selectionIndicator.backgroundColor = .systemBackground
            selectionIndicator.layer.cornerRadius = Design.buttonHeight / 2
            selectionIndicator.layer.shadowColor = UIColor.black.cgColor
            selectionIndicator.layer.shadowOffset = CGSize(width: 0, height: 2)
            selectionIndicator.layer.shadowRadius = 4
            selectionIndicator.layer.shadowOpacity = 0.1
            insertSubview(selectionIndicator, belowSubview: scrollView)
        }
        
        private func setupButtons() {
            TimeFilter.allCases.forEach { filter in
                let button = UIButton()
                button.setTitle(filter.rawValue, for: .normal)
                button.setTitleColor(.secondaryLabel, for: .normal)
                button.setTitleColor(.label, for: .selected)
                button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
                button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
                
                buttons.append(button)
                stackView.addArrangedSubview(button)
                
                button.snp.makeConstraints { make in
                    make.width.equalTo(Design.buttonWidth)
                    make.height.equalTo(Design.buttonHeight)
                }
            }
            
            // Garantir que o layout seja atualizado antes de posicionar o indicador
            layoutIfNeeded()
            
            // Selecionar o primeiro botão após o layout estar pronto
            DispatchQueue.main.async {
                if let firstButton = self.buttons.first {
                    self.selectionIndicator.snp.makeConstraints { make in
                        make.height.equalTo(Design.buttonHeight)
                        make.width.equalTo(Design.buttonWidth)
                        make.centerY.equalToSuperview()
                        make.centerX.equalTo(firstButton)
                    }
                    self.selectButton(firstButton)
                }
            }
        }
        
        private func setupGestureRecognizer() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
            addGestureRecognizer(panGesture)
        }
        
        @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: self)
            
            switch gesture.state {
            case .began:
                isDragging = true
                feedbackGenerator.prepare()
                
            case .changed:
                guard isDragging else { return }
                
                // Adicionar um pequeno delay para evitar mudanças muito rápidas
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                perform(#selector(checkButtonSelection), with: location, afterDelay: 0.05)
                
            case .ended, .cancelled:
                isDragging = false
                // Animação final mais suave quando solta
                if let currentButton = currentSelectedButton {
                    selectButton(currentButton)
                }
                
            default:
                break
            }
        }
        
        @objc private func checkButtonSelection(_ location: Any?) {
            guard let point = location as? CGPoint else { return }
            
            if let closestButton = findClosestButton(to: point) {
                if closestButton != currentSelectedButton {
                    feedbackGenerator.impactOccurred(intensity: 0.5)
                    selectButton(closestButton)
                }
            }
        }
        
        private func findClosestButton(to point: CGPoint) -> UIButton? {
            var closestButton: UIButton?
            var minDistance: CGFloat = .infinity
            
            for button in buttons {
                let buttonFrame = button.convert(button.bounds, to: self)
                let buttonCenterX = buttonFrame.midX
                let distance = abs(buttonCenterX - point.x)
                
                if distance < minDistance {
                    minDistance = distance
                    closestButton = button
                }
            }
            
            return closestButton
        }
        
        // MARK: - Actions
        @objc private func filterButtonTapped(_ sender: UIButton) {
            guard sender != currentSelectedButton else { return }
            selectButton(sender)
        }
        
        private func selectButton(_ button: UIButton) {
            guard button != currentSelectedButton else { return }
            
            currentSelectedButton?.isSelected = false
            button.isSelected = true
            currentSelectedButton = button
            
            // Scroll para centralizar o botão selecionado
            let buttonFrame = button.convert(button.bounds, to: scrollView)
            let centerPoint = CGPoint(
                x: buttonFrame.midX - scrollView.bounds.width / 2,
                y: 0
            )
            
            // Animação do scroll mais suave
            let scrollDuration = isDragging ? Design.dragAnimationDuration : Design.normalAnimationDuration
            UIView.animate(withDuration: scrollDuration,
                          delay: 0,
                          usingSpringWithDamping: Design.springDamping,
                          initialSpringVelocity: Design.springVelocity) {
                self.scrollView.contentOffset = centerPoint
            }
            
            // Animação do indicador mais suave
            UIView.animate(withDuration: scrollDuration,
                          delay: 0,
                          usingSpringWithDamping: Design.springDamping,
                          initialSpringVelocity: Design.springVelocity) {
                self.selectionIndicator.snp.remakeConstraints { make in
                    make.height.equalTo(Design.buttonHeight)
                    make.width.equalTo(Design.buttonWidth)
                    make.centerY.equalToSuperview()
                    make.centerX.equalTo(button.snp.centerX)
                }
                self.layoutIfNeeded()
            }
            
            if let index = buttons.firstIndex(of: button),
               let filter = TimeFilter.allCases[safe: index] {
                onFilterSelected?(filter)
            }
        }
    }
    
}
// MARK: - Helper
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
