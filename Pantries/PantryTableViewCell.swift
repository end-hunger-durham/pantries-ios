//
//  PantryTableViewCell.swift
//  Pantries
//
//  Created by Josh Johnson on 6/9/18.
//  Copyright © 2018 End Hunger Durham. All rights reserved.
//

import UIKit

class PantryTableViewCell: UITableViewCell {

    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        mapImageView.layer.borderColor = UIColor.black.cgColor
        mapImageView.layer.borderWidth = 1.0
        mapImageView.layer.cornerRadius = mapImageView.bounds.height / 2.0
        mapImageView.clipsToBounds = true
        
        accessoryType = .disclosureIndicator
    }
    
}
