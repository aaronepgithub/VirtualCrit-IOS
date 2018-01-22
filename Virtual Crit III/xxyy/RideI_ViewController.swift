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
    
    @IBOutlet weak var out_H1: UIButton!
    @IBOutlet weak var out_H2: UIButton!
    @IBOutlet weak var out_H3: UIButton!
    
    @IBOutlet weak var out_V1: UIButton!
    @IBOutlet weak var out_V2: UIButton!
    @IBOutlet weak var out_V3: UIButton!
    
    
//BETTER EXAMPLE
    
    func setButtonAndLabel(l: UILabel, b: UIButton, first: String, second: String, third: String) {
        let string = first + second as NSString
            let result = NSMutableAttributedString(string: string as String)
        let attributesForFirstWord = [
            //NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 90),
            NSAttributedStringKey.foregroundColor : UIColor.white,
//            NSAttributedStringKey.backgroundColor : UIColor.gray
            NSAttributedStringKey.font:  UIFont(
                name: "Yanone Kaffeesatz",
                size: 90.0)!
        ]
//        let shadow = NSShadow()
//        shadow.shadowColor = UIColor.gray
//        shadow.shadowOffset = CGSize(width: 4, height: 4)
        let attributesForSecondWord = [
            //NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 20),
            NSAttributedStringKey.foregroundColor : UIColor.white,
//            NSAttributedStringKey.backgroundColor : UIColor.green,
//            NSAttributedStringKey.shadow : shadow,
            NSAttributedStringKey.font:  UIFont(
                name: "Yanone Kaffeesatz",
                size: 20.0)!
            ]

        /* Find the string "100000" in the whole string and set its attribute */
        result.setAttributes(attributesForFirstWord,
                             range: string.range(of: first))

        /* Do the same thing for the string "lbs" */
        result.setAttributes(attributesForSecondWord,
                             range: string.range(of: second))

        //return NSAttributedString(attributedString: result)
        b.setAttributedTitle(result, for: .normal)
        l.text = third
    }
    

    
    
    var btnV1_counter: Int = 0
    @IBAction func btn_V1(_ sender: UIButton) {
        
        //set based on counter value
        //if btnV1_counter == 1...
        
        let l = out_L1V
        let b = out_V1
        let first = "000"
        let second = " BPM"
        let third = "HRT \n BPM"
        setButtonAndLabel(l: l!, b: b!, first: first, second: second, third: third)
        
        btnV1_counter += 1
    }
    
    var btnV2_counter: Int = 0
    @IBAction func btn_V2(_ sender: UIButton) {
        
        let l = out_L2V
        let b = out_V2
        let first = "00.0"
        let second = " MPH"
        let third = "SPD \n MPH"
        setButtonAndLabel(l: l!, b: b!, first: first, second: second, third: third)
        btnV2_counter += 1
    }
    
    var btnV3_counter: Int = 0
    @IBAction func btn_V3(_ sender: UIButton) {
        
        let l = out_L3V
        let b = out_V3
        let first = "00"
        let second = " RPM"
        let third = "CAD \n RPM"
        setButtonAndLabel(l: l!, b: b!, first: first, second: second, third: third)
        btnV3_counter += 1
    }
    
    var btnH1_counter: Int = 0
    @IBAction func btn_H1(_ sender: UIButton) {
        let l = out_L1H
        let b = out_H1
        let first = "00"
        let second = " RPM"
        let third = "CAD \n RPM"
        setButtonAndLabel(l: l!, b: b!, first: first, second: second, third: third)
        btnH1_counter += 1
    }
    
    var btnH2_counter: Int = 0
    @IBAction func btn_H2(_ sender: UIButton) {
        let l = out_L2H
        let b = out_H2
        let first = "00"
        let second = " RPM"
        let third = "CAD \n RPM"
        setButtonAndLabel(l: l!, b: b!, first: first, second: second, third: third)
        btnH2_counter += 1
    }
    
    var btnH3_counter: Int = 0
    @IBAction func btn_H3(_ sender: UIButton) {
        let l = out_L3H
        let b = out_H3
        let first = "00"
        let second = " RPM"
        let third = "CAD \n RPM"
        setButtonAndLabel(l: l!, b: b!, first: first, second: second, third: third)
        btnH3_counter += 1
    }
    
    
    
    
    
    
    //just for view did load
    func setAttribButtonTitle(x: UIButton) {
        let myString1 = "00.0 MPH"
        let myMutableString = NSMutableAttributedString(
        string: myString1,
        attributes: [NSAttributedStringKey.font:
        UIFont(name: "Yanone Kaffeesatz", size: 20.0)!])
    
        myMutableString.addAttribute(
        NSAttributedStringKey.font,
        value: UIFont(
        name: "Yanone Kaffeesatz",
        size: 90.0)!,
        range: NSRange(
        location: 0,
        length: 4))
    
    myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location:0,length: 4))
        x.setAttributedTitle(myMutableString, for: .normal)
    myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location:4,length: 4))
        x.setAttributedTitle(myMutableString, for: .normal)
    
    }
    
    var HeadR_Counter = 0
    @IBAction func btn_HeadR(_ sender: UIButton) {
        let x = HeadR_Counter
        if x == 0 {
            out_V3.isHidden = true
            out_H3.isHidden = true
            HeadR_Counter = 1
        }
        if x == 1 {
            out_V2.isHidden = true
            out_H2.isHidden = true
            HeadR_Counter = 2
        }
        if x == 2 {
            out_V3.isHidden = false
            out_H3.isHidden = false
            out_V2.isHidden = false
            out_H2.isHidden = false
            HeadR_Counter = 0
        }
        
        

    }
    @IBAction func btnHeadL(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        
        
        
    }
    

    
