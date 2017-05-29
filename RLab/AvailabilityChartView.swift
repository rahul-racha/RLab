//
//  AvailabilityChartView.swift
//  TLab
//
//  Created by rahul rachamalla on 3/17/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Charts

class AvailabilityChartView: BarChartView {

    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        constructFrame()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        constructFrame()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func constructFrame()
    {
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.darkGray.cgColor
    }

}
