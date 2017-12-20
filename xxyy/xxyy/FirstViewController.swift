//
//  FirstViewController.swift
//  xxyy
//
//  Created by aaronep on 10/25/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    @IBOutlet weak var constraint_topInfoBar: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_stactViewMain: NSLayoutConstraint!
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let currentPoint = touch.location(in: view)
//            print(currentPoint.x)
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let currentPoint = touch.location(in: view)
//            print(currentPoint.x)
//        }
//    }
    
    @objc func switchToDataTabCont(){
        
        //Using constraint approach, both back to 40 on Portrait
//        constraint_topInfoBar.constant = 0
//        constraint_stactViewMain.constant = 0
        
        //opt 1
        //tabBarController!.selectedIndex = 2
        //opt2
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ID3")
        self.present(newViewController, animated: true, completion: nil)
        
        
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            print(currentPoint.x)
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
        }
    }

    
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Speed: UILabel!
    @IBOutlet weak var lbl_Cadence: UILabel!
    @IBOutlet weak var lbl_HR: UILabel!
    @IBOutlet weak var lbl_Distance: UILabel!
    
    @IBOutlet weak var lbl_Top_Info_Bar: UILabel!
    
    @IBOutlet weak var lbl_hrLabel: UILabel!
    @IBOutlet weak var lbl_cadLabel: UILabel!
    
    
    
    
    @objc func update() {

        
        lbl_Speed.text = "\(stringer1(myIn: rt.rt_speed))"
        lbl_Cadence.text = "\(stringer0(myIn: rt.rt_cadence))"
        
        lbl_Time.text = rt.string_elapsed_time  //NS Date Time since launch
        lbl_Distance.text = "\(stringer2(myIn: rt.total_distance))"
        lbl_HR.text = "\(stringer0(myIn: rt.rt_hr))"
        
        let mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        lbl_Top_Info_Bar.text = "\(stringer1(myIn: mvspd)) mph  \(rt.total_moving_time_string) mvg"
        
        let percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
        lbl_hrLabel.text = "HR: \(percentofmax)%"
        lbl_cadLabel.text = "CAD"

    }
    
    @objc func rotated() {
        
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
            //switchToDataTabCont()
//            constraint_topInfoBar.constant = 0
//            constraint_stactViewMain.constant = 0
        }
        
        if UIDevice.current.orientation.isPortrait {
            print("Portrait")
//            constraint_topInfoBar.constant = 40
//            constraint_stactViewMain.constant = 40
        }
            
//            if UIDevice.current.orientation.isFlat {
//                print("Flat")
//                return
//            }
//        } else {
//            print("Portrait")
//            constraint_topInfoBar.constant = 40
//            constraint_stactViewMain.constant = 40
            
        
        
//        if UIDevice.current.orientation.isFlat {
//            print("Flat")
//            constraint_topInfoBar.constant = 0
//            constraint_stactViewMain.constant = 0
//            lbl_hrLabel.text = ""
//            lbl_cadLabel.text = ""
//        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("update"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

