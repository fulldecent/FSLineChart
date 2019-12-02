//
//  FSLineChartTests.swift
//  FSLineChart
//
//  Created by Yaroslav Zhurakovskiy on 25.11.2019.
//  Copyright © 2019 William Entriken. All rights reserved.
//

import XCTest
@testable import FSLineChart

class FSLineChartTests: XCTestCase {
    func testInitialisation() {
        let chart = FSLineChart()
        XCTAssertNotNil(chart);
    }
      
    func testBoundsEmptyChart() {
        let chart = FSLineChart()
        chart.setChartData([])
    
        XCTAssertEqual(chart.minVerticalBound, 0)
        XCTAssertEqual(chart.maxVerticalBound, 0)
    }
    
    func testBoundsAllValuesToZero() {
        let chart = FSLineChart()
        chart.setChartData([0, 0, 0])
    
        XCTAssertEqual(chart.minVerticalBound, 0)
        XCTAssertEqual(chart.maxVerticalBound, 0)
    }
    
    func testBounds() {
        let chart = FSLineChart()
        chart.setChartData([0, 1, -1])
    
        XCTAssertEqual(chart.minVerticalBound, -3)
        XCTAssertEqual(chart.maxVerticalBound, 1.5)
    }
    
    func testPerformanceExample() {
        let chart = FSLineChart()
        let testData = (0..<1000).map { Double($0) }
        
        // Testing whether a 1000 values are processed between two frames (1/60th of a second)
        measure {
            chart.setChartData(testData);
        }
    }
    
    func testDataWithAllZeroesShouldNotCrash() {
        let chart = FSLineChart(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 320,
                height: 176
            )
        )
        chart.verticalGridStep = 5
        chart.horizontalGridStep = 9
        chart.labelForIndex =  { "\($0)" }
        chart.labelForValue = { String(format: "%.f", $0) }
        chart.setChartData((1...10).map  { _ in Double(0) })
        
        UIGraphicsBeginImageContext(chart.bounds.size)
        chart.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        XCTAssertNotNil(image)
    }
}
