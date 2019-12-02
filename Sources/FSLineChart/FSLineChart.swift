//
//  LegacySupport.swift
//  FSLineChart
//
//  Created by Yaroslav Zhurakovskiy on 25.11.2019.
//  Copyright © 2019 William Entriken. All rights reserved.
//

import UIKit
import QuartzCore

open class FSLineChart: UIView {
    internal var data: [Double] = []
    
    private let renderer = GridRenderer()
    private let layoutManager = LayoutManager()
    
    // Block definition for getting a label for a set index (use case: date, units,...)
    public typealias LabelForIndexGetter = (Int) -> String
    // Same as above, but for the value (for adding a currency, or a unit symbol for example)
    public typealias LabelForValueGetter = (CGFloat) -> String

    public enum ValueLabelPosition {
        case left
        case right
        case mirrored
    }

    // Index label properties
    public var labelForIndex: LabelForIndexGetter?
    
    public var indexLabelFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 10)!
    public var indexLabelTextColor: UIColor = .gray
    public var indexLabelBackgroundColor: UIColor = .clear

    // Value label properties
    public var labelForValue: LabelForValueGetter?
    public var valueLabelFont: UIFont = UIFont(name: "HelveticaNeue-Light", size: 11)!
    public var valueLabelTextColor: UIColor = .gray
    public var valueLabelBackgroundColor: UIColor = UIColor(white: 1, alpha:0.75)
    public var valueLabelPosition: ValueLabelPosition = .right

    // Number of visible step in the chart
    public var verticalGridStep: Int = 3
    public var horizontalGridStep: Int = 3
    public func setGridStep(_ value: Int) {
        verticalGridStep = value
        horizontalGridStep = value
    }

    // Margin of the chart
    public var margin: CGFloat = 0.5

    // Decoration parameters, let you pick the color of the line as well as the color of the axis
    public var axisColor: UIColor = UIColor(white: 0.7, alpha: 1.0)
    public var axisLineWidth: CGFloat = 1

    // Chart parameters
    public var color: UIColor = .fsLightBlue
    public var fillColor: UIColor? = UIColor.fsLightBlue.withAlphaComponent(0.25)
    public var lineWidth: CGFloat = 1.0

    // Data points
    public var displayDataPoint: Bool = false
    public var dataPointColor: UIColor = .fsLightBlue
    public var dataPointBackgroundColor: UIColor = .fsLightBlue
    public var dataPointRadius: CGFloat = 1

    // Grid parameters
    public var drawInnerGrid: Bool = true
    public var innerGridColor: UIColor = UIColor(white: 0.9, alpha: 1.0)
    public var innerGridLineWidth: CGFloat = 0.5

    // Smoothing
    public var bezierSmoothing: Bool = true
    public var bezierSmoothingTension: CGFloat = 0.2

    // Animations
    public var animationDuration: TimeInterval = 0.5

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .white
        layoutManager.chart = self
        layoutManager.recalculateAxisSize(from: frame, margin: margin)
    }
    
    public override func layoutSubviews() {
        layoutManager.recalculateAxisSize(from: frame, margin: margin)
        layoutManager.layoutChart()
        super.layoutSubviews()
    }
    
    public override func draw(_ rect: CGRect) {
        renderer.render(chart: self, layoutManager: layoutManager)
    }

    public func setChartData(_ chartData: [Double]) {
        data = chartData
        layoutManager.layoutChart()
    }
}

public extension FSLineChart {
    var minVerticalBound: CGFloat {
        return layoutManager.minVerticalBound
    }

    var maxVerticalBound: CGFloat {
        return layoutManager.maxVerticalBound
    }
}
