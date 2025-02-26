//
//  Home+LineChartView.swift
//  CoinMB
//
//  Created by Rodrigo Souza on 24/02/25.
//

import UIKit

extension Home { 
    class LineChartView: UIView {
        // MARK: - Properties
        var dataPoints: [CGFloat] = [] {
            didSet {
                setNeedsLayout()
            }
        }
        
        private let pointLayer = CAShapeLayer()
        private var animated = true
        
        private let lineWidth: CGFloat = 2.0
        private let pointRadius: CGFloat = 8.0
        private let animationDuration: TimeInterval = 1.2
        private var selectedPointIndex: Int?
        private var isDragging = false
        private let feedbackGenerator = UISelectionFeedbackGenerator()
        private var lastSelectedIndex: Int?
        
        var onPointSelected: ((Int, CGFloat) -> Void)?
        var onDragBegan: (() -> Void)?
        var onDragEnded: (() -> Void)?
        
        var lineColor: UIColor = UIColor(red: 0.45, green: 0, blue: 0.87, alpha: 1.0) {
            didSet {
                updateColors()
            }
        }
        
        var gradientStartColor: UIColor {
            return lineColor.withAlphaComponent(0.3)
        }
        
        // MARK: - UI Components
        private let gradientLayer = CAGradientLayer()
        private let lineLayer = CAShapeLayer()
        private let dashLayer = CAShapeLayer()
        private let dashGradientLayer = CAGradientLayer()
        private let highlightLineLayer = CAShapeLayer()
        private let pointShadowLayer = CAShapeLayer()
        
        // MARK: - Init
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        private func setupView() {
            backgroundColor = .clear
            setupLayers()
            configureLineLayer()
            configurePointLayer()
            configureDashGradientLayer()
            configureHighlightLayer()
            configurePointShadowLayer()
            setupGestureRecognizers()
            updateColors()
            setupAccessibility()
        }

        private func setupAccessibility() {
            isAccessibilityElement = true
            accessibilityIdentifier = "Home.LineChartView"
            accessibilityLabel = "Gráfico de linha"
            accessibilityTraits = [.allowsDirectInteraction, .updatesFrequently]
            accessibilityHint = "Deslize para explorar os valores do gráfico"
            accessibilityValue = "Toque e arraste para explorar \(dataPoints.count) pontos de dados"
        }
        
        private func updateAccessibilityValue(for index: Int) {
            guard index >= 0 && index < dataPoints.count else { return }
            let value = dataPoints[index]
            accessibilityValue = "Ponto \(index + 1) de \(dataPoints.count), valor: \(String(format: "%.2f", value))"
        }
        
        private func setupLayers() {
            layer.addSublayer(gradientLayer)
            layer.addSublayer(lineLayer)
            layer.addSublayer(highlightLineLayer)
            layer.addSublayer(dashGradientLayer)
            layer.addSublayer(pointShadowLayer)
            layer.addSublayer(pointLayer)
        }
        
        private func configureLineLayer() {
            lineLayer.lineWidth = lineWidth
            lineLayer.lineCap = .round
            lineLayer.lineJoin = .round
            lineLayer.fillColor = nil
            lineLayer.strokeColor = lineColor.cgColor
            lineLayer.shadowColor = lineColor.cgColor
            lineLayer.shadowOffset = .zero
            lineLayer.shadowOpacity = 0.2
            lineLayer.shadowRadius = 8
        }
        
        private func configurePointLayer() {
            pointLayer.fillColor = UIColor.white.cgColor
            pointLayer.strokeColor = lineColor.cgColor
            pointLayer.lineWidth = 3.0
            pointLayer.shadowColor = UIColor.black.cgColor
            pointLayer.shadowOffset = CGSize(width: 0, height: 1)
            pointLayer.shadowOpacity = 0.3
            pointLayer.shadowRadius = 4
        }
        
        private func configureDashGradientLayer() {
            dashGradientLayer.colors = [
                UIColor.clear.cgColor,
                lineColor.cgColor,
                lineColor.cgColor,
                UIColor.clear.cgColor
            ]
            dashGradientLayer.locations = [0.0, 0.1, 0.9, 1.0]
            dashGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            dashGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            
            dashLayer.lineDashPattern = [4, 4]
            dashLayer.lineWidth = 1.0
            dashLayer.strokeColor = UIColor.white.cgColor
            dashGradientLayer.mask = dashLayer
        }
        
        private func configureHighlightLayer() {
            highlightLineLayer.lineWidth = lineWidth * 2
            highlightLineLayer.lineCap = .round
            highlightLineLayer.lineJoin = .round
            highlightLineLayer.fillColor = nil
            highlightLineLayer.strokeColor = lineColor.cgColor
            highlightLineLayer.opacity = 0
        }
        
