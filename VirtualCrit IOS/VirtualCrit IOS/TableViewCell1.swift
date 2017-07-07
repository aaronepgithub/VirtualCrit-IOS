//
//  TableViewCell1.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 7/7/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class TableViewCell1: UITableViewCell {
    
    @IBOutlet weak var cellTitle1: UILabel!

    @IBOutlet weak var cellSubTitle1: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
