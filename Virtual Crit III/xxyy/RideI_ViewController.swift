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
    

    var swipeUpVal: Int = 1
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
    
    
    func update1a() {
        switch swipeValue {
        case 0:
            initialTextFields()
            footer.text = getFooter()
            B1.text = stringer0(myIn: rt.rt_hr)
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            L1.text = "HRT \(percentofmax)%"
            L3.text = "HRT \(percentofmax)%"
            
        case 1:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
            B1.text = stringer0(myIn: interval.hr)
            L1.text = "HRT 30i \(percentofmax)%"
            L3.text = "HRT 30i \(percentofmax)%"
            
        case 2:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            B1.text = stringer0(myIn: round.hr)
            L1.text = "HRT RND \(percentofmax)%"
            L3.text = "HRT RND \(percentofmax)%"
        default:
            print("Default update1")
        }
    }
    
    func update1b() {
        switch swipeValue {
        case 0:
            initialTextFields()
            footer.text = getFooter()
            B1.text = stringer0(myIn: rt.rt_cadence)
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            L1.text = "CAD"
            L3.text = "CAD"
            
        case 1:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
            B1.text = stringer0(myIn: interval.cadence)
            L1.text = "CAD 30i"
            L3.text = "CAD 30i"
            
        case 2:
            initialTextFields()
            footer.text = getFooter()
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            B1.text = stringer0(myIn: round.cadence)
            L1.text = "CAD RND \(round.inRoundTimer)"
            L3.text = "CAD RND \(round.inRoundTimer)"
        default:
            print("Default update1")
        }
    }
    
    @objc func update1() {
        //TIME
        let x = swipeUpVal
        if x == 2 {update1a()}
        if x == 3 {update1b()}
        if x == 1 {
        
            switch swipeValue {
            case 0:
                initialTextFields()
                footer.text = getFooter()
                B1.text = stringer1(myIn: rt.rt_speed)
                percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
                L1.text = "SPEED"
                L3.text = "SPEED"
                
            case 1:
                initialTextFields()
                footer.text = getFooter()
                percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
                B1.text = stringer1(myIn: interval.speed)
                L1.text = "SPD 30i"
                L3.text = "SPD 30i"
                
            case 2:
                initialTextFields()
                footer.text = getFooter()
                percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
                B1.text = stringer1(myIn: round.speed)
                L1.text = "SPD RND \(round.inRoundTimer)"
                L3.text = "SPD RND \(round.inRoundTimer)"
            default:
                print("Default update1")
            }
            
        }
    }  //end u1
    
    
    
    
    func update2a() {
        //HRT
        switch swipeValue {
        case 0:
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            B1.text = stringer0(myIn: rt.rt_hr)
            L3.text = "HRT \(percentofmax)%"
            L1.text = "HRT \(percentofmax)%"

        case 1:
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
            L1.text = "HRT 30i \(percentofmax)%"
            L3.text = "HRT 30i \(percentofmax)%"
            B1.text = stringer0(myIn: interval.hr)
            
        case 2:
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            L1.text = "HRT RND \(percentofmax)%"
            L3.text = "HRT RND \(percentofmax)%"
            B1.text = stringer0(myIn: round.hr)
            
        default:
            print("Default update hr")
        }
    }
    
    func update2b() {
        //CAD
        switch swipeValue {
        case 0:
            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
            B1.text = stringer0(myIn: rt.rt_cadence)
            L3.text = "CAD"
            L1.text = "CAD"
            
        case 1:
            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
            L1.text = "CAD 30i"
            L3.text = "CAD 30i"
            B1.text = stringer0(myIn: interval.cadence)
            
        case 2:
            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            L1.text = "CAD RND \(round.inRoundTimer)"
            L3.text = "CAD RND \(round.inRoundTimer)"
            B1.text = stringer0(myIn: round.cadence)
            
        default:
            print("Default update hr")
        }
    }
    
    @objc func update2() {
        //HR
        let x = swipeUpVal
        if x == 2 {update2a()}
        if x == 3 {update2b()}
        if x == 1 {
        switch swipeValue {
        case 0:
            _ = 1
            
        case 1:
             _ = 1
            
        case 2:
            _ = 1
            
        default:
            print("Default update hr")
        }
            
        }
    }
    
    
    
    func update3a() {
        switch swipeValue {
        case 0:
         _ = 1
        case 1:
         _ = 1
        case 2:
         _ = 1
        default:
            print("Default update")
        }
    }

    func update3b() {
        switch swipeValue {
        case 0:
            _ = 1
        case 1:
            _ = 1
        case 2:
            _ = 1
        default:
            print("Default update")
        }
    }

    
    
    @objc func update3() {
        //SPD
        let x = swipeUpVal
        if x == 2 {update3a()}
        if x == 3 {update3b()}
        if x == 1 {
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
        }}
    }
    
    
    func update4a() {
        switch swipeValue {
        case 0:
            _ = 1
        case 1:
            _ = 1
        case 2:
            _ = 1
        default:
            print("Default update")
        }
    }
    
    func update4b() {
        switch swipeValue {
        case 0:
            B1.text = stringer0(myIn: rt.rt_cadence)
            L1.text = "CAD"
            L3.text = "CAD"
        case 1:
            L3.text = "CAD 30i"
        case 2:
            L1.text = "CAD RND \(round.inRoundTimer)"
            L3.text = "CAD RND \(round.inRoundTimer)"
        default:
            print("Default update")
        }
    }
    
    
    @objc func update4() {
        //CAD
        let x = swipeUpVal
        if x == 2 {update4a()}
        if x == 3 {update4b()}
        if x == 1 {
        switch swipeValue {
        case 0:
            _ = 1
        case 1:
            _ = 1
        case 2:
            _ = 1
        default:
            print("Default update")
        }}
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
            //animateTextColor()
        } else {
            swipeValue = swipeValue + 1
            print("Swipe Value \(swipeValue)")
            //animateTextColor()
        }
    }
    
    
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
            if swipeUpVal == 3 {
                swipeUpVal = 1
            } else {
                swipeUpVal = swipeUpVal + 1
            }
        case 3:
            print("Case 3")
           
            
        default:
            print("DOWN")
            self.tabBarController?.selectedIndex = 2;
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
