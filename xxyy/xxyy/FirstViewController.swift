//
//  FirstViewController.swift
//  xxyy
//
//  Created by aaronep on 10/25/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

//    @IBOutlet weak var lbl_Time: UILabel!
//    @IBOutlet weak var lbl_Speed: UILabel!
//    @IBOutlet weak var lbl_HR: UILabel!
//    @IBOutlet weak var lbl_Cadence: UILabel!
    
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Speed: UILabel!
    @IBOutlet weak var lbl_Cadence: UILabel!
    @IBOutlet weak var lbl_HR: UILabel!
    @IBOutlet weak var lbl_Distance: UILabel!
    
    @IBOutlet weak var lbl_Top_Info_Bar: UILabel!
    
    
    
    
    @objc func update() {
        
        //  causes too many zeros for display
//        lbl_Speed.text = "\(String(format:"%.2f", rt.rt_speed))"
//        lbl_Cadence.text = "\(String(format:"%.0f", rt.rt_cadence))"
        
//        lbl_Speed.text = "\(String(format:"%.1f", quick_avg.speed))"
        lbl_Speed.text = "\(stringer1(myIn: quick_avg.speed))"
//        lbl_Cadence.text = "\(String(format:"%.0f", quick_avg.cadence))"
        lbl_Cadence.text = "\(stringer0(myIn: quick_avg.cadence))"
//        lbl_HR.text = "\(String(format:"%.0f", rt.rt_hr))"
        lbl_HR.text = "\(stringer0(myIn: rt.rt_hr))"
//        lbl_Distance.text = "\(String(format:"%.2f", rt.total_distance))"
        lbl_Distance.text = "\(stringer2(myIn: rt.total_distance))"

        //lbl_Time.text = createTimeString(seconds: Int(rt.total_time))  //moving time from ble
        lbl_Time.text = rt.string_elapsed_time  //NS Date Time since launch
        
        let x = createTimeString(seconds: Int(quick_avg.lap_time))
        
        if let rs = raw_speed_for_avg {
            if let rd = raw_distance_for_avg {
                if rd.isNaN == false && rs.isNaN == false {
                    lbl_Top_Info_Bar.text = "\(stringer0(myIn: rd)) mi   \(stringer0(myIn: rs)) avg mph   \(x)"
                }
            }
        }

        
                
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("update"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

