//
//  Home+RollingCounterLabel.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/25.
//

import UIKit

extension Home {
    class RollingCounterLabel: UILabel {
        private var currentValue: Double = 0
        private var targetValue: Double = 0
        private var animationDuration: TimeInterval = 0.3
        private var displayLink: CADisplayLink?
        private var startTime: CFTimeInterval = 0
        private var formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLabel()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupLabel()
        }
        
        private func setupLabel() {
            font = .systemFont(ofSize: 24, weight: .bold)
            textAlignment = .left
        }
        
        func setValue(_ value: Double, animated: Bool = true) {
            displayLink?.invalidate()
            
            if !animated {
                currentValue = value
                targetValue = value
                updateText(value)
                return
            }
            
            targetValue = value
            startTime = CACurrentMediaTime()
            
            displayLink = CADisplayLink(target: self, selector: #selector(handleUpdate))
            displayLink?.add(to: .main, forMode: .common)
        }
        
        @objc private func handleUpdate(_ displayLink: CADisplayLink) {
            let elapsed = CACurrentMediaTime() - startTime
            let progress = min(1.0, elapsed / animationDuration)
            
            if progress >= 1.0 {
                self.displayLink?.invalidate()
                self.displayLink = nil
                currentValue = targetValue
                updateText(targetValue)
                return
            }
            
            // Função de easing para suavizar a animação
            let easedProgress = progress * (2 - progress)
            let newValue = currentValue + (targetValue - currentValue) * easedProgress
            updateText(newValue)
        }
        
        private func updateText(_ value: Double) {
            text = formatter.string(from: NSNumber(value: value))
        }
    }
} 