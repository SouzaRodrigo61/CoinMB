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
        
        private var buttons: [UIButton] = []
        private var currentSelectedButton: UIButton?
        
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
            static let horizontalPadding: CGFloat = 12
            static let verticalPadding: CGFloat = 8
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
            stackView.distribution = .fillEqually
            
            stackView.snp.makeConstraints { make in
                make.top.equalTo(scrollView).offset(Design.verticalPadding)
                make.leading.equalTo(scrollView).offset(Design.horizontalPadding)
                make.trailing.equalTo(scrollView).offset(-Design.horizontalPadding)
                make.bottom.equalTo(scrollView).offset(-Design.verticalPadding)
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
            
            selectionIndicator.snp.makeConstraints { make in
                make.height.equalTo(Design.buttonHeight)
                make.width.equalTo(Design.buttonWidth)
                make.centerY.equalToSuperview()
            }
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
                }
            }
            
            if let firstButton = buttons.first {
                selectButton(firstButton)
            }
        }
        
        // MARK: - Actions
        @objc private func filterButtonTapped(_ sender: UIButton) {
            guard sender != currentSelectedButton else { return }
            selectButton(sender)
        }
        
        private func selectButton(_ button: UIButton) {
            currentSelectedButton?.isSelected = false
            button.isSelected = true
            currentSelectedButton = button
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.selectionIndicator.snp.remakeConstraints { make in
                    make.height.equalTo(Design.buttonHeight)
                    make.width.equalTo(Design.buttonWidth)
                    make.centerY.equalToSuperview()
                    make.centerX.equalTo(button)
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
