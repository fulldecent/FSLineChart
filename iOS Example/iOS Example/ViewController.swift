//
//  ViewController.swift
//  iOS Example
//
//  Created by Yaroslav Zhurakovskiy on 20.11.2019.
//  Copyright © 2019 William Entriken. All rights reserved.
//

import UIKit
import FSLineChart

class ViewController: UIViewController {
    @IBOutlet weak var chartWithDates: FSLineChart!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadChartWithDates()
    }

    func loadChartWithDates() {
        // Generating some dummy data
        let chartData = (0..<7).map { Float($0) / 30.0 + Float(Int.random(in: 0...100)) / 500  }
        
        let months: [String] = ["January", "February", "March", "April", "May", "June", "July"]

        // Setting up the line chart
        chartWithDates.verticalGridStep = 6
        chartWithDates.horizontalGridStep = 3
        chartWithDates.fillColor = nil;
        chartWithDates.displayDataPoint = true
        chartWithDates.dataPointColor = .fsOrange
        chartWithDates.dataPointBackgroundColor = UIColor.fsOrange
        chartWithDates.dataPointRadius = 2
        chartWithDates.color = chartWithDates.dataPointColor.withAlphaComponent(0.3)
        chartWithDates.valueLabelPosition = .mirrored

        chartWithDates.labelForIndex =  { months[$0] }
        chartWithDates.labelForValue = { String(format: "%.02f €", $0) }

        chartWithDates.setChartData(chartData)
    }
}

