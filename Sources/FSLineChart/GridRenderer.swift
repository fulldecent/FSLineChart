//
//  GridRenderer.swift
//  FSLineChart
//
//  Created by Yaroslav Zhurakovskiy on 25.11.2019.
//  Copyright © 2019 William Entriken. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class GridRenderer {
    // We pass FSLineChart now for temporarily refactoring reasons. Its better to use some struct.
    func render(
        chart options: FSLineChart,
        layoutManager: LineChartLayoutManager
    ) {
        guard options.data.count > 0 else {
            return
        }
        
        let ctx = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(ctx);
        ctx.setLineWidth(options.axisLineWidth);
        ctx.setStrokeColor(options.axisColor.cgColor)
      
      // draw coordinate axis
        ctx.move(to: CGPointMake(options.margin, options.margin))
        ctx.addLine(to: CGPointMake(options.margin, layoutManager.axisHeight + options.margin + 3))
        ctx.strokePath()
      
        let scale = layoutManager.calculateHorizontalScale(
            data: options.data,
            horizontalGridStep: options.horizontalGridStep
        )
        let minBound = layoutManager.minVerticalBound
        let maxBound = layoutManager.maxVerticalBound
      
        // draw grid
        if(options.drawInnerGrid) {
            for i in 0..<options.horizontalGridStep {
                ctx.setStrokeColor(options.innerGridColor.cgColor)
                ctx.setLineWidth(options.innerGridLineWidth)
              
              let point = CGPointMake(
                CGFloat(1 + i) * layoutManager.axisWidth / CGFloat(options.horizontalGridStep) * scale + options.margin,
                options.margin
              )
              
              ctx.move(to: point)
              ctx.addLine(to: CGPointMake(point.x, layoutManager.axisHeight + options.margin))
              ctx.strokePath()
              
            ctx.setStrokeColor(options.axisColor.cgColor)
              ctx.setLineWidth(options.axisLineWidth)
              ctx.move(to: CGPointMake(point.x - 0.5, layoutManager.axisHeight + options.margin))
              ctx.addLine(to: CGPointMake(point.x - 0.5, layoutManager.axisHeight + layoutManager.margin + 3))
              ctx.strokePath()
          }
          
          for i in 0..<options.verticalGridStep+1 {
              // If the value is zero then we display the horizontal axis
              let v = maxBound - (maxBound - minBound) / CGFloat(options.verticalGridStep * i)
              
              if (v == 0) {
                  ctx.setLineWidth(options.axisLineWidth)
                  ctx.setStrokeColor(options.axisColor.cgColor)
              } else {
                  ctx.setStrokeColor(options.innerGridColor.cgColor)
                  ctx.setLineWidth(options.innerGridLineWidth)
              }
              
              let point = CGPointMake(
                  options.margin,
                  CGFloat(i) * layoutManager.axisHeight / CGFloat(options.verticalGridStep) + options.margin
              )
              
              ctx.move(to: point)
              ctx.addLine(to: CGPointMake(layoutManager.axisWidth + options.margin, point.y))
              ctx.strokePath()
          }
      }
      
      UIGraphicsPopContext()
  }
}
