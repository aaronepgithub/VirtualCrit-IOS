//
//  RideII_ViewController.swift
//  xxyy
//
//  Created by aaronep on 1/8/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class RideII_ViewController: UIViewController {
    
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var footer: UILabel!
    
    @IBOutlet weak var L1: UILabel!
    @IBOutlet weak var L2: UILabel!
    
    @IBOutlet weak var L3: UILabel!
    @IBOutlet weak var L4: UILabel!
    
    @IBOutlet weak var B1: UILabel!
    @IBOutlet weak var B2: UILabel!
    
    
    var swipeUpVal: Int = 0
    var swipeValue: Int = 0
    var totalSwipeValues: Int = 2 //3 with zero - 0, 1, 2
    var percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
    
//    if swipeUpVal % 2 == 0 {
//    print("\(myInt) is even number")
//    } else {
//    print("\(myInt) is odd number")
//    }
    
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
    
    //TODO,USE UP TO GO FROM SP/CAD TO HR/MAX

    
    @objc func update1() {
        //TIME
        switch swipeValue {
        case 0:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            
            if swipeUpVal % 2 == 0 {
                //values
                B1.text = stringer1(myIn: rt.rt_speed)
                B2.text = stringer0(myIn: rt.rt_cadence)

                //labels
                L1.text = "SPEED"
                L3.text = "SPEED"
                L2.text = "CAD"
                L4.text = "CAD"
            
            } else {
                //values
                B1.text = stringer0(myIn: rt.rt_hr)
                B2.text = percentofmax

                //labels
                L1.text = "HR"
                L3.text = "HR"
                L2.text = "SCORE"
                L4.text = "SCORE"
            }

            
        case 1:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
            
            if swipeUpVal % 2 == 0 {
                B1.text = stringer1(myIn: interval.speed)
                L1.text = "SPD 30i"
                L3.text = "SPD 30i"
                L2.text = "CAD 30i"
                L4.text = "CAD 30i"
            } else {
                B1.text = stringer0(myIn: interval.hr)
                B2.text = percentofmax
                L1.text = "HR 30i"
                L3.text = "HR 30i"
                L2.text = "SCORE 30i"
                L4.text = "SCORE 30i"
            }


            
        case 2:
            //RND
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            
            if swipeUpVal % 2 == 0 {
                B1.text = stringer1(myIn: round.speed)
                B2.text = stringer0(myIn: round.cadence)
                L1.text = "SPD RND \(round.inRoundTimer)"
                L3.text = "SPD RND \(round.inRoundTimer)"
                L2.text = "CAD RND"
                L4.text = "CAD RND"
            } else {
                B1.text = stringer0(myIn: round.hr)
                B2.text = percentofmax
                L1.text = "HR RND \(round.inRoundTimer)"
                L3.text = "HR RND \(round.inRoundTimer)"
                L2.text = "SCORE RND"
                L4.text = "SCORE RND"
            }

            
        default:
            print("Default update1")
        }
        
    }
    
    
    
    @objc func update2() {
        //HR
        //initialTextFields()
        switch swipeValue {
            
            
        case 0:

            if swipeUpVal % 2 == 0 { _ = 1} else {
                percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
                //values
                B1.text = stringer0(myIn: rt.rt_hr)
                B2.text = percentofmax
                
                //labels
                L1.text = "HR"
                L3.text = "HR"
                L2.text = "SCORE"
                L4.text = "SCORE"
            }

            
        case 1:

            if swipeUpVal % 2 == 0 { _ = 1} else {
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
                //values
                B1.text = stringer0(myIn: interval.hr)
                B2.text = percentofmax
                
                //labels
                L1.text = "HR 30i"
                L3.text = "HR 30i"
                L2.text = "SCORE 30i"
                L4.text = "SCORE 30i"
            }
            
            
        case 2:

            if swipeUpVal % 2 == 0 { _ = 1} else {
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
                //values
                B1.text = stringer0(myIn: round.hr)
                B2.text = percentofmax
                
                //labels
                L1.text = "HR RND"
                L3.text = "HR RND"
                L2.text = "SCORE RND"
                L4.text = "SCORE RND"
            }
            
        default:
            print("Default update hr")
        }
    }
    @objc func update3() {
        //SPD
        //initialTextFields()
        
        if swipeUpVal % 2 == 0 {
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
        } else {
            _ = 1
        }
    }
    @objc func update4() {
        //CAD
        //initialTextFields()
        
        if swipeUpVal % 2 == 0 {
            switch swipeValue {
            case 0:
                B2.text = stringer0(myIn: rt.rt_cadence)
                L2.text = "CAD"
                L4.text = "CAD"
                //            BIG_R_HZ.text = stringer0(myIn: rt.rt_cadence)
                //            BIG_B_VERT.text = stringer0(myIn: rt.rt_cadence)
                //            rightHZ.text = "CAD"
                //            btmVERT.text = "CAD"
                _ = 1
                
            case 1:
                
                L2.text = "CAD 30i"
                L4.text = "CAD 30i"
                _ = 1
            case 2:
                L2.text = "CAD RND"
                L4.text = "CAD RND"
                _ = 1
                
            default:
                print("Default update")
            }
        } else {  _ = 1}

    }
    
    func animateTextColor() {
        L3.textColor = UIColor.red
        L1.textColor = UIColor.red
        L2.textColor = UIColor.red
        L2.textColor = UIColor.red
        B1.textColor = UIColor.red
        B2.textColor = UIColor.red
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            self.L3.textColor = UIColor.black
            self.L1.textColor = UIColor.black
            self.L2.textColor = UIColor.black
            self.L3.textColor = UIColor.black
            self.B1.textColor = UIColor.black
            self.B2.textColor = UIColor.black
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
            swipeUpVal = swipeUpVal + 1
        case 3:
            print("Case 4 Down")
            //swipeUpVal = swipeUpVal + 1
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
