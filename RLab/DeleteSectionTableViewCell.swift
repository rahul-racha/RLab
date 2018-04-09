//
//  DeleteSectionTableViewCell.swift
//  TLab
//
//  Created by Rahul Racha on 4/7/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit

class DeleteSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectBox: UIImageView!
    
    @IBOutlet weak var crnLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
