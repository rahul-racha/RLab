//
//  SectionTableViewCell.swift
//  TLab
//
//  Created by Rahul Racha on 4/6/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit

class SectionTableViewCell: UITableViewCell {

    @IBOutlet weak var crnLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var sectionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
