import CoreGraphics
import UIKit

/// Utility functions for chart calculations, designed for testability and reusability.
struct ChartUtilities {
    /// Calculates the horizontal scale for a chart based on data and grid steps.
    /// - Parameters:
    ///   - data: The dataset to scale.
    ///   - horizontalGridStep: The number of horizontal grid lines.
    /// - Returns: The calculated scale factor.
    static func calculateHorizontalScale(data: [Double], horizontalGridStep: Int) -> CGFloat {
        var scale: CGFloat = 1.0
        let q = data.count / horizontalGridStep
        if data.count > 1 {
            scale = CGFloat(q * horizontalGridStep) / CGFloat(data.count - 1)
        }
        return scale
    }
    
    /// Computes the point position for a data index in the chart.
    /// - Parameters:
    ///   - index: The index of the data point.
    ///   - data: The dataset.
    ///   - scale: The vertical scale factor.
    ///   - axisWidth: The width of the chart’s axis.
    ///   - axisHeight: The height of the chart’s axis.
    ///   - margin: The chart’s margin.
    /// - Returns: The computed point.
    static func getPointForIndex(
        index: Int,
        data: [Double],
        scale: CGFloat,
        axisWidth: CGFloat,
        axisHeight: CGFloat,
        margin: CGFloat
    ) throws -> CGPoint {
        guard index >= 0 && index < data.count else {
            return .zero
        }
        
        let number = CGFloat(data[index])
        if data.count < 2 {
            return CGPoint(x: margin, y: axisHeight + margin - number * scale)
        } else {
            return CGPoint(
                x: margin + CGFloat(index) * (axisWidth / CGFloat(data.count - 1)),
                y: axisHeight + margin - number * scale
            )
        }
    }
    
    /// Generates a path for the chart’s line or fill area.
    /// - Parameters:
    ///   - data: The dataset.
    ///   - scale: The vertical scale factor.
    ///   - axisWidth: The width of the chart’s axis.
    ///   - axisHeight: The height of the chart’s axis.
    ///   - margin: The chart’s margin.
    ///   - smoothed: Whether to apply Bezier smoothing.
    ///   - smoothingTension: The tension for Bezier smoothing.
    ///   - closed: Whether to close the path for filling.
    /// - Returns: The computed path.
    static func getLinePath(
        data: [Double],
        scale: CGFloat,
        axisWidth: CGFloat,
        axisHeight: CGFloat,
        margin: CGFloat,
        smoothed: Bool,
        smoothingTension: CGFloat,
        closed: Bool
    ) throws -> UIBezierPath {
        let path = UIBezierPath()
        
        if smoothed {
            for i in 0..<data.count-1 {
                var controlPoint = [CGPoint.zero, CGPoint.zero]
                let p = try getPointForIndex(
                    index: i,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                )
                
                if i == 0 {
                    path.move(to: p)
                }
                
                let nextPoint = try getPointForIndex(
                    index: i + 1,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                )
                let previousPoint = i > 0 ? try getPointForIndex(
                    index: i - 1,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                ) : p
                
                var m = CGPoint.zero
                if i > 0 {
                    m.x = (nextPoint.x - previousPoint.x) / 2
                    m.y = (nextPoint.y - previousPoint.y) / 2
                } else {
                    m.x = (nextPoint.x - p.x) / 2
                    m.y = (nextPoint.y - p.y) / 2
                }
                
                controlPoint[0].x = p.x + m.x * smoothingTension
                controlPoint[0].y = p.y + m.y * smoothingTension
                
                let nextIndex = i < data.count - 2 ? i + 2 : i + 1
                let nextPoint2 = try getPointForIndex(
                    index: nextIndex,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                )
                let previousPoint2 = try getPointForIndex(
                    index: i,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                )
                let p2 = try getPointForIndex(
                    index: i + 1,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                )
                
                m = CGPoint.zero
                if i < data.count - 2 {
                    m.x = (nextPoint2.x - previousPoint2.x) / 2
                    m.y = (nextPoint2.y - previousPoint2.y) / 2
                } else {
                    m.x = (p2.x - previousPoint2.x) / 2
                    m.y = (p2.y - previousPoint2.y) / 2
                }
                
                controlPoint[1].x = p2.x - m.x * smoothingTension
                controlPoint[1].y = p2.y - m.y * smoothingTension
                
                path.addCurve(to: p2, controlPoint1: controlPoint[0], controlPoint2: controlPoint[1])
            }
        } else {
            for i in 0..<data.count {
                let point = try getPointForIndex(
                    index: i,
                    data: data,
                    scale: scale,
                    axisWidth: axisWidth,
                    axisHeight: axisHeight,
                    margin: margin
                )
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
        }
        
        if closed {
            let lastPoint = try getPointForIndex(
                index: data.count - 1,
                data: data,
                scale: scale,
                axisWidth: axisWidth,
                axisHeight: axisHeight,
                margin: margin
            )
            path.addLine(to: lastPoint)
            path.addLine(to: try getPointForIndex(
                index: data.count - 1,
                data: data,
                scale: 0,
                axisWidth: axisWidth,
                axisHeight: axisHeight,
                margin: margin
            ))
            path.addLine(to: try getPointForIndex(
                index: 0,
                data: data,
                scale: 0,
                axisWidth: axisWidth,
                axisHeight: axisHeight,
                margin: margin
            ))
            path.addLine(to: try getPointForIndex(
                index: 0,
                data: data,
                scale: scale,
                axisWidth: axisWidth,
                axisHeight: axisHeight,
                margin: margin
            ))
        }
        
        return path
    }
}
