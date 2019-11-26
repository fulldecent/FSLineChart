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
        let testData = (0..<1000).map { Float($0) }
        
        // Testing whether a 1000 values are processed between two frames (1/60th of a second)
        measure {
            chart.setChartData(testData);
        }
    }
}
