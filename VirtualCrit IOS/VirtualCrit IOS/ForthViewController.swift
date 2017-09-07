//
//  ForthViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 7/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

struct Pacer {
    static var target_distance: Double = 5  //5 miles
    static var target_duration: Double = 20  //20 min
    static var target_avg_speed: Double = 15 // 60 / 15 mph =  4 min per mile

    static var status: String = "On Pace"
    static var goal_time: String = "Goal"
    static var eta_time: String = "ETA"
}

class ForthViewController: UIViewController {
    
    
    @IBOutlet weak var lbl_label1: UILabel!
    @IBOutlet weak var lbl_label2: UILabel!
    @IBOutlet weak var lbl_label3: UILabel!
    
    func func_one_second() {
        
        //lbl_pacer_times.text = "Goal:  \(Pacer.goal_time)    ETA:  \(Pacer.eta_time)"

        lbl_label1.text = "\(Pacer.goal_time) Pacer Goal"
        lbl_label2.text = "\(Pacer.eta_time) ETA"
        lbl_label3.text = "\(Pacer.status)"
        
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //anotherSecondElapsed
        NotificationCenter.default.addObserver(self, selector: #selector(func_one_second), name: Notification.Name("anotherSecondElapsed"), object: nil)
        

        // Do any additional setup after loading the view.
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
