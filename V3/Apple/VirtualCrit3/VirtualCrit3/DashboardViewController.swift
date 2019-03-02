//
//  DashboardViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 3/1/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit

extension UIView {
    func rotate(degrees: CGFloat) {
        rotate(radians: CGFloat.pi * degrees / 180.0)
    }
    
    func rotate(radians: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}


class DashboardViewController: UIViewController {
    
    @IBOutlet weak var labelMPH: UILabel!
    @IBOutlet weak var labelPACE: UILabel!
    @IBOutlet weak var labelMILES: UILabel!
    
    
    @IBOutlet weak var valuePACE: UILabel!
    @IBOutlet weak var valueMPH: UILabel!
    @IBOutlet weak var valueMILES: UILabel!
    
    @IBOutlet weak var topLeft: UILabel!
    @IBOutlet weak var topRight: UILabel!
    @IBOutlet weak var bottomLeft: UILabel!
    @IBOutlet weak var bottomRight: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelMPH.rotate(degrees: 90)
        labelPACE.rotate(degrees: 90)
        labelMILES.rotate(degrees: 90)
        
    }
    

}