//    self.dismiss(animated: true, completion: nil)

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
        //animateTextColor()
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
    
    
    @IBOutlet weak var out_L1V: UILabel!
    @IBOutlet weak var out_L2V: UILabel!
    @IBOutlet weak var out_L3V: UILabel!
    
    @IBOutlet weak var out_L1H: UILabel!
    @IBOutlet weak var out_L2H: UILabel!
    @IBOutlet weak var out_L3H: UILabel!
    
    
//    var buttons = [out_v1: UIButton, out_v2: UIButton, out_v3: UIButton, out_h1: UIButton, out_h2: UIButton, out_h3: UIButton]
//
//    var labels = [out_L1V: UILabel, out_L2V: UILabel, out_L3V: UILabel, out_L1H: UILabel, out_L2H: UILabel, out_L3H: UILabel]

    var buttons = [UIButton]()
    var labels = [UILabel]()
    var counters = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var x = out_V1
        buttons.append(out_V1)
        labels.append(out_L1V)
        counters.append(btnV1_counter)
        setAttribButtonTitle(x: x!)
        
        x = out_V2
        buttons.append(out_V2)
        labels.append(out_L2V)
        counters.append(btnV2_counter)
        setAttribButtonTitle(x: x!)
        
        x = out_V3
        buttons.append(out_V3)
        labels.append(out_L3V)
        counters.append(btnV3_counter)
        setAttribButtonTitle(x: x!)
        
        x = out_H1
        buttons.append(out_H1)
        labels.append(out_L1H)
        counters.append(btnH1_counter)
        setAttribButtonTitle(x: x!)
        
        x = out_H2
        buttons.append(out_H2)
        labels.append(out_L2H)
        counters.append(btnH2_counter)
        setAttribButtonTitle(x: x!)
        
        x = out_H3
        buttons.append(out_H3)
        labels.append(out_L3H)
        counters.append(btnH3_counter)
        setAttribButtonTitle(x: x!)
        
        self.view.bringSubview(toFront: out_L1V)
        self.view.bringSubview(toFront: out_L2V)
        self.view.bringSubview(toFront: out_L3V)
        
        self.view.bringSubview(toFront: out_L1H)
        self.view.bringSubview(toFront: out_L2H)
        self.view.bringSubview(toFront: out_L3H)
        
        dump(buttons)
        dump(labels)
        dump(counters)
        
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





