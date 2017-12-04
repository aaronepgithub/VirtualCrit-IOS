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
    @IBOutlet weak var lbl_top_StatusBar: UILabel!
    

    
    @objc func update() {
//        if quick_avg.speed.isNaN == false {
//            out_Left.text = "\(String(format:"%.1f", quick_avg.speed))"
//        }
        
        if arrSpeed.isNaN == false {
            out_Left.text = "\(stringer1(myIn: arrSpeed))"
        }
        
        if quick_avg.cadence.isNaN == false {
                    out_Right.text = "\(String(format:"%.0f", quick_avg.cadence))"
        }
        out_Center.text = "\(String(format:"%.0f", rt.rt_hr))"
        
//        lbl_top_StatusBar.text = "\(avg_seconds_count)  |  \(String(format:"%.1f", old_avg_speed)) prev mph"
        
        lbl_top_StatusBar.text = "\(arrDurationTotalString) mv \(stringer1(myIn: arrAverageMovingSpeed)) mph"
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let currTime = formatter.string(from: currentDateTime)
        
//        if let rs = raw_speed_for_avg {
//            if rs.isNaN == false {
//                out_Bottom.text = "\(rt.string_elapsed_time)     \(String(format:"%.1f", rt.total_distance)) Miles     \(String(format:"%.1f", rs)) Mph     \(currTime)"
//            }
//        }
        
        out_Bottom.text = "\(rt.string_elapsed_time)  \(stringer1(myIn: arrDistanceTotal)) Miles  \(currTime)"
        
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
