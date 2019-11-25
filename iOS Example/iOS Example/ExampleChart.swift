//
//  ExampleChart.swift
//  FSLineChart
//
//  Created by Arthur GUIBERT on 01/11/2016.
//  Copyright © 2016 Arthur GUIBERT. All rights reserved.
//

import UIKit
import FSLineChart

class ExampleChart: FSLineChart {
    override func awakeFromNib() {
        load()
    }
    
    public func load() {
        // Generate some dummy data
        let data = (0...10).map { _ in Float(20 + (arc4random() % 100)) }
        
        verticalGridStep = 5
        horizontalGridStep = 9
        labelForIndex = { "\($0)" }
        labelForValue = { String(format: "$%.02f", $0) }
        setChartData(data)
    }
    
}
