//
//  ProfTableViewCell.swift
//  TLab
//
//  Created by rahul rachamalla on 5/19/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class ProfTableViewCell: UITableViewCell {

    @IBOutlet weak var professor: UILabel!
    var userid: Int?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setId(id: Int) {
        userid = id
    }
}
