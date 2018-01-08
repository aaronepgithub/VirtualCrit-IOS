//
//  RideI_ViewController.swift
//  xxyy
//
//  Created by aaronep on 1/8/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class RideI_ViewController: UIViewController {


    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var footer: UILabel!
    
    @IBOutlet weak var L1: UILabel!
    @IBOutlet weak var L3: UILabel!
    @IBOutlet weak var B1: UILabel!
    
    var swipeUpVal: Int = 0
    var swipeValue: Int = 0
    var totalSwipeValues: Int = 2 //3 with zero - 0, 1, 2
    var percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
    
    
    //view did load, call this
    
    func getFooter() -> String {
        let mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        return "AVG \(stringer1(myIn: mvspd))  \(rt.total_moving_time_string) MOV"
    }
    
    func getFormattedTime() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: currentDateTime)
    }
    
    func initialTextFields() {
        header.text = "\(stringer2(myIn: rt.total_distance)) MILES   \(rt.string_elapsed_time)"
        //timeOfDay.text = getFormattedTime()
    }
    
    @objc func update1() {
        //TIME
        
        switch swipeValue {
        case 0:
            initialTextFields()
            footer.text = getFooter()
            //values
            B1.text = stringer1(myIn: rt.rt_speed)
//            BIG_L_HZ.text = stringer0(myIn: rt.rt_hr)
//            BIG_R_HZ.text = stringer0(myIn: rt.rt_cadence)
//            BIG_T_VERT.text = stringer0(myIn: rt.rt_hr)
//            BIG_B_VERT.text = stringer0(myIn: rt.rt_cadence)
            
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            
            //labels
            L1.text = "SPEED"
            L3.text = "SPEED"
//            leftHZ.text = "HRT \(percentofmax)%"
//            topVERT.text = "HRT \(percentofmax)%"
//            rightHZ.text = "CAD"
//            btmVERT.text = "CAD"
            
        case 1:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
//            leftHZ.text = "HRT 30i \(percentofmax)%"
//            topVERT.text = "HRT 30i \(percentofmax)%"
//            BIG_L_HZ.text = stringer0(myIn: interval.hr)
//            BIG_T_VERT.text = stringer0(myIn: interval.hr)
            
            
            B1.text = stringer1(myIn: interval.speed)
            L1.text = "SPD 30i"
            L3.text = "SPD 30i"
            
//            BIG_R_HZ.text = stringer0(myIn: interval.cadence)
//            BIG_B_VERT.text = stringer0(myIn: interval.cadence)
//            rightHZ.text = "CAD 30i"
//            btmVERT.text = "CAD 30i"
            
            
            
            
        case 2:
            //RND
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
//            leftHZ.text = "HRT RND \(percentofmax)%"
//            topVERT.text = "HRT RND \(percentofmax)%"
//            BIG_L_HZ.text = stringer0(myIn: round.hr)
//            BIG_T_VERT.text = stringer0(myIn: round.hr)
            
            
            
            B1.text = stringer1(myIn: round.speed)
            L1.text = "SPD RND \(round.inRoundTimer)"
            L3.text = "SPD RND \(round.inRoundTimer)"
            
//            BIG_R_HZ.text = stringer0(myIn: round.cadence)
//            BIG_B_VERT.text = stringer0(myIn: round.cadence)
//            rightHZ.text = "CAD RND"
//            btmVERT.text = "CAD RND"
            
        default:
            print("Default update1")
        }
        
    }
    
    
    
    @objc func update2() {
        //HR
        //initialTextFields()
        switch swipeValue {
        case 0:
//            BIG_L_HZ.text = stringer0(myIn: rt.rt_hr)
//            BIG_T_VERT.text = stringer0(myIn: rt.rt_hr)
//            leftHZ.text = "HRT \(percentofmax)%"
//            topVERT.text = "HRT \(percentofmax)%"
            _ = 1
            
        case 1:
            //HRT 30i
            //leftHZ.text = "HRT 30i \(percentofmax)%"
            //            topVERT.text = "HRT 30i \(percentofmax)%"
            //            BIG_L_HZ.text = stringer0(myIn: interval.hr)
            //            BIG_T_VERT.text = stringer0(myIn: interval.hr)
             _ = 1
            
        case 2:
            //HRT RND
            //leftHZ.text = "HRT RND \(percentofmax)%"
            _ = 1
            
        default:
            print("Default update hr")
        }
    }
    @objc func update3() {
        //SPD
        //initialTextFields()
        switch swipeValue {
        case 0:
            B1.text = stringer1(myIn: rt.rt_speed)
            L1.text = "SPEED"
            L3.text = "SPEED"
        case 1:
            L3.text = "SPD 30i"
            
        case 2:
            L1.text = "SPD RND \(round.inRoundTimer)"
            L3.text = "SPD RND \(round.inRoundTimer)"
            
        default:
            print("Default update")
        }
    }
    @objc func update4() {
        //CAD
        //initialTextFields()
        switch swipeValue {
        case 0:
//            BIG_R_HZ.text = stringer0(myIn: rt.rt_cadence)
//            BIG_B_VERT.text = stringer0(myIn: rt.rt_cadence)
//            rightHZ.text = "CAD"
//            btmVERT.text = "CAD"
            _ = 1
            
        case 1:
//            btmVERT.text = "CAD 30i"
                        _ = 1
        case 2:
//            btmVERT.text = "CAD RND"
                        _ = 1
            
        default:
            print("Default update")
        }
    }
    
    func animateTextColor() {
        L3.textColor = UIColor.red
        L1.textColor = UIColor.red
        B1.textColor = UIColor.red
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            self.L3.textColor = UIColor.black
            self.L1.textColor = UIColor.black
            self.B1.textColor = UIColor.black
        }
    }
    
    func changeSwipeNumber() {
        if (swipeValue == totalSwipeValues) {
            swipeValue = 0
            print("Swipe Value \(swipeValue)")
            animateTextColor()
        } else {
            swipeValue = swipeValue + 1
            print("Swipe Value \(swipeValue)")
            animateTextColor()
        }
    }
    
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 2:
            print("Case 2 - LEFT")
            changeSwipeNumber()
        case 1:
            print("Case 1 - RIGHT")
            changeSwipeNumber()
        case 4:
            print("Case 4 UP")
        default:
            print("default Gesture - not up, left, or right")
            break
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(upSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(update1), name: Notification.Name("update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update2), name: Notification.Name("heartrate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update3), name: Notification.Name("speed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update4), name: Notification.Name("cadence"), object: nil)
        
        
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