        private func configurePointShadowLayer() {
            pointShadowLayer.fillColor = UIColor.black.cgColor
            pointShadowLayer.shadowColor = UIColor.black.cgColor
            pointShadowLayer.shadowOffset = .zero
            pointShadowLayer.shadowOpacity = 0.5
            pointShadowLayer.shadowRadius = 8
        }
        
        private func setupGestureRecognizers() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            addGestureRecognizer(panGesture)
            addGestureRecognizer(tapGesture)
        }
        
        private func updateColors() {
            let isDarkMode = traitCollection.userInterfaceStyle == .dark
            
            let startAlpha: CGFloat = isDarkMode ? 0.25 : 0.15
            let middleAlpha: CGFloat = isDarkMode ? 0.15 : 0.05
            
            gradientLayer.colors = [
                lineColor.withAlphaComponent(startAlpha).cgColor,
                lineColor.withAlphaComponent(middleAlpha).cgColor,
                UIColor.clear.cgColor
            ]
            gradientLayer.locations = [0, 0.5, 1.0]
            
            lineLayer.strokeColor = lineColor.cgColor
            pointLayer.strokeColor = lineColor.cgColor
            dashLayer.strokeColor = UIColor.white.cgColor
            
            dashGradientLayer.colors = [
                UIColor.clear.cgColor,
                lineColor.cgColor,
                lineColor.cgColor,
                UIColor.clear.cgColor
            ]
            
            highlightLineLayer.strokeColor = lineColor.cgColor
        }
        
        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            let location = gesture.location(in: self)
            
