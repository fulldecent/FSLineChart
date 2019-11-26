//
//  LayoutManager.swift
//  FSLineChart
//
//  Created by Yaroslav Zhurakovskiy on 25.11.2019.
//  Copyright © 2019 William Entriken. All rights reserved.
//

import CoreGraphics
import UIKit

class LineChartLayoutManager {
    private unowned var chart: FSLineChart!
    private var layers: [CALayer] = []
    private let boundsCalculator = BoundsCalculator()
    
    public private(set) var axisWidth: CGFloat = 0
    public private(set) var axisHeight: CGFloat = 0
        
    func layoutChart(_ chart: FSLineChart) {
        self.chart = chart
        
        // Removing the old label views as well as the chart layers.
        chart.subviews.forEach { $0.removeFromSuperview() }
        layers.forEach { $0.removeFromSuperlayer() }
        
        guard data.count > 0 else {
           return
        }
       
        boundsCalculator.computeBounds(
            data: data,
            verticalGridStep: verticalGridStep
        )
        
        strokeChart()

        if displayDataPoint {
           strokeDataPoints()
        }

        if labelForValue != nil {
            for i in 0..<verticalGridStep {
                if let label = createLabelForValue(i) {
                    chart.addSubview(label)
                }
           }
        }

        if labelForIndex != nil {
           for i in 0..<horizontalGridStep + 1 {
               if let label = createLabelForIndex(i) {
                chart.addSubview(label)
               }
           }
        }

        chart.setNeedsDisplay()
    }
    
    func recalculateAxisSize(from frame: CGRect, margin: CGFloat) {
        axisWidth = frame.size.width - 2 * margin
        axisHeight = frame.size.height - 2 * margin
    }
}

fileprivate extension LineChartLayoutManager {
    func strokeChart() {
        let minBound = self.minVerticalBound
        let scale = self.verticalScale
    
        let noPath = getLinePath(scale: 0, withSmoothing:bezierSmoothing, close:false)
        let path = getLinePath(scale: scale, withSmoothing:bezierSmoothing, close:false)
    
        let noFill = getLinePath(scale: 0, withSmoothing:bezierSmoothing, close:true)
        let fill = getLinePath(scale: scale, withSmoothing:bezierSmoothing, close:true)
    
        if let fillColor = fillColor {
            let fillLayer = CAShapeLayer()
            fillLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + minBound * scale, self.bounds.size.width, self.bounds.size.height)
            fillLayer.bounds = self.bounds;
            fillLayer.path = fill.cgPath
            fillLayer.strokeColor = nil;
            fillLayer.fillColor = fillColor.cgColor;
            fillLayer.lineWidth = 0;
            fillLayer.lineJoin = .round;
    
            chart.layer.addSublayer(fillLayer)
            layers.append(fillLayer)
            
            let fillAnimation = CABasicAnimation(keyPath: "path")
            fillAnimation.duration = animationDuration;
            fillAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            fillAnimation.fillMode = .forwards;
            fillAnimation.fromValue = noFill.cgPath;
            fillAnimation.toValue = fill.cgPath;
            fillLayer.add(fillAnimation, forKey:"path")
        }
    
        let pathLayer = CAShapeLayer()
        pathLayer.frame = CGRect(
            x: self.bounds.origin.x,
            y: self.bounds.origin.y + minBound * scale,
            width: self.bounds.size.width,
            height: self.bounds.size.height
        )
        pathLayer.bounds = self.bounds;
        pathLayer.path = path.cgPath
        pathLayer.strokeColor = color.cgColor
        pathLayer.fillColor = nil;
        pathLayer.lineWidth = lineWidth;
        pathLayer.lineJoin = .round;
    
        chart.layer.addSublayer(pathLayer)
        layers.append(pathLayer)
    
        if fillColor != nil {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.duration = animationDuration;
            pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pathAnimation.fromValue = noPath.cgPath
            pathAnimation.toValue = path.cgPath
            pathLayer.add(pathAnimation,forKey:"path")
        } else {
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = animationDuration;
            pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pathAnimation.fromValue = NSNumber(value: 0.0)
            pathAnimation.toValue = NSNumber(value: 1.0)
            pathLayer.add(pathAnimation, forKey:"path")
        }
    }
    
    func strokeDataPoints() {
        let minBound = minVerticalBound
        let scale = verticalScale
        
        for i in 0..<data.count {
            var p = self.getPointForIndex(i, withScale:scale)
            p.y +=  minBound * scale;
            
            let circle = UIBezierPath(
                ovalIn: CGRect(
                    x: p.x - dataPointRadius,
                    y: p.y - dataPointRadius,
                    width: dataPointRadius * 2,
                    height: dataPointRadius * 2
                )
            )
            
            let fillLayer = CAShapeLayer()
            fillLayer.frame = CGRectMake(p.x, p.y, dataPointRadius, dataPointRadius);
            fillLayer.bounds = CGRectMake(p.x, p.y, dataPointRadius, dataPointRadius);
            fillLayer.path = circle.cgPath;
            fillLayer.strokeColor = dataPointColor.cgColor;
            fillLayer.fillColor = dataPointBackgroundColor.cgColor;
            fillLayer.lineWidth = 1;
            fillLayer.lineJoin = .round;
            
            chart.layer.addSublayer(fillLayer)
            layers.append(fillLayer)
        }
    }
}

