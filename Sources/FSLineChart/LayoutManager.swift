import CoreGraphics
import UIKit

/// Manages the layout and rendering of a chart’s visual components, including lines, data points, and labels.
class LayoutManager {
    private var layers: [CALayer] = []
    private let boundsCalculator = BoundsCalculator()
    
    private(set) var axisWidth: CGFloat = 0
    private(set) var axisHeight: CGFloat = 0
    private var cachedHorizontalScale: CGFloat?
    private var cachedVerticalScale: CGFloat?
    
    /// Configures the axis size based on the chart’s frame and margin.
    /// - Parameters:
    ///   - frame: The chart’s frame.
    ///   - margin: The margin around the chart.
    func recalculateAxisSize(from frame: CGRect, margin: CGFloat) {
        axisWidth = frame.size.width - 2 * margin
        axisHeight = frame.size.height - 2 * margin
        cachedHorizontalScale = nil
        cachedVerticalScale = nil
    }
    
    /// Lays out the chart’s visual elements in the provided view.
    /// - Parameters:
    ///   - configuration: The chart’s configuration.
    ///   - view: The chart view to render into.
    @MainActor
    func layoutChart(configuration: ChartConfiguration, in view: FSLineChart) throws {
        view.subviews.forEach { $0.removeFromSuperview() }
        layers.forEach { $0.removeFromSuperlayer() }
        layers.removeAll()
        
        guard !configuration.data.isEmpty else { return }
        
        try boundsCalculator.computeBounds(
            data: configuration.data,
            verticalGridStep: configuration.style.gridSteps.vertical
        )
        
        try strokeChart(configuration: configuration, in: view)
        
        if configuration.style.displayDataPoints {
            try strokeDataPoints(configuration: configuration, in: view)
        }
        
        if let labels = configuration.labels {
            for i in 0..<configuration.style.gridSteps.vertical {
                if let label = createLabelForValue(index: i, configuration: configuration, labels: labels) {
                    view.addSubview(label)
                }
            }
            
            for i in 0..<configuration.style.gridSteps.horizontal + 1 {
                if let label = createLabelForIndex(index: i, configuration: configuration, labels: labels) {
                    view.addSubview(label)
                }
            }
        }
        
        view.setNeedsDisplay()
    }
    
    /// Calculates the horizontal scale for the chart.
    /// - Parameters:
    ///   - data: The dataset.
    ///   - horizontalGridStep: The number of horizontal grid lines.
    /// - Returns: The calculated scale.
    func calculateHorizontalScale(data: [Double], horizontalGridStep: Int) -> CGFloat {
        if let cached = cachedHorizontalScale { return cached }
        let scale = ChartUtilities.calculateHorizontalScale(data: data, horizontalGridStep: horizontalGridStep)
        cachedHorizontalScale = scale
        return scale
    }
    
    /// The minimum vertical bound from the bounds calculator.
    var minVerticalBound: CGFloat {
        return boundsCalculator.minVerticalBound
    }
    
    /// The maximum vertical bound from the bounds calculator.
    var maxVerticalBound: CGFloat {
        return boundsCalculator.maxVerticalBound
    }
    
