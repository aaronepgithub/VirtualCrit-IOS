//
//  TableViewCell.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 6/5/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellSubTitle: UILabel!

    @IBOutlet weak var cellTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
