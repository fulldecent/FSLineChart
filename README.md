FSLineChart
===========

A line chart library for iOS.

Screenshots
---
<img src="Screenshots/fslinechart.png" width="320px" />&nbsp;
<img src="Screenshots/fslinechart2.png" width="320px" />

Installing FSLineChart
---

Add this to your project using Swift Package Manager. In Xcode that is simply: File > Swift Packages > Add Package Dependency... and you're done. Alternative installations options are available for legacy projects.

How to use
---
FSLineChart is a subclass of UIView so it can be added as regular view. The block structure allows you to format the values displayed on the chart the way you want. Here is a simple swift example:

```swift
var data: [Int] = []
        
// Generate some dummy data
for _ in 0...10 {
    data.append(Int(20 + (arc4random() % 100)))
}

verticalGridStep = 5
horizontalGridStep = 9
labelForIndex = { "\($0)" }
labelForValue = { "$\($0)" }
setChartData(data)
```

You can also set several parameters. Some of the parameters including `color` and `fillColor` must be set before calling the `setChartData` method. All those properties are available:

```swift
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
```


Examples
---
You can clone the repo to see a simple example. I'm also using FSLineChart on [ChartLoot](https://github.com/ArthurGuibert/ChartLoot) if you want to see the integration in a bigger project.