fileprivate extension LineChartLayoutManager {
    func getPointForIndex(_ idx: Int, withScale scale: CGFloat) -> CGPoint {
        guard idx >= 0 && idx < data.count else {
            return .zero
        }
        
        // Compute the point position in the view from the data with a set scale value
        let number = CGFloat(data[idx])
        
        if(data.count < 2) {
            return CGPointMake(margin, axisHeight + margin - number * scale);
        } else {
            return CGPointMake(
                margin + CGFloat(idx) * (axisWidth / CGFloat(data.count - 1)),
                axisHeight + margin - number * scale
            )
        }
    }
    
    func getLinePath(
        scale: CGFloat,
        withSmoothing smoothed: Bool,
        close closed: Bool
    ) -> UIBezierPath {
        let path = UIBezierPath()
        
        if(smoothed) {
            for i in 0..<data.count-1 {
                var controlPoint = Array(repeating: CGPoint.zero, count: 2)
                var p = getPointForIndex(i, withScale: scale)
                
                // Start the path drawing
                if i == 0 {
                    path.move(to: p)
                }
                                
                // First control point
                var nextPoint = getPointForIndex(i + 1, withScale:scale)
                var previousPoint = getPointForIndex(i - 1, withScale:scale)
                var m = CGPoint.zero;
                
                if(i > 0) {
                    m.x = (nextPoint.x - previousPoint.x) / 2;
                    m.y = (nextPoint.y - previousPoint.y) / 2;
                } else {
                    m.x = (nextPoint.x - p.x) / 2;
                    m.y = (nextPoint.y - p.y) / 2;
                }
                
                controlPoint[0].x = p.x + m.x * bezierSmoothingTension;
                controlPoint[0].y = p.y + m.y * bezierSmoothingTension;
                
                // Second control point
                nextPoint = getPointForIndex(i + 2, withScale:scale)
                previousPoint = getPointForIndex(i, withScale:scale)
                p = getPointForIndex(i + 1, withScale:scale)
                m = CGPoint.zero;
                
                if(i < data.count - 2) {
                    m.x = (nextPoint.x - previousPoint.x) / 2;
                    m.y = (nextPoint.y - previousPoint.y) / 2;
                } else {
                    m.x = (p.x - previousPoint.x) / 2;
                    m.y = (p.y - previousPoint.y) / 2;
                }
                
                controlPoint[1].x = p.x - m.x * bezierSmoothingTension;
                controlPoint[1].y = p.y - m.y * bezierSmoothingTension;
                
                path.addCurve(
                    to: p,
                    controlPoint1: controlPoint[0],
                    controlPoint2: controlPoint[1]
                )
            }
            
        } else {
            for i in 0..<data.count {
                if(i > 0) {
                    path.addLine(to: getPointForIndex(i, withScale: scale))
                } else {
                    path.move(to: getPointForIndex(i, withScale: scale))
                }
            }
        }
        
        if closed {
            // Closing the path for the fill drawing
            path.addLine(to: getPointForIndex(data.count - 1, withScale:scale))
            path.addLine(to: getPointForIndex(data.count - 1, withScale:0))
            path.addLine(to: getPointForIndex(0, withScale:0))
            path.addLine(to: getPointForIndex(0, withScale:scale))
        }
        
        return path
    }
}

extension LineChartLayoutManager {
    func calculateHorizontalScale(
        data: [Float],
        horizontalGridStep: Int
    ) -> CGFloat {
        var scale: CGFloat = 1.0
        let q = data.count / horizontalGridStep

        if data.count > 1 {
           scale = CGFloat(q * horizontalGridStep) / CGFloat(data.count - 1)
        }

        return scale
    }
    
    private var horizontalScale: CGFloat {
        return calculateHorizontalScale(
            data: data,
            horizontalGridStep: horizontalGridStep
        )
    }

    private var verticalScale: CGFloat {
        let minBound = self.minVerticalBound
        let maxBound = self.maxVerticalBound
        
        let spread = maxBound - minBound;
        var scale: CGFloat = 0
        
        if (spread != 0) {
            scale = axisHeight / spread
        }

        return scale
    }
}

