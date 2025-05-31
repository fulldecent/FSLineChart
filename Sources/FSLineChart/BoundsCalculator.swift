import CoreGraphics
import Foundation

/// Calculates the minimum and maximum bounds for a chart's vertical axis, ensuring rounded steps for readability.
class BoundsCalculator {
    private(set) var min: Double = Double.greatestFiniteMagnitude
    private(set) var max: Double = -Double.greatestFiniteMagnitude
    
    /// Computes the bounds for the given dataset, adjusting for rounded steps and ensuring zero is included if negative values are present.
    /// - Parameters:
    ///   - data: The dataset to analyze.
    ///   - verticalGridStep: The number of vertical grid lines.
    func computeBounds(data: [Double], verticalGridStep: Int) throws {
        guard !data.isEmpty else {
            throw ChartError.emptyData
        }
        guard data.allSatisfy({ !$0.isNaN && !$0.isInfinite }) else {
            throw ChartError.invalidData
        }

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

        max = getUpperRoundNumber(max, forGridStep: verticalGridStep)

        if min < 0 {
            let step: Double
            if verticalGridStep > 3 {
                step = abs(max - min) / Double(verticalGridStep - 1)
            } else {
                step = Swift.max(abs(max - min) / 2, Swift.max(abs(min), abs(max)))
            }

            let roundedStep = getUpperRoundNumber(step, forGridStep: verticalGridStep)

            var newMin: Double
            var newMax: Double

            if abs(min) > abs(max) {
                let m = ceil(abs(min) / roundedStep)
                newMin = roundedStep * Double(m) * (min > 0 ? 1 : -1)
                newMax = roundedStep * (Double(verticalGridStep) - m) * (max > 0 ? 1 : -1)
            } else {
                let m = ceil(abs(max) / roundedStep)
                newMax = roundedStep * Double(m) * (max > 0 ? 1 : -1)
                newMin = roundedStep * (Double(verticalGridStep) - m) * (min > 0 ? 1 : -1)
            }

            if min < newMin {
                newMin -= roundedStep
                newMax -= roundedStep
            }

            if max > newMax + roundedStep {
                newMin += roundedStep
                newMax += roundedStep
            }

            min = newMin
            max = newMax

            if max < min {
                swap(&max, &min)
            }
        }
        
        if max.isNaN {
            max = 1
        }
    }
    
    /// Rounds a value to a number suitable for grid steps, using a 0.5 step increment.
    /// - Parameters:
    ///   - value: The value to round.
    ///   - gridStep: The number of grid steps.
    /// - Returns: The rounded value.
    func getUpperRoundNumber(_ value: Double, forGridStep gridStep: Int) -> Double {
        guard value > 0 else {
            return 0
        }
        
        let logValue = log10(value)
        let scale = pow(10, floor(logValue))
        var n = ceil(value / scale * 4)
        
        let tmp = Int(n) % gridStep
        if tmp != 0 {
            n += Double(gridStep - tmp)
        }
        
        return n * scale / 4.0
    }
}

extension BoundsCalculator {
    /// The minimum vertical bound, ensuring it’s at least zero.
    var minVerticalBound: CGFloat {
        return CGFloat(Swift.min(min, 0))
    }

    /// The maximum vertical bound, ensuring it’s at least zero.
    var maxVerticalBound: CGFloat {
        return CGFloat(Swift.max(max, 0))
    }
}

/// Errors related to chart data processing.
enum ChartError: Error {
    case emptyData
    case invalidData
    case invalidIndex
}
