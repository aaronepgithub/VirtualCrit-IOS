//
//  BLTE_TableViewCell.swift
//  xxyy
//
//  Created by aaronep on 11/20/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class BLTE_TableViewCell: UITableViewCell {
    


//    @IBOutlet weak var outlet_btn_SensorName: UIButton!
//    @IBOutlet weak var lbl_SensorStatus: UILabel!
    
    @IBOutlet weak var BLTE_CellTitle: UILabel!
    
    @IBOutlet weak var BLTE_CellSubTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