fileprivate extension LineChartLayoutManager {
    private func createLabelForValue(_ index: Int) -> UILabel? {
        let minBound = self.minVerticalBound
        let maxBound = self.maxVerticalBound

        let p = CGPoint(
            x: margin + (valueLabelPosition == .right ? axisWidth : 0),
            y: axisHeight + margin - CGFloat(index + 1) * axisHeight / CGFloat(verticalGridStep)
        )

        let value = minBound + (maxBound - minBound) / CGFloat(verticalGridStep * (index + 1))
        guard let text = labelForValue?(value) else {
            return nil
        }

        let rect = CGRect(
            x: margin,
            y: p.y + 2,
            width: self.frame.size.width - margin * 2 - 4.0,
            height: 14
        )
        
         let width = (text as NSString).boundingRect(
            with: rect.size,
            options: [.usesLineFragmentOrigin],
            attributes: [.font: valueLabelFont],
            context: nil
        ).size.width


        let xPadding: CGFloat = 6
        var xOffset: CGFloat = width + xPadding;

        if valueLabelPosition == .mirrored {
            xOffset = -xPadding;
        }

        let label = UILabel(
            frame: CGRect(
                x: p.x - xOffset,
                y: p.y + 2,
                width: width + 2,
                height: 14
            )
        )
        label.text = text;
        label.font = valueLabelFont;
        label.textColor = valueLabelTextColor;
        label.textAlignment = .center;
        label.backgroundColor = valueLabelBackgroundColor;

        return label
    }

    private func createLabelForIndex(_ index: Int) -> UILabel? {
        let scale = self.horizontalScale
        let q = data.count / horizontalGridStep;
        var itemIndex = q * index;

        if itemIndex >= data.count {
            itemIndex = data.count - 1
        }

        guard let text = labelForIndex?(itemIndex) else {
            return nil
        }

        let p = CGPointMake(
            margin + CGFloat(index) * (axisWidth / CGFloat(horizontalGridStep)) * scale,
            axisHeight + margin
        )
            

        let rect = CGRect(
            x: margin,
            y: p.y + 2,
            width: self.frame.size.width - margin * 2 - 4.0,
            height: 14
        );

        let width = (text as NSString).boundingRect(
            with: rect.size,
            options: [.usesLineFragmentOrigin],
            attributes: [.font: indexLabelFont],
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
        label.text = text;
        label.font = indexLabelFont;
        label.textColor = indexLabelTextColor;
        label.backgroundColor = indexLabelBackgroundColor;

        return label
    }
}

// It's done for refactoring purposes
extension LineChartLayoutManager {
    var data: [Float] {
        return chart.data
    }
    
    var dataPointBackgroundColor: UIColor {
        return chart.dataPointBackgroundColor
    }
    
    var verticalGridStep: Int {
        return chart.verticalGridStep
    }
    
    var bezierSmoothingTension: CGFloat {
        return chart.bezierSmoothingTension
    }
    
    var displayDataPoint: Bool {
        return chart.displayDataPoint
    }
    
    var labelForValue: FSLineChart.LabelForValueGetter? {
        return chart.labelForValue
    }
    
    var labelForIndex: FSLineChart.LabelForIndexGetter? {
        return chart.labelForIndex
    }
    
    var horizontalGridStep: Int {
        return chart.horizontalGridStep
    }
    
    var valueLabelPosition: FSLineChart.ValueLabelPosition {
        return chart.valueLabelPosition
    }
    
    var minVerticalBound: CGFloat {
        return boundsCalculator.minVerticalBound
    }
    
    var maxVerticalBound: CGFloat {
        return boundsCalculator.maxVerticalBound
    }
    
    var margin: CGFloat {
        return chart.margin
    }
    
    var color: UIColor {
        return chart.color
    }
    
    var lineWidth: CGFloat {
        return chart.lineWidth
    }
    
    var frame: CGRect {
        return chart.frame
    }
    
    var bounds: CGRect {
        return chart.bounds
    }
    
    var fillColor: UIColor? {
        return chart.fillColor
    }
    
    var valueLabelFont: UIFont {
        return chart.valueLabelFont
    }
    
    var valueLabelTextColor: UIColor {
        return chart.valueLabelTextColor
    }
    
    var valueLabelBackgroundColor: UIColor {
        return chart.valueLabelBackgroundColor
    }
    
    var indexLabelFont: UIFont {
        return chart.indexLabelFont
    }
    
    var dataPointRadius: CGFloat {
        return chart.dataPointRadius
    }
    
    var indexLabelTextColor: UIColor {
        return chart.indexLabelTextColor
    }
    
    var dataPointColor: UIColor {
        return chart.dataPointColor
    }
    
    var bezierSmoothing: Bool {
        return chart.bezierSmoothing
    }
    
    var indexLabelBackgroundColor: UIColor {
        return chart.indexLabelBackgroundColor
    }
    
    var animationDuration: TimeInterval {
        return chart.animationDuration
    }
}
