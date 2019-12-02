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
    @IBOutlet weak var chartWithZeroes: FSLineChart!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChartWithDates()
        setupChartWithZeroes()
        
        loadChartWithDates()
        loadChartWithZeroes()
    }

    private func loadChartWithDates() {
        let chartData = (0..<7).map { Float($0) / 30.0 + Float(Int.random(in: 0...100)) / 500  }
            
        chartWithDates.setChartData(chartData)
    }
    
    private func loadChartWithZeroes() {
        let chartData = (0..<10).map { _ in Float(0) }
        chartWithZeroes.setChartData(chartData)
    }
    
    private func setupChartWithDates() {
        chartWithDates.verticalGridStep = 6
        chartWithDates.horizontalGridStep = 3
        chartWithDates.fillColor = nil
        chartWithDates.displayDataPoint = true
        chartWithDates.dataPointColor = .fsOrange
        chartWithDates.dataPointBackgroundColor = UIColor.fsOrange
        chartWithDates.dataPointRadius = 2
        chartWithDates.color = chartWithDates.dataPointColor.withAlphaComponent(0.3)
        chartWithDates.valueLabelPosition = .mirrored

         let months = [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July"
        ]
        chartWithDates.labelForIndex =  { months[$0] }
        chartWithDates.labelForValue = { String(format: "%.02f €", $0) }
    }
    
    private func setupChartWithZeroes() {
        chartWithZeroes.verticalGridStep = 5
        chartWithZeroes.horizontalGridStep = 9
        chartWithZeroes.labelForIndex =  { "\($0)" }
        chartWithZeroes.labelForValue = { String(format: "%.f", $0) }
    }
}