    @MainActor
    private func strokeChart(configuration: ChartConfiguration, in view: FSLineChart) throws {
        let minBound = boundsCalculator.minVerticalBound
        let scale = verticalScale(configuration: configuration)
        
        let noPath = try ChartUtilities.getLinePath(
            data: configuration.data,
            scale: 0,
            axisWidth: axisWidth,
            axisHeight: axisHeight,
            margin: configuration.style.margin,
            smoothed: configuration.style.bezierSmoothing,
            smoothingTension: configuration.style.bezierSmoothingTension,
            closed: false
        )
        let path = try ChartUtilities.getLinePath(
            data: configuration.data,
            scale: scale,
            axisWidth: axisWidth,
            axisHeight: axisHeight,
            margin: configuration.style.margin,
            smoothed: configuration.style.bezierSmoothing,
            smoothingTension: configuration.style.bezierSmoothingTension,
            closed: false
        )
        
        let noFill = try ChartUtilities.getLinePath(
            data: configuration.data,
            scale: 0,
            axisWidth: axisWidth,
            axisHeight: axisHeight,
            margin: configuration.style.margin,
            smoothed: configuration.style.bezierSmoothing,
            smoothingTension: configuration.style.bezierSmoothingTension,
            closed: true
        )
        let fill = try ChartUtilities.getLinePath(
            data: configuration.data,
            scale: scale,
            axisWidth: axisWidth,
            axisHeight: axisHeight,
            margin: configuration.style.margin,
            smoothed: configuration.style.bezierSmoothing,
            smoothingTension: configuration.style.bezierSmoothingTension,
            closed: true
        )
        
        if let fillColor = configuration.style.fillColor {
            let fillLayer = CAShapeLayer()
            fillLayer.frame = CGRect(
                x: view.bounds.origin.x,
                y: view.bounds.origin.y + minBound * scale,
                width: view.bounds.size.width,
                height: view.bounds.size.height
            )
            fillLayer.bounds = view.bounds
            fillLayer.path = noFill.cgPath
            fillLayer.strokeColor = nil
            fillLayer.fillColor = fillColor.cgColor
            fillLayer.lineWidth = 0
            fillLayer.lineJoin = .round
            
            view.layer.addSublayer(fillLayer)
            layers.append(fillLayer)
            
            let animator = UIViewPropertyAnimator(duration: configuration.style.animationDuration, curve: .easeInOut) {
                fillLayer.path = fill.cgPath
            }
            animator.startAnimation()
        }
        
        let pathLayer = CAShapeLayer()
        pathLayer.frame = CGRect(
            x: view.bounds.origin.x,
            y: view.bounds.origin.y + minBound * scale,
            width: view.bounds.size.width,
            height: view.bounds.size.height
        )
        pathLayer.bounds = view.bounds
        pathLayer.path = noPath.cgPath
        pathLayer.strokeColor = configuration.style.lineColor.cgColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = configuration.style.lineWidth
        pathLayer.lineJoin = .round
        
        view.layer.addSublayer(pathLayer)
        layers.append(pathLayer)
        
        let animator = UIViewPropertyAnimator(duration: configuration.style.animationDuration, curve: .easeInOut) {
            pathLayer.path = path.cgPath
            pathLayer.strokeEnd = 1.0
        }
        animator.startAnimation()
    }
    
    @MainActor
    private func strokeDataPoints(configuration: ChartConfiguration, in view: FSLineChart) throws {
        let minBound = boundsCalculator.minVerticalBound
        let scale = verticalScale(configuration: configuration)
        
        for i in 0..<configuration.data.count {
            let p = try ChartUtilities.getPointForIndex(
                index: i,
                data: configuration.data,
                scale: scale,
                axisWidth: axisWidth,
                axisHeight: axisHeight,
                margin: configuration.style.margin
            )
            let adjustedPoint = CGPoint(x: p.x, y: p.y + minBound * scale)
            
            let circle = UIBezierPath(
                ovalIn: CGRect(
                    x: adjustedPoint.x - configuration.style.dataPointRadius,
                    y: adjustedPoint.y - configuration.style.dataPointRadius,
                    width: configuration.style.dataPointRadius * 2,
                    height: configuration.style.dataPointRadius * 2
                )
            )
            
            let fillLayer = CAShapeLayer()
            fillLayer.frame = CGRect(
                x: adjustedPoint.x,
                y: adjustedPoint.y,
                width: configuration.style.dataPointRadius,
                height: configuration.style.dataPointRadius
            )
            fillLayer.bounds = CGRect(
                x: adjustedPoint.x,
                y: adjustedPoint.y,
                width: configuration.style.dataPointRadius,
                height: configuration.style.dataPointRadius
            )
            fillLayer.path = circle.cgPath
            fillLayer.strokeColor = configuration.style.dataPointColor.cgColor
            fillLayer.fillColor = configuration.style.dataPointBackgroundColor.cgColor
            fillLayer.lineWidth = 1
            fillLayer.lineJoin = .round
            
            view.layer.addSublayer(fillLayer)
            layers.append(fillLayer)
        }
    }
    
