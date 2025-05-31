import CoreGraphics
import UIKit

/// Renders the grid and axes for a chart.
class GridRenderer {
    /// Draws the chart’s grid and axes using the provided configuration.
    /// - Parameters:
    ///   - configuration: The chart’s configuration.
    ///   - layoutManager: The layout manager for axis dimensions.
    @MainActor
    func render(configuration: ChartConfiguration, layoutManager: LayoutManager) throws {
        guard !configuration.data.isEmpty else { return }
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        UIGraphicsPushContext(ctx)
        
        ctx.setLineWidth(configuration.style.axisLineWidth)
        ctx.setStrokeColor(configuration.style.axisColor.cgColor)
        
        // Draw coordinate axis
        ctx.move(to: CGPoint(x: configuration.style.margin, y: configuration.style.margin))
        ctx.addLine(to: CGPoint(x: configuration.style.margin, y: layoutManager.axisHeight + configuration.style.margin + 3))
        ctx.strokePath()
        
        let scale = layoutManager.calculateHorizontalScale(
            data: configuration.data,
            horizontalGridStep: configuration.style.gridSteps.horizontal
        )
        let minBound = layoutManager.minVerticalBound
        let maxBound = layoutManager.maxVerticalBound
        
        // Draw grid
        if configuration.style.drawInnerGrid {
            for i in 0..<configuration.style.gridSteps.horizontal {
                ctx.setStrokeColor(configuration.style.innerGridColor.cgColor)
                ctx.setLineWidth(configuration.style.innerGridLineWidth)
                
                let point = CGPoint(
                    x: CGFloat(1 + i) * layoutManager.axisWidth / CGFloat(configuration.style.gridSteps.horizontal) * scale + configuration.style.margin,
                    y: configuration.style.margin
                )
                
                ctx.move(to: point)
                ctx.addLine(to: CGPoint(x: point.x, y: layoutManager.axisHeight + configuration.style.margin))
                ctx.strokePath()
                
                ctx.setStrokeColor(configuration.style.axisColor.cgColor)
                ctx.setLineWidth(configuration.style.axisLineWidth)
                ctx.move(to: CGPoint(x: point.x - 0.5, y: layoutManager.axisHeight + configuration.style.margin))
                ctx.addLine(to: CGPoint(x: point.x - 0.5, y: layoutManager.axisHeight + configuration.style.margin + 3))
                ctx.strokePath()
            }
            
            for i in 0..<configuration.style.gridSteps.vertical + 1 {
                let v = maxBound - (maxBound - minBound) / CGFloat(configuration.style.gridSteps.vertical * i)
                
                if v == 0 {
                    ctx.setLineWidth(configuration.style.axisLineWidth)
                    ctx.setStrokeColor(configuration.style.axisColor.cgColor)
                } else {
                    ctx.setStrokeColor(configuration.style.innerGridColor.cgColor)
                    ctx.setLineWidth(configuration.style.innerGridLineWidth)
                }
                
                let point = CGPoint(
                    x: configuration.style.margin,
                    y: CGFloat(i) * layoutManager.axisHeight / CGFloat(configuration.style.gridSteps.vertical) + configuration.style.margin
                )
                
                ctx.move(to: point)
                ctx.addLine(to: CGPoint(x: layoutManager.axisWidth + configuration.style.margin, y: point.y))
                ctx.strokePath()
            }
        }
        
        UIGraphicsPopContext()
    }
}
