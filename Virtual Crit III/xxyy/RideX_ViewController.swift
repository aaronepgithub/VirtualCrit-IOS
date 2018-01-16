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
    var percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
    
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
            
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            
            //labels
            midHZ.text = "SPEED"
            midVERT.text = "SPEED"
            leftHZ.text = "HRT \(percentofmax)%"
            topVERT.text = "HRT \(percentofmax)%"
            rightHZ.text = "CAD"
            btmVERT.text = "CAD"
            
        case 1:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
            leftHZ.text = "HRT 30i \(percentofmax)%"
            topVERT.text = "HRT 30i \(percentofmax)%"
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
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            leftHZ.text = "HRT RND \(percentofmax)%"
            topVERT.text = "HRT RND \(percentofmax)%"
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
            leftHZ.text = "HRT \(percentofmax)%"
            topVERT.text = "HRT \(percentofmax)%"
            
        case 1:
            //HRT 30i
            leftHZ.text = "HRT 30i \(percentofmax)%"
//            topVERT.text = "HRT 30i \(percentofmax)%"
//            BIG_L_HZ.text = stringer0(myIn: interval.hr)
//            BIG_T_VERT.text = stringer0(myIn: interval.hr)
            
        case 2:
            //HRT RND
            leftHZ.text = "HRT RND \(percentofmax)%"
            
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
        //print("rt.rt_cadence - notify:  \(rt.rt_cadence)");
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
    
    func animateTextColor() {
        BIG_L_HZ.textColor = UIColor.red
        BIG_R_HZ.textColor = UIColor.red
        BIG_B_VERT.textColor = UIColor.red
        BIG_MIDDLE.textColor = UIColor.red
        BIG_T_VERT.textColor = UIColor.red
        rightHZ.textColor = UIColor.red
        leftHZ.textColor = UIColor.red
        midHZ.textColor = UIColor.red
        topVERT.textColor = UIColor.red
        midVERT.textColor = UIColor.red
        btmVERT.textColor = UIColor.red
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            self.BIG_L_HZ.textColor = UIColor.black
            self.BIG_R_HZ.textColor = UIColor.black
            self.BIG_B_VERT.textColor = UIColor.black
            self.BIG_MIDDLE.textColor = UIColor.black
            self.BIG_T_VERT.textColor = UIColor.black
            self.rightHZ.textColor = UIColor.black
            self.leftHZ.textColor = UIColor.black
            self.midHZ.textColor = UIColor.black
            self.topVERT.textColor = UIColor.black
            self.midVERT.textColor = UIColor.black
            self.btmVERT.textColor = UIColor.black
        }
    }
    
    @IBOutlet weak var BIGL_TRAILING: NSLayoutConstraint!
    @IBOutlet weak var BIGR_LEADING: NSLayoutConstraint!
    @IBOutlet weak var BIGL_TOP: NSLayoutConstraint!
    
    
    func changeSwipeNumber() {
        if (swipeValue == totalSwipeValues) {
            swipeValue = 0
            print("Swipe Value \(swipeValue)")
            //animateTextColor()
        } else {
            swipeValue = swipeValue + 1
            print("Swipe Value \(swipeValue)")
            //animateTextColor()
        }
    }
    
    //var downState: Int = 0
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        animateTextColor()
        switch swipe.direction.rawValue {
        case 2:
            print("Case 2 - LEFT")
            changeSwipeNumber()
        case 1:
            print("Case 1 - RIGHT")
            changeSwipeNumber()
        case 4:
            print("Case 4 UP")
            self.tabBarController?.selectedIndex = 2;
        case 3:
            print("Case 3")
        default:
            print("DOWN")
            //let x = downState
            self.tabBarController?.selectedIndex = 2;
//            if x == 0 {
//                BIG_MIDDLE.isHidden = false
//                midHZ.isHidden = false
//                BIGL_TRAILING.constant = -36
//                BIGR_LEADING.constant = -36
//                BIGL_TOP.constant = 90
//                downState = 1
//            }
//            if x == 1 {
//                BIG_MIDDLE.isHidden = true
//                midHZ.isHidden = true
//                BIGL_TRAILING.constant = 0
//                BIGR_LEADING.constant = 0
//                BIGL_TOP.constant = 45
//                //chg cad to score
//                downState = 2
//            }
//            if x == 2 {
//                BIG_MIDDLE.isHidden = true
//                midHZ.isHidden = true
//                BIGL_TRAILING.constant = 0
//                BIGR_LEADING.constant = 0
//                BIGL_TOP.constant = 45
//                //chg hr to sspeed
//                downState = 0
//            }


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
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(downSwipe)
        
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
