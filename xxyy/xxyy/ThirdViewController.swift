//
//  ThirdViewController.swift
//  xxyy
//
//  Created by aaronep on 11/27/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    
    @IBOutlet weak var out_Left: UILabel!
    @IBOutlet weak var out_Center: UILabel!
    @IBOutlet weak var out_Right: UILabel!
    @IBOutlet weak var out_Bottom: UILabel!
    

    
    @objc func update() {
        out_Left.text = "\(String(format:"%.1f", quick_avg.speed))"
        out_Right.text = "\(String(format:"%.0f", quick_avg.cadence))"
        out_Center.text = "\(String(format:"%.0f", rt.rt_hr))"
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let currTime = formatter.string(from: currentDateTime)
        
        if let rs = raw_speed_for_avg {
            if rs.isNaN == false {
                out_Bottom.text = "\(rt.string_elapsed_time)     \(String(format:"%.1f", rt.total_distance)) Miles     \(String(format:"%.1f", rs)) Mph     \(currTime)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("update"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
