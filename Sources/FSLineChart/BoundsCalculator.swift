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
    private(set) var min: Double = Double.greatestFiniteMagnitude
    private(set) var max: Double = -Double.greatestFiniteMagnitude
    
    func computeBounds(data: [Double], verticalGridStep: Int) {
        min = Double.greatestFiniteMagnitude
        max = -Double.greatestFiniteMagnitude

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
           var step: Double

           if verticalGridStep > 3 {
               step = abs(max - min) / Double(verticalGridStep - 1)
           } else {
               step = Swift.max(abs(max - min) / 2, Swift.max(abs(min), abs(max)))
           }

           step = getUpperRoundNumber(step, forGridStep: verticalGridStep)

           var newMin: Double
           var newMax: Double

           if abs(min) > abs(max) {
               let m = ceil(abs(min) / step)

               newMin = step * Double(m) * (min > 0 ? 1 : -1)
               newMax = step * (Double(verticalGridStep) - m) * (max > 0 ? 1 : -1)
           } else {
               let m = ceil(abs(max) / step)
               
               newMax = step * Double(m) * (max > 0 ? 1 : -1)
               newMin = step * (Double(verticalGridStep) - m) * (min > 0 ? 1 : -1)
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
        _ value: Double,
        forGridStep gridStep: Int
   ) -> Double {
       guard value > 0 else {
           return 0
       }
       
       // We consider a round number the following by 0.5 step instead of true round number (with step of 1)
       let logValue = log10(value);
       let scale = pow(10, floor(logValue));
       var n = ceil(value / scale * 4);
       
       let tmp = Int(n) % gridStep;
       
       if tmp != 0 {
           n += Double(gridStep - tmp)
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
