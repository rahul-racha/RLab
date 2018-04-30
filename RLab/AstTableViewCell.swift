//
//  AstTableViewCell.swift
//  TLab
//
//  Created by Rahul Racha on 1/28/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit

class AstTableViewCell: UITableViewCell {
    
    @IBOutlet weak var midasLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
