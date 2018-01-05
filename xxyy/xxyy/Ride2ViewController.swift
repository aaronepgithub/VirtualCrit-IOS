//
//  ThirdViewController.swift
//  xxyy
//
//  Created by aaronep on 11/27/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var out_StackViewAll: UIStackView!
    
    
    @IBOutlet weak var out_Left: UILabel!
    @IBOutlet weak var out_Center: UILabel!
    @IBOutlet weak var out_Right: UILabel!
    @IBOutlet weak var out_Bottom: UILabel!
    @IBOutlet weak var lbl_top_StatusBar: UILabel!
    
    @objc func switchToDataTabCont(){
        //let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let newViewController = storyBoard.instantiateViewController(withIdentifier: "ID4")
        
        self.tabBarController?.selectedIndex = 3;
        
        
        //self.tabBarController?.present(newViewController, animated: true, completion: nil)
        //self.performSegue(withIdentifier: "SEG2", sender: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            print(currentPoint.x)
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
        }
    }
    
    var percentofmax: Double = 0.0
    @IBOutlet weak var lbl_hrLabel: UILabel!
    
    @objc func update1() {

        let mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        percentofmax = (Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)
        lbl_top_StatusBar.text = "MOV:\(rt.total_moving_time_string)   AVG:\(stringer1(myIn: mvspd))"
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let currTime = formatter.string(from: currentDateTime)
        
        out_Bottom.text = "\(rt.string_elapsed_time)  \(stringer1(myIn: rt.total_distance)) MILES  \(currTime)"
    }
    
    @objc func update2() {
        out_Center.text = "\(String(format:"%.0f", rt.rt_hr))"
        percentofmax = (Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)
        lbl_hrLabel.text = "HR: \(stringer0(myIn: percentofmax))% MAX"

    }
    @objc func update3() {
        out_Left.text = stringer1(myIn: rt.rt_speed)
    }

    @objc func update4() {
        out_Right.text = stringer0(myIn: rt.rt_cadence)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update1), name: Notification.Name("update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update2), name: Notification.Name("heartrate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update3), name: Notification.Name("speed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update4), name: Notification.Name("cadence"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
