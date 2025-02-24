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
            
            layer.addSublayer(gradientLayer)
            layer.addSublayer(lineLayer)
            layer.addSublayer(pointLayer)
            layer.addSublayer(dashLayer)
            layer.addSublayer(dashGradientLayer)
            
            lineLayer.lineWidth = lineWidth
            lineLayer.lineCap = .round
            lineLayer.lineJoin = .round
            lineLayer.fillColor = nil
            lineLayer.strokeColor = lineColor.cgColor
            lineLayer.shadowColor = lineColor.cgColor
            lineLayer.shadowOffset = .zero
            lineLayer.shadowOpacity = 0.2
            lineLayer.shadowRadius = 8
            
            pointLayer.fillColor = UIColor.white.cgColor
            pointLayer.strokeColor = lineColor.cgColor
            pointLayer.lineWidth = 2.0
            pointLayer.shadowColor = lineColor.cgColor
            pointLayer.shadowOffset = .zero
            pointLayer.shadowOpacity = 0.2
            pointLayer.shadowRadius = 8
            
            dashGradientLayer.colors = [
                UIColor.clear.cgColor,
                UIColor.systemGray.cgColor,
                UIColor.systemGray.cgColor,
                UIColor.clear.cgColor
            ]
            dashGradientLayer.locations = [0.0, 0.1, 0.9, 1.0]
            dashGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            dashGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            
            dashLayer.lineDashPattern = [4, 4]
            dashLayer.lineWidth = 1.0
            dashLayer.strokeColor = UIColor.white.cgColor
            dashGradientLayer.mask = dashLayer
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            addGestureRecognizer(panGesture)
            addGestureRecognizer(tapGesture)
            
            updateColors()
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
        }
        
        private func updateSelectedPoint(at location: CGPoint) {
            guard !dataPoints.isEmpty else { return }
            
            let horizontalGap = bounds.width / CGFloat(dataPoints.count - 1)
            let index = Int((location.x / horizontalGap).rounded())
            let clampedIndex = max(0, min(index, dataPoints.count - 1))
            
            if lastSelectedIndex != clampedIndex {
                feedbackGenerator.selectionChanged()
                lastSelectedIndex = clampedIndex
            }
            
            selectedPointIndex = clampedIndex
            onPointSelected?(clampedIndex, dataPoints[clampedIndex])
            
            setNeedsLayout()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard !dataPoints.isEmpty else { return }
            
            let rect = bounds
            let linePath = UIBezierPath()
            let pointsPath = UIBezierPath()
            
            let horizontalGap = rect.width / CGFloat(dataPoints.count - 1)
            let maxValue = dataPoints.max() ?? 1
            let scale = (rect.height * 0.8) / maxValue
            let verticalOffset = rect.height * 0.1
            
            var points: [CGPoint] = []
            
            for pointIndex in 0..<dataPoints.count {
                let point = CGPoint(
                    x: CGFloat(pointIndex) * horizontalGap,
                    y: rect.height - verticalOffset - (dataPoints[pointIndex] * scale)
                )
                points.append(point)
            }
            
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
            
            guard let gradientPath = linePath.copy() as? UIBezierPath else {
                return
            }
            gradientPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
            gradientPath.addLine(to: CGPoint(x: 0, y: rect.height))
            gradientPath.close()
            
            let gradientMaskLayer = CAShapeLayer()
            gradientMaskLayer.path = gradientPath.cgPath
            gradientLayer.frame = rect
            gradientLayer.mask = gradientMaskLayer
            
            if animated {
                animateDrawing()
                animated = false
            }
            
            if let selectedIndex = selectedPointIndex {
                let point = points[selectedIndex]
                let dashPath = UIBezierPath()
                dashPath.move(to: CGPoint(x: point.x, y: 0))
                dashPath.addLine(to: CGPoint(x: point.x, y: bounds.height))
                
                dashLayer.path = dashPath.cgPath
                dashGradientLayer.frame = bounds
                dashGradientLayer.opacity = 1.0
                
                let selectedPointPath = UIBezierPath(arcCenter: point,
                                                   radius: pointRadius,
                                                   startAngle: 0,
                                                   endAngle: .pi * 2,
                                                   clockwise: true)
                pointLayer.path = selectedPointPath.cgPath
            } else {
                dashLayer.path = nil
                dashGradientLayer.opacity = 0
                pointLayer.path = nil
            }
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
