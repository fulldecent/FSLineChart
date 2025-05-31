import UIKit

/// A line chart view for displaying data with customizable styling and labels.
@MainActor
open class FSLineChart: UIView {
    private var configuration: ChartConfiguration
    private let renderer = GridRenderer()
    private let layoutManager = LayoutManager()
    
    /// Initializes the chart with a frame.
    /// - Parameter frame: The frame for the chart view.
    public override init(frame: CGRect) {
        configuration = ChartConfiguration(
            data: [],
            labels: nil,
            style: ChartStyle.defaultStyle
        )
        super.init(frame: frame)
        commonInit()
    }
    
    /// Initializes the chart from a coder.
    /// - Parameter coder: The coder to initialize from.
    public required init?(coder: NSCoder) {
        configuration = ChartConfiguration(
            data: [],
            labels: nil,
            style: ChartStyle.defaultStyle
        )
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .white
        layoutManager.recalculateAxisSize(from: frame, margin: configuration.style.margin)
    }
    
    /// Lays out the chart’s subviews and updates the axis size.
    open override func layoutSubviews() {
        super.layoutSubviews()
        layoutManager.recalculateAxisSize(from: frame, margin: configuration.style.margin)
        try? layoutManager.layoutChart(configuration: configuration, in: self)
    }
    
    /// Draws the chart’s grid and axes.
    /// - Parameter rect: The rectangle to draw in.
    open override func draw(_ rect: CGRect) {
        try? renderer.render(configuration: configuration, layoutManager: layoutManager)
    }
    
    /// Sets the chart’s data and triggers a redraw.
    /// - Parameter chartData: The data to display.
    public func setChartData(_ chartData: [Double]) throws {
        configuration = ChartConfiguration(
            data: chartData,
            labels: configuration.labels,
            style: configuration.style
        )
        try layoutManager.layoutChart(configuration: configuration, in: self)
    }
    
    /// Applies a new style to the chart.
    /// - Parameter style: The style to apply.
    public func applyStyle(_ style: ChartStyle) {
        configuration = ChartConfiguration(
            data: configuration.data,
            labels: configuration.labels,
            style: style
        )
        try? layoutManager.layoutChart(configuration: configuration, in: self)
    }
    
    /// Sets the chart’s label providers.
    /// - Parameter labels: The label providers for index and value labels.
    public func setLabels(_ labels: ChartLabels?) {
        configuration = ChartConfiguration(
            data: configuration.data,
            labels: labels,
            style: configuration.style
        )
        try? layoutManager.layoutChart(configuration: configuration, in: self)
    }
}

/// Configuration for the chart, including data, labels, and style.
public struct ChartConfiguration {
    public let data: [Double]
    public let labels: ChartLabels?
    public let style: ChartStyle
    
    public init(data: [Double], labels: ChartLabels?, style: ChartStyle) {
        self.data = data
        self.labels = labels
        self.style = style
    }
}

/// Styling options for the chart’s appearance.
public struct ChartStyle {
    public let axisColor: UIColor
    public let axisLineWidth: CGFloat
    public let lineColor: UIColor
    public let fillColor: UIColor?
    public let lineWidth: CGFloat
    public let displayDataPoints: Bool
    public let dataPointColor: UIColor
    public let dataPointBackgroundColor: UIColor
    public let dataPointRadius: CGFloat
    public let drawInnerGrid: Bool
    public let innerGridColor: UIColor
    public let innerGridLineWidth: CGFloat
    public let gridSteps: (vertical: Int, horizontal: Int)
    public let margin: CGFloat
    public let bezierSmoothing: Bool
    public let bezierSmoothingTension: CGFloat
    public let animationDuration: TimeInterval
    public let indexLabelFont: UIFont
    public let indexLabelColor: UIColor
    public let indexLabelBackgroundColor: UIColor
    public let valueLabelFont: UIFont
    public let valueLabelColor: UIColor
    public let valueLabelBackgroundColor: UIColor
    public let valueLabelPosition: ValueLabelPosition
    