//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
//        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(leftSwipe)
//
//        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
//        upSwipe.direction = UISwipeGestureRecognizerDirection.up
//        self.view.addGestureRecognizer(upSwipe)
//
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
//        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(rightSwipe)
//
//        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
//        downSwipe.direction = UISwipeGestureRecognizerDirection.down
//        self.view.addGestureRecognizer(downSwipe)

//        NotificationCenter.default.addObserver(self, selector: #selector(update1), name: Notification.Name("update"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(update2), name: Notification.Name("heartrate"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(update3), name: Notification.Name("speed"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(update4), name: Notification.Name("cadence"), object: nil)





//    func update1a() {
//        switch swipeValue {
//        case 0:
//            initialTextFields()
//            footer.text = getFooter()
//            B1.text = stringer0(myIn: rt.rt_hr)
//            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
//            L1.text = "HRT \(percentofmax)%"
//            L3.text = "HRT \(percentofmax)%"
//
//        case 1:
//            initialTextFields()
//            footer.text = getFooter()
//            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
//            B1.text = stringer0(myIn: interval.hr)
//            L1.text = "HRT 30i \(percentofmax)%"
//            L3.text = "HRT 30i \(percentofmax)%"
//
//        case 2:
//            initialTextFields()
//            footer.text = getFooter()
//            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
//            B1.text = stringer0(myIn: round.hr)
//            L1.text = "HRT RND \(percentofmax)%"
//            L3.text = "HRT RND \(percentofmax)%"
//        default:
//            print("Default update1")
//        }
//    }

//    func update1b() {
//        switch swipeValue {
//        case 0:
//            initialTextFields()
//            footer.text = getFooter()
//            B1.text = stringer0(myIn: rt.rt_cadence)
//            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
//            L1.text = "CAD"
//            L3.text = "CAD"
//
//        case 1:
//            initialTextFields()
//            footer.text = getFooter()
//            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
//            B1.text = stringer0(myIn: interval.cadence)
//            L1.text = "CAD 30i"
//            L3.text = "CAD 30i"
//
//        case 2:
//            initialTextFields()
//            footer.text = getFooter()
//            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
//            B1.text = stringer0(myIn: round.cadence)
//            L1.text = "CAD RND \(round.inRoundTimer)"
//            L3.text = "CAD RND \(round.inRoundTimer)"
//        default:
//            print("Default update1")
//        }
//    }

//    @objc func update1() {
//        //TIME
//        let x = swipeUpVal
//        if x == 2 {update1a()}
//        if x == 3 {update1b()}
//        if x == 1 {
//
//            switch swipeValue {
//            case 0:
//                initialTextFields()
//                footer.text = getFooter()
//                B1.text = stringer1(myIn: rt.rt_speed)
//                percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
//                L1.text = "SPEED"
//                L3.text = "SPEED"
//
//            case 1:
//                initialTextFields()
//                footer.text = getFooter()
//                percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
//                B1.text = stringer1(myIn: interval.speed)
//                L1.text = "SPD 30i"
//                L3.text = "SPD 30i"
//
//            case 2:
//                initialTextFields()
//                footer.text = getFooter()
//                percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
//                B1.text = stringer1(myIn: round.speed)
//                L1.text = "SPD RND \(round.inRoundTimer)"
//                L3.text = "SPD RND \(round.inRoundTimer)"
//            default:
//                print("Default update1")
//            }
//
//        }
//    }  //end u1
//
//


//    func update2a() {
//        //HRT
//        switch swipeValue {
//        case 0:
//            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
//            B1.text = stringer0(myIn: rt.rt_hr)
//            L3.text = "HRT \(percentofmax)%"
//            L1.text = "HRT \(percentofmax)%"
//
//        case 1:
//            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
//            L1.text = "HRT 30i \(percentofmax)%"
//            L3.text = "HRT 30i \(percentofmax)%"
//            B1.text = stringer0(myIn: interval.hr)
//
//        case 2:
//            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
//            L1.text = "HRT RND \(percentofmax)%"
//            L3.text = "HRT RND \(percentofmax)%"
//            B1.text = stringer0(myIn: round.hr)
//
//        default:
//            print("Default update hr")
//        }
//    }

