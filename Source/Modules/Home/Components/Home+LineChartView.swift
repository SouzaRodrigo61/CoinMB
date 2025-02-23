import UIKit

extension Home { 
    class LineChartView: UIView {
        // MARK: - Properties
        var dataPoints: [CGFloat] = [] {
            didSet {
                setNeedsLayout()
            }
        }
        
        // MARK: - UI Components
        private let gradientLayer = CAGradientLayer()
        private let lineLayer = CAShapeLayer()
        
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
            
            let customBlueColor = UIColor.systemBlue.withAlphaComponent(0.5)
            
            layer.addSublayer(gradientLayer)
            layer.addSublayer(lineLayer)
            
            gradientLayer.colors = [customBlueColor.cgColor, UIColor.clear.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.strokeColor = UIColor.systemBlue.cgColor
            lineLayer.lineWidth = 3.0
            lineLayer.lineCap = .round
            lineLayer.lineJoin = .round
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard !dataPoints.isEmpty else { return }
            
            let rect = bounds
            let linePath = UIBezierPath()
            
            let horizontalGap = rect.width / CGFloat(dataPoints.count - 1)
            let maxValue = dataPoints.max() ?? 1
            let scale = rect.height / maxValue
            
            let startPoint = CGPoint(x: 0, y: rect.height - (dataPoints[0] * scale))
            linePath.move(to: startPoint)
            
            for pointIndex in 0..<dataPoints.count {
                let nextPoint = CGPoint(
                    x: CGFloat(pointIndex) * horizontalGap,
                    y: rect.height - (dataPoints[pointIndex] * scale)
                )
                linePath.addLine(to: nextPoint)
            }
            
            lineLayer.path = linePath.cgPath
            
            linePath.addLine(to: CGPoint(x: rect.width, y: rect.height))
            linePath.addLine(to: CGPoint(x: 0, y: rect.height))
            
            let gradientMaskLayer = CAShapeLayer()
            gradientMaskLayer.path = linePath.cgPath
            
            gradientLayer.frame = rect
            gradientLayer.mask = gradientMaskLayer
        }
    } 
}