            switch gesture.state {
            case .began:
                feedbackGenerator.prepare()
                isDragging = true
                onDragBegan?()
                updateSelectedPoint(at: location)
            case .changed:
                updateSelectedPoint(at: location)
            case .ended, .cancelled:
                isDragging = false
                onDragEnded?()
                selectedPointIndex = nil
                lastSelectedIndex = nil
                setNeedsLayout()
            default:
                break
            }
        }
        
        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: self)
            feedbackGenerator.prepare()
            feedbackGenerator.selectionChanged()
            isDragging = true
            onDragBegan?()
            updateSelectedPoint(at: location)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isDragging = false
                self.onDragEnded?()
                self.selectedPointIndex = nil
                self.lastSelectedIndex = nil
                self.setNeedsLayout()
            }
        }
        
        private func updateSelectedPoint(at location: CGPoint) {
            guard !dataPoints.isEmpty else { return }
            
            let horizontalGap = bounds.width / CGFloat(dataPoints.count - 1)
            let index = Int((location.x / horizontalGap).rounded())
            let clampedIndex = max(0, min(index, dataPoints.count - 1))
            
            guard lastSelectedIndex != clampedIndex else { return }
            
            feedbackGenerator.selectionChanged()
            lastSelectedIndex = clampedIndex
            selectedPointIndex = clampedIndex
            
            updateAccessibilityValue(for: clampedIndex)
            
            DispatchQueue.main.async {
                self.onPointSelected?(clampedIndex, self.dataPoints[clampedIndex])
                self.setNeedsLayout()
            }
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            guard !dataPoints.isEmpty else { return }
            
            let rect = bounds
            let points = calculatePoints(in: rect)
            
            setupLinePath(with: points)
            setupGradientPath(in: rect)
            
            if animated {
                animateDrawing()
                animated = false
            }
            
            updateSelectionState(with: points)
        }
        
        private func calculatePoints(in rect: CGRect) -> [CGPoint] {
            let horizontalGap = rect.width / CGFloat(dataPoints.count - 1)
            let maxValue = dataPoints.max() ?? 1
            let scale = (rect.height * 0.8) / maxValue
            let verticalOffset = rect.height * 0.1
            
            return dataPoints.enumerated().map { index, value in
                CGPoint(
                    x: CGFloat(index) * horizontalGap,
                    y: rect.height - verticalOffset - (value * scale)
                )
            }
        }
        
        private func setupLinePath(with points: [CGPoint]) {
            let linePath = UIBezierPath()
            let pointsPath = UIBezierPath()
            let horizontalGap = bounds.width / CGFloat(dataPoints.count - 1)
            
            linePath.move(to: points[0])
            
            for pointIndex in 0..<points.count - 1 {
                let current = points[pointIndex]
                let next = points[pointIndex + 1]
                
                let controlPoint1 = CGPoint(x: current.x + horizontalGap/3, y: current.y)
                let controlPoint2 = CGPoint(x: next.x - horizontalGap/3, y: next.y)
                
                linePath.addCurve(to: next, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            }
            
            for point in points {
                let circleRect = CGRect(x: point.x - 4, y: point.y - 4, width: 8, height: 8)
                pointsPath.append(UIBezierPath(ovalIn: circleRect))
            }
            
            lineLayer.path = linePath.cgPath
            pointLayer.path = pointsPath.cgPath
        }
        
        private func setupGradientPath(in rect: CGRect) {
            guard let linePath = lineLayer.path,
                  let gradientPath = UIBezierPath(cgPath: linePath).copy() as? UIBezierPath else {
                return
            }
            
            gradientPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
            gradientPath.addLine(to: CGPoint(x: 0, y: rect.height))
            gradientPath.close()
            
            let gradientMaskLayer = CAShapeLayer()
            gradientMaskLayer.path = gradientPath.cgPath
            gradientLayer.frame = rect
            gradientLayer.mask = gradientMaskLayer
        }
        
        private func updateSelectionState(with points: [CGPoint]) {
            if let selectedIndex = selectedPointIndex {
                updateLayersForSelection(at: selectedIndex, points: points)
            } else {
                resetLayersToDefault()
            }
        }
        
        private func updateLayersForSelection(at selectedIndex: Int, points: [CGPoint]) {
            lineLayer.opacity = isDragging ? 0.3 : 1.0
            gradientLayer.opacity = isDragging ? 0.6 : 1.0
            
            let point = points[selectedIndex]
            updateDashLayer(at: point)
            updateSelectedPoint(at: point)
            
            if isDragging {
                updateHighlightPath(at: selectedIndex, points: points)
            } else {
                highlightLineLayer.opacity = 0
            }
        }
        
        private func updateDashLayer(at point: CGPoint) {
            let dashPath = UIBezierPath()
            dashPath.move(to: CGPoint(x: point.x, y: 0))
            dashPath.addLine(to: CGPoint(x: point.x, y: bounds.height))
            dashLayer.path = dashPath.cgPath
            dashGradientLayer.frame = bounds
            dashGradientLayer.opacity = isDragging ? 1.0 : 0.0
            
            let selectedPointPath = UIBezierPath(arcCenter: point,
                                               radius: pointRadius,
                                               startAngle: 0,
                                               endAngle: .pi * 2,
                                               clockwise: true)
            
            pointShadowLayer.path = selectedPointPath.cgPath
            pointShadowLayer.opacity = isDragging ? 1.0 : 0.0
            
            pointLayer.path = selectedPointPath.cgPath
        }
        
        private func updateHighlightPath(at selectedIndex: Int, points: [CGPoint]) {
            let highlightPath = UIBezierPath()
            let segmentWidth: CGFloat = bounds.width / CGFloat(points.count - 1)
            
            let startIndex = max(0, selectedIndex - 1)
            let endIndex = min(points.count - 1, selectedIndex + 1)
            
            highlightPath.move(to: points[startIndex])
            
            if startIndex < selectedIndex {
                let controlPoint1 = CGPoint(x: points[startIndex].x + segmentWidth/3, y: points[startIndex].y)
                let controlPoint2 = CGPoint(x: points[selectedIndex].x - segmentWidth/3, y: points[selectedIndex].y)
                highlightPath.addCurve(
                    to: points[selectedIndex], 
                    controlPoint1: controlPoint1, 
                    controlPoint2: controlPoint2
                )
            }
            
            if selectedIndex < endIndex {
                let controlPoint1 = CGPoint(x: points[selectedIndex].x + segmentWidth/3, y: points[selectedIndex].y)
                let controlPoint2 = CGPoint(x: points[endIndex].x - segmentWidth/3, y: points[endIndex].y)
                highlightPath.addCurve(
                    to: points[endIndex], 
                    controlPoint1: controlPoint1, 
                    controlPoint2: controlPoint2
                )
            }
            
            highlightLineLayer.path = highlightPath.cgPath
            highlightLineLayer.opacity = 1.0
        }
        
        private func resetLayersToDefault() {
            lineLayer.opacity = 1.0
            gradientLayer.opacity = 1.0
            dashLayer.path = nil
            dashGradientLayer.opacity = 0
            pointLayer.path = nil
            pointShadowLayer.opacity = 0
            highlightLineLayer.opacity = 0
        }
        
        private func animateDrawing() {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = animationDuration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.duration = animationDuration / 2
            fadeAnimation.fromValue = 0
            fadeAnimation.toValue = 1
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
            
            gradientLayer.add(fadeAnimation, forKey: "fadeAnimation")
            lineLayer.add(animation, forKey: "lineAnimation")
            pointLayer.add(animation, forKey: "pointsAnimation")
        }
        
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                updateColors()
            }
        }
    } 
}
