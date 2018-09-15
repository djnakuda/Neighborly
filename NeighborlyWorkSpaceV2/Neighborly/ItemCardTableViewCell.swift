//
//  ItemCardTableViewCell.swift
//  Neighborly
//
//  Created by Other users on 4/11/18.
//  Copyright © 2018 Adam Liber. All rights reserved.
//

import UIKit

class ItemCardTableViewCell: UITableViewCell {

    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemStatusLabel: UILabel!
    @IBOutlet weak var itemDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 0.2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
