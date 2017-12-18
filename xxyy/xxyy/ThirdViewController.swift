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
        
        //opt 1
//        tabBarController!.selectedIndex = 1
        //opt 2
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ID1")
//        self.present(newViewController, animated: true, completion: nil)
        
        //opt 3 - another opt - for modal
        self.dismiss(animated: true, completion: nil)
        
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
    @objc func update() {

        out_Left.text = stringer1(myIn: rt.rt_speed)
        out_Right.text = stringer0(myIn: rt.rt_cadence)
        
        let mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        percentofmax = (Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)
        
        lbl_top_StatusBar.text = "\(rt.total_moving_time_string) mv \(stringer1(myIn: mvspd)) mph \(stringer0(myIn: percentofmax))% MAX"
        
        if UIDevice.current.orientation.isLandscape {
            print("3Landscape")
            out_Center.text = "\(String(format:"%.0f", rt.rt_hr))"
            lbl_hrLabel.text = "HR: \(stringer0(myIn: percentofmax))% MAX"
        }

//        if UIDevice.current.orientation.isPortrait {
//            print("3Portrait")
//            out_Center.text = ""
//            lbl_hrLabel.text = ""
//        }
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let currTime = formatter.string(from: currentDateTime)
        
        out_Bottom.text = "\(rt.string_elapsed_time)  \(stringer1(myIn: rt.total_distance)) Miles  \(currTime)"
    }
    
    @objc func rotated_3vc() {

        if UIDevice.current.orientation.isLandscape {
            print("3bLandscape")
            out_Center.text = "\(String(format:"%.0f", rt.rt_hr))"
            lbl_hrLabel.text = "HR: \(stringer0(myIn: percentofmax))% MAX"
        }
        
        if UIDevice.current.orientation.isPortrait {
            print("3bPortrait")
            out_Center.text = ""
            lbl_hrLabel.text = ""
        }

    }
    
//    private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscapeLeft
//    }
    
//    private func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.landscape
//    }
//
//    private func shouldAutorotate() -> Bool {
//        return true
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: Notification.Name("update"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated_3vc), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //let value = UIInterfaceOrientation.landscapeLeft.rawValue
        //UIDevice.current.setValue(value, forKey: "orientation")
    
        
        
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
