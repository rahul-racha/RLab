//
//  TableViewCell.swift
//  RLab
//
//  Created by rahul rachamalla on 2/22/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var projects: UILabel!

    @IBOutlet weak var dotView: DotView!
    @IBOutlet weak var availabilityChartView: AvailabilityChartView!
    @IBOutlet weak var weekHours: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //biggest change to swift 3...
        layoutIfNeeded()
        profileImage.layer.cornerRadius = profileImage.frame.size.width/3
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 3.0
        profileImage.layer.borderColor = UIColor.darkGray.cgColor
        profileImage.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {                             
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func studentActivityStatus(status: StatusColor)
    {
        if (status == StatusColor.available)
        {
            //print (Manager.color)
//            if (Manager.color == "out") {
//                self.dotView.activeStatusColor(b: UIColor.orange)
//
//            } else {
                self.dotView.activeStatusColor(b: UIColor.green)
            //}
        } else if (status == StatusColor.recitation) {
            self.dotView.activeStatusColor(b: UIColor.orange)
            
        } else if (status == StatusColor.unavailable)
        {
            self.dotView.activeStatusColor(b: UIColor.red)
        } else if (status == StatusColor.selection) {
            self.dotView.activeStatusColor(b: UIColor.white)
        } else
        {
            self.dotView.activeStatusColor(b: UIColor.gray)
        }
    }
    
}
