//
//  XAxisFormatter.swift
//  TLab
//
//  Created by rahul rachamalla on 3/21/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Foundation
import Charts

public class BarChartFormatter: NSObject, IAxisValueFormatter
{
    var week: [String]?
    //var week: [String]! = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    
    public func setWeek(receivedWeek: [String]) {
        week = receivedWeek
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String
    {
        let val = Int(floor(value))
        if (week != nil) {
            //print("WEEK IN FORMATTER \(week)")
        if val>=0 && val<week!.count {
            //print("val in formatter \(val)")
            //print("formatter class week int value \(week![Int(value)])")
            return week![val]
        }
        }
        return ""
    }
}
