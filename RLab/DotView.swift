//
//  DotView.swift
//  RLab
//
//  Created by rahul rachamalla on 2/22/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

enum StatusColor{
    case available
    case unavailable
    case recitation
    case selection
    case unknown
}

class DotView: UIView {

     override init(frame: CGRect)
     {
        super.init(frame: frame)
        constructFrame()
     }
     
     required init(coder aDecoder: NSCoder)
     {
        super.init(coder: aDecoder)!
        constructFrame()
     }
    
    // MARK: Helper methods
     func activeStatusColor(b: UIColor)
     {
        self.backgroundColor = b
     }
     
    func constructFrame()
    {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.white.cgColor
    }

}