//    func update2b() {
//        //CAD
//        switch swipeValue {
//        case 0:
//            percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
//            B1.text = stringer0(myIn: rt.rt_cadence)
//            L3.text = "CAD"
//            L1.text = "CAD"
//
//        case 1:
//            percentofmax = stringer0(myIn: Double((Double(interval.hr) / Double(settings_MAXHR)) * Double(100)))
//            L1.text = "CAD 30i"
//            L3.text = "CAD 30i"
//            B1.text = stringer0(myIn: interval.cadence)
//
//        case 2:
//            percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
//            L1.text = "CAD RND \(round.inRoundTimer)"
//            L3.text = "CAD RND \(round.inRoundTimer)"
//            B1.text = stringer0(myIn: round.cadence)
//
//        default:
//            print("Default update hr")
//        }
//    }

//    @objc func update2() {
//        //HR
//        let x = swipeUpVal
//        if x == 2 {update2a()}
//        if x == 3 {update2b()}
//        if x == 1 {
//        switch swipeValue {
//        case 0:
//            _ = 1
//
//        case 1:
//             _ = 1
//
//        case 2:
//            _ = 1
//
//        default:
//            print("Default update hr")
//        }
//
//        }
//    }



//    func update3a() {
//        switch swipeValue {
//        case 0:
//         _ = 1
//        case 1:
//         _ = 1
//        case 2:
//         _ = 1
//        default:
//            print("Default update")
//        }
//    }
//
//    func update3b() {
//        switch swipeValue {
//        case 0:
//            _ = 1
//        case 1:
//            _ = 1
//        case 2:
//            _ = 1
//        default:
//            print("Default update")
//        }
//    }



//    @objc func update3() {
//        //SPD
//        let x = swipeUpVal
//        if x == 2 {update3a()}
//        if x == 3 {update3b()}
//        if x == 1 {
//        switch swipeValue {
//        case 0:
//            B1.text = stringer1(myIn: rt.rt_speed)
//            L1.text = "SPEED"
//            L3.text = "SPEED"
//        case 1:
//            L3.text = "SPD 30i"
//        case 2:
//            L1.text = "SPD RND \(round.inRoundTimer)"
//            L3.text = "SPD RND \(round.inRoundTimer)"
//        default:
//            print("Default update")
//        }}
//    }


//    func update4a() {
//        switch swipeValue {
//        case 0:
//            _ = 1
//        case 1:
//            _ = 1
//        case 2:
//            _ = 1
//        default:
//            print("Default update")
//        }
//    }

//    func update4b() {
//        switch swipeValue {
//        case 0:
//            B1.text = stringer0(myIn: rt.rt_cadence)
//            L1.text = "CAD"
//            L3.text = "CAD"
//        case 1:
//            L3.text = "CAD 30i"
//        case 2:
//            L1.text = "CAD RND \(round.inRoundTimer)"
//            L3.text = "CAD RND \(round.inRoundTimer)"
//        default:
//            print("Default update")
//        }
//    }


//    @objc func update4() {
//        //CAD
//        let x = swipeUpVal
//        if x == 2 {update4a()}
//        if x == 3 {update4b()}
//        if x == 1 {
//        switch swipeValue {
//        case 0:
//            _ = 1
//        case 1:
//            _ = 1
//        case 2:
//            _ = 1
//        default:
//            print("Default update")
//        }}
//    }

//    func animateTextColor() {
//        L3.textColor = UIColor.red
//        L1.textColor = UIColor.red
//        B1.textColor = UIColor.red
//        let when = DispatchTime.now() + 2
//        DispatchQueue.main.asyncAfter(deadline: when){
//            self.L3.textColor = UIColor.black
//            self.L1.textColor = UIColor.black
//            self.B1.textColor = UIColor.black
//        }
//    }