    public enum ValueLabelPosition {
        case left
        case right
        case mirrored
    }
    
    @MainActor
    public static let defaultStyle = ChartStyle(
        axisColor: UIColor(white: 0.7, alpha: 1.0),
        axisLineWidth: 1,
        lineColor: .fsLightBlue,
        fillColor: UIColor.fsLightBlue.withAlphaComponent(0.25),
        lineWidth: 1.0,
        displayDataPoints: false,
        dataPointColor: .fsLightBlue,
        dataPointBackgroundColor: .fsLightBlue,
        dataPointRadius: 1,
        drawInnerGrid: true,
        innerGridColor: UIColor(white: 0.9, alpha: 1.0),
        innerGridLineWidth: 0.5,
        gridSteps: (vertical: 3, horizontal: 3),
        margin: 20,
        bezierSmoothing: true,
        bezierSmoothingTension: 0.2,
        animationDuration: 0.5,
        indexLabelFont: .systemFont(ofSize: 10, weight: .light),
        indexLabelColor: .gray,
        indexLabelBackgroundColor: .clear,
        valueLabelFont: .systemFont(ofSize: 11, weight: .light),
        valueLabelColor: .gray,
        valueLabelBackgroundColor: UIColor(white: 1, alpha: 0.75),
        valueLabelPosition: .right
    )
    
    public init(
        axisColor: UIColor,
        axisLineWidth: CGFloat,
        lineColor: UIColor,
        fillColor: UIColor?,
        lineWidth: CGFloat,
        displayDataPoints: Bool,
        dataPointColor: UIColor,
        dataPointBackgroundColor: UIColor,
        dataPointRadius: CGFloat,
        drawInnerGrid: Bool,
        innerGridColor: UIColor,
        innerGridLineWidth: CGFloat,
        gridSteps: (vertical: Int, horizontal: Int),
        margin: CGFloat,
        bezierSmoothing: Bool,
        bezierSmoothingTension: CGFloat,
        animationDuration: TimeInterval,
        indexLabelFont: UIFont,
        indexLabelColor: UIColor,
        indexLabelBackgroundColor: UIColor,
        valueLabelFont: UIFont,
        valueLabelColor: UIColor,
        valueLabelBackgroundColor: UIColor,
        valueLabelPosition: ValueLabelPosition
    ) {
        self.axisColor = axisColor
        self.axisLineWidth = axisLineWidth
        self.lineColor = lineColor
        self.fillColor = fillColor
        self.lineWidth = lineWidth
        self.displayDataPoints = displayDataPoints
        self.dataPointColor = dataPointColor
        self.dataPointBackgroundColor = dataPointBackgroundColor
        self.dataPointRadius = dataPointRadius
        self.drawInnerGrid = drawInnerGrid
        self.innerGridColor = innerGridColor
        self.innerGridLineWidth = innerGridLineWidth
        self.gridSteps = gridSteps
        self.margin = margin
        self.bezierSmoothing = bezierSmoothing
        self.bezierSmoothingTension = bezierSmoothingTension
        self.animationDuration = animationDuration
        self.indexLabelFont = indexLabelFont
        self.indexLabelColor = indexLabelColor
        self.indexLabelBackgroundColor = indexLabelBackgroundColor
        self.valueLabelFont = valueLabelFont
        self.valueLabelColor = valueLabelColor
        self.valueLabelBackgroundColor = valueLabelBackgroundColor
        self.valueLabelPosition = valueLabelPosition
    }
}

/// Providers for chart index and value labels.
public struct ChartLabels {
    public let indexLabel: (Int) -> String
    public let valueLabel: (CGFloat) -> String
    
    public init(indexLabel: @escaping (Int) -> String, valueLabel: @escaping (CGFloat) -> String) {
        self.indexLabel = indexLabel
        self.valueLabel = valueLabel
    }
}
