//
//  RideX_ViewController.swift
//  xxyy
//
//  Created by aaronep on 1/7/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class RideX_ViewController: UIViewController {

    var swipeValue: Int = 0
    var totalSwipeValues: Int = 2 //3 with zero - 0, 1, 2
    
    //standard
    @IBOutlet weak var timeOfDay: UILabel!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var footer: UILabel!
    
    //labels
    @IBOutlet weak var midHZ: UILabel!
    @IBOutlet weak var leftHZ: UILabel!
    @IBOutlet weak var rightHZ: UILabel!
    
    @IBOutlet weak var midVERT: UILabel!
    @IBOutlet weak var topVERT: UILabel!
    @IBOutlet weak var btmVERT: UILabel!
    
    //values
    
    @IBOutlet weak var BIG_MIDDLE: UILabel!
    @IBOutlet weak var BIG_T_VERT: UILabel!
    @IBOutlet weak var BIG_B_VERT: UILabel!
    
    @IBOutlet weak var BIG_L_HZ: UILabel!
    @IBOutlet weak var BIG_R_HZ: UILabel!
    
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
        timeOfDay.text = getFormattedTime()
        
//        footer.text = getFooter()
//        //values
//        BIG_MIDDLE.text = stringer1(myIn: rt.rt_speed)
//        BIG_L_HZ.text = stringer0(myIn: rt.rt_hr)
//        BIG_R_HZ.text = stringer0(myIn: rt.rt_cadence)
//        BIG_T_VERT.text = stringer0(myIn: rt.rt_hr)
//        BIG_B_VERT.text = stringer0(myIn: rt.rt_cadence)
//        //labels
//        midHZ.text = "SPEED"
//        midVERT.text = "SPEED"
//        leftHZ.text = "HRT"
//        topVERT.text = "HRT"
//        rightHZ.text = "CAD"
//        btmVERT.text = "CAD"
    }
    
    
    @objc func update1() {
        //TIME
        
        switch swipeValue {
        case 0:
            initialTextFields()
            footer.text = getFooter()
            //values
            BIG_MIDDLE.text = stringer1(myIn: rt.rt_speed)
            BIG_L_HZ.text = stringer0(myIn: rt.rt_hr)
            BIG_R_HZ.text = stringer0(myIn: rt.rt_cadence)
            BIG_T_VERT.text = stringer0(myIn: rt.rt_hr)
            BIG_B_VERT.text = stringer0(myIn: rt.rt_cadence)
            //labels
            midHZ.text = "SPEED"
            midVERT.text = "SPEED"
            leftHZ.text = "HRT"
            topVERT.text = "HRT"
            rightHZ.text = "CAD"
            btmVERT.text = "CAD"
            
        case 1:
            initialTextFields()
            footer.text = getFooter()
            
            leftHZ.text = "HRT 30i"
            topVERT.text = "HRT 30i"
            BIG_L_HZ.text = stringer0(myIn: interval.hr)
            BIG_T_VERT.text = stringer0(myIn: interval.hr)
            
            BIG_MIDDLE.text = stringer1(myIn: interval.speed)
            midHZ.text = "SPD 30i"
            midVERT.text = "SPD 30i"
            
            BIG_R_HZ.text = stringer0(myIn: interval.cadence)
            BIG_B_VERT.text = stringer0(myIn: interval.cadence)
            rightHZ.text = "CAD 30i"
            btmVERT.text = "CAD 30i"
            
        case 2:
            //RND
            initialTextFields()
            footer.text = getFooter()
            
            leftHZ.text = "HRT RND"
            topVERT.text = "HRT RND"
            BIG_L_HZ.text = stringer0(myIn: round.hr)
            BIG_T_VERT.text = stringer0(myIn: round.hr)
            
            BIG_MIDDLE.text = stringer1(myIn: round.speed)
            midHZ.text = "SPD RND:  \(round.inRoundTimer)"
            midVERT.text = "SPD RND:  \(round.inRoundTimer)"
            
            BIG_R_HZ.text = stringer0(myIn: round.cadence)
            BIG_B_VERT.text = stringer0(myIn: round.cadence)
            rightHZ.text = "CAD RND"
            btmVERT.text = "CAD RND"
            
        default:
            print("Default update1")
        }
        
    }
    
    
    
    @objc func update2() {
        //HR
        //initialTextFields()
        switch swipeValue {
        case 0:
            BIG_L_HZ.text = stringer0(myIn: rt.rt_hr)
            BIG_T_VERT.text = stringer0(myIn: rt.rt_hr)
            leftHZ.text = "HRT"
            topVERT.text = "HRT"
            
        case 1:
            //HRT 30i
            leftHZ.text = "HRT 30i"
//            topVERT.text = "HRT 30i"
//            BIG_L_HZ.text = stringer0(myIn: interval.hr)
//            BIG_T_VERT.text = stringer0(myIn: interval.hr)
            
        case 2:
            //HRT RND
            leftHZ.text = "HRT RND"
            
        default:
            print("Default update hr")
        }
    }
    @objc func update3() {
        //SPD
        //initialTextFields()
        switch swipeValue {
        case 0:
            BIG_MIDDLE.text = stringer1(myIn: rt.rt_speed)
            midHZ.text = "SPEED"
            midVERT.text = "SPEED"
        case 1:
            midVERT.text = "SPD 30i"
            
        case 2:
            midHZ.text = "SPD RND:  \(round.inRoundTimer)"
            midVERT.text = "SPD RND:  \(round.inRoundTimer)"
            
        default:
            print("Default update")
        }
    }
    @objc func update4() {
        //CAD
        //initialTextFields()
        switch swipeValue {
        case 0:
            BIG_R_HZ.text = stringer0(myIn: rt.rt_cadence)
            BIG_B_VERT.text = stringer0(myIn: rt.rt_cadence)
            rightHZ.text = "CAD"
            btmVERT.text = "CAD"
            
        case 1:
            btmVERT.text = "CAD 30i"
        case 2:
            btmVERT.text = "CAD RND"
            
        default:
            print("Default update")
        }
    }
    
    @objc func switchToDataTabCont(){
        //self.tabBarController?.selectedIndex = 2;
    }
    
    func changeSwipeNumber() {
        if (swipeValue == totalSwipeValues) {
            swipeValue = 0
            print("Swipe Value \(swipeValue)")
        } else {
            swipeValue = swipeValue + 1
            print("Swipe Value \(swipeValue)")
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
}
