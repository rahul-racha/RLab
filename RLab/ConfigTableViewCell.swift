//
//  ConfigTableViewCell.swift
//  TLab
//
//  Created by Rahul Racha on 2/13/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit

class ConfigTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var midasLabelField: UILabel!
    @IBOutlet weak var btnCheckmark: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
