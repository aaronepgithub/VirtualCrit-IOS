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
    
    @objc func switchToDataTabCont(){
        tabBarController!.selectedIndex = 1
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            print(currentPoint.x)
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
        }
    }
    
    @objc func update() {

        out_Left.text = stringer1(myIn: rt.rt_speed)
        out_Right.text = stringer0(myIn: rt.rt_cadence)
        out_Center.text = "\(String(format:"%.0f", rt.rt_hr))"
        
        let mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        let percentofmax = (Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)
        
        lbl_top_StatusBar.text = "\(rt.total_moving_time_string) mv \(stringer1(myIn: mvspd)) mph \(stringer0(myIn: percentofmax))% MAX"
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let currTime = formatter.string(from: currentDateTime)
        
        
        out_Bottom.text = "\(rt.string_elapsed_time)  \(stringer1(myIn: rt.total_distance)) Miles  \(currTime)"
        
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