    @MainActor
    private func createLabelForValue(index: Int, configuration: ChartConfiguration, labels: ChartLabels) -> UILabel? {
        let minBound = boundsCalculator.minVerticalBound
        let maxBound = boundsCalculator.maxVerticalBound
        
        let value = minBound + (maxBound - minBound) / CGFloat(configuration.style.gridSteps.vertical * (index + 1))
        let text = labels.valueLabel(value)
        
        let p = CGPoint(
            x: configuration.style.margin + (configuration.style.valueLabelPosition == .right ? axisWidth : 0),
            y: axisHeight + configuration.style.margin - CGFloat(index + 1) * axisHeight / CGFloat(configuration.style.gridSteps.vertical)
        )
        
        let rect = CGRect(
            x: configuration.style.margin,
            y: p.y + 2,
            width: axisWidth - configuration.style.margin * 2 - 4.0,
            height: 14
        )
        
        let width = (text as NSString).boundingRect(
            with: rect.size,
            options: [.usesLineFragmentOrigin],
            attributes: [.font: configuration.style.valueLabelFont],
            context: nil
        ).size.width
        
        let xPadding: CGFloat = 6
        var xOffset: CGFloat = width + xPadding
        if configuration.style.valueLabelPosition == .mirrored {
            xOffset = -xPadding
        }
        
        let label = UILabel(
            frame: CGRect(
                x: p.x - xOffset,
                y: p.y + 2,
                width: width + 2,
                height: 14
            )
        )
        label.text = text
        label.font = configuration.style.valueLabelFont
        label.textColor = configuration.style.valueLabelColor
        label.textAlignment = .center
        label.backgroundColor = configuration.style.valueLabelBackgroundColor
        
        return label
    }
    
    @MainActor
    private func createLabelForIndex(index: Int, configuration: ChartConfiguration, labels: ChartLabels) -> UILabel? {
        let scale = calculateHorizontalScale(data: configuration.data, horizontalGridStep: configuration.style.gridSteps.horizontal)
        let q = configuration.data.count / configuration.style.gridSteps.horizontal
        var itemIndex = q * index
        
        if itemIndex >= configuration.data.count {
            itemIndex = configuration.data.count - 1
        }
        
        let text = labels.indexLabel(itemIndex)
        
        let p = CGPoint(
            x: configuration.style.margin + CGFloat(index) * (axisWidth / CGFloat(configuration.style.gridSteps.horizontal)) * scale,
            y: axisHeight + configuration.style.margin
        )
        
        let rect = CGRect(
            x: configuration.style.margin,
            y: p.y + 2,
            width: axisWidth - configuration.style.margin * 2 - 4.0,
            height: 14
        )
        
        let width = (text as NSString).boundingRect(
            with: rect.size,
            options: [.usesLineFragmentOrigin],
            attributes: [.font: configuration.style.indexLabelFont],
            context: nil
        ).size.width
        
        let label = UILabel(
            frame: CGRect(
                x: p.x - 4.0,
                y: p.y + 2,
                width: width + 2,
                height: 14
            )
        )
        label.text = text
        label.font = configuration.style.indexLabelFont
        label.textColor = configuration.style.indexLabelColor
        label.backgroundColor = configuration.style.indexLabelBackgroundColor
        
        return label
    }
    
    private func verticalScale(configuration: ChartConfiguration) -> CGFloat {
        if let cached = cachedVerticalScale { return cached }
        let minBound = boundsCalculator.minVerticalBound
        let maxBound = boundsCalculator.maxVerticalBound
        
        let spread = maxBound - minBound
        let scale: CGFloat = spread != 0 ? axisHeight / spread : 0
        cachedVerticalScale = scale
        return scale
    }
}
