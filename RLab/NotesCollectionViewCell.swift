//
//  NotesCollectionViewCell.swift
//  TLab
//
//  Created by rahul rachamalla on 5/7/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class NotesCollectionViewCell: UICollectionViewCell {

    //@IBOutlet weak var cellUIView: UIView!
    var id: Int?
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var delNote: UIButton!
    @IBOutlet weak var descriptionNote: UITextView!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
