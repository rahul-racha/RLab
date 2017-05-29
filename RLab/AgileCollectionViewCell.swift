//
//  AgileCollectionViewCell.swift
//  TLab
//
//  Created by rahul rachamalla on 3/13/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class AgileCollectionViewCell: UICollectionViewCell {


    //@IBOutlet weak var agileCollectionViewCellOutlet: UIView!
    @IBOutlet weak var members: UILabel!
    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var update: UITextView!
    @IBOutlet weak var profAndProj: UILabel!
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //layoutIfNeeded()
        //agileCollectionViewCellOutlet.clipsToBounds = true
        //agileCollectionViewCellOutlet.layer.borderWidth = 1.8
        //agileCollectionViewCellOutlet.layer.borderColor = UIColor.lightGray.cgColor
    }

}
