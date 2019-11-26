//
//  BoundsCalculator.swift
//  FSLineChart
//
//  Created by Yaroslav Zhurakovskiy on 25.11.2019.
//  Copyright © 2019 William Entriken. All rights reserved.
//

import CoreGraphics
import Foundation

class BoundsCalculator {
    private(set) var min: Float = MAXFLOAT
    private(set) var max: Float = -MAXFLOAT
    
    func computeBounds(data: [Float], verticalGridStep: Int) {
        min = MAXFLOAT
        max = -MAXFLOAT

        for number in data {
           if number < min {
               min = number
           }

           if number > max {
               max = number
           }
        }

       // The idea is to adjust the minimun and the maximum value to display the whole chart in the view, and if possible with nice "round" steps.
        max = getUpperRoundNumber(max, forGridStep: verticalGridStep)

        if min < 0 {
           // If the minimum is negative then we want to have one of the step to be zero so that the chart is displayed nicely and more comprehensively
           var step: Float

           if verticalGridStep > 3 {
               step = abs(max - min) / Float(verticalGridStep - 1)
           } else {
               step = Swift.max(abs(max - min) / 2, Swift.max(abs(min), abs(max)))
           }

           step = getUpperRoundNumber(step, forGridStep: verticalGridStep)

           var newMin: Float
           var newMax: Float

           if abs(min) > abs(max) {
               let m = ceilf(abs(min) / step)

               newMin = step * Float(m) * (min > 0 ? 1 : -1)
               newMax = step * (Float(verticalGridStep) - m) * (max > 0 ? 1 : -1)
           } else {
               let m = ceilf(abs(max) / step)
               
               newMax = step * Float(m) * (max > 0 ? 1 : -1)
               newMin = step * (Float(verticalGridStep) - m) * (min > 0 ? 1 : -1)
           }

           if min < newMin {
               newMin -= step
               newMax -= step
           }

           if max > newMax + step {
               newMin += step
               newMax += step
           }

           min = newMin
           max = newMax

           if max < min {
               // TODO: use swap
               let tmp = max
               max = min
               min = tmp
           }
        }
        
        // No data
        if max.isNaN {
            max = 1
        }
   }
   
   func getUpperRoundNumber(
        _ value: Float,
        forGridStep gridStep: Int
   ) -> Float {
       guard value > 0 else {
           return 0
       }
       
       // We consider a round number the following by 0.5 step instead of true round number (with step of 1)
       let logValue = log10f(value);
       let scale = powf(10, floorf(logValue));
       var n = ceilf(value / scale * 4);
       
       let tmp = Int(n) % gridStep;
       
       if tmp != 0 {
           n += Float(gridStep - tmp)
       }
       
       return n * scale / 4.0
   }
}

extension BoundsCalculator {
    var minVerticalBound: CGFloat {
       return CGFloat(Swift.min(min, 0))
    }

    var maxVerticalBound: CGFloat {
       return CGFloat(Swift.max(max, 0))
    }
}
