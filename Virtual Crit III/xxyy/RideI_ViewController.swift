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
    
    func getFooter() -> String {
        
        // if ble dist/spd is 0, try for geo
        
        var mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        var mvtime = rt.total_moving_time_string
        
        if rt.total_distance == 0 && geo.total_distance > 0 {
            mvspd = geo.total_distance / (geo.total_moving_time_seconds / 60 / 60)
            mvtime = geo.total_moving_time_string
            
        }
        
        return "AVG \(stringer1(myIn: mvspd))  \(mvtime) MOV"
        
    }
    
    func getFormattedTime() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: currentDateTime)
    }
    
    func getHeader() {
        footer.text = getFooter()
        //timeOfDay.text = getFormattedTime()
        if rt.total_distance > 0 {
            header.text = "\(stringer2(myIn: rt.total_distance)) MILES   \(rt.string_elapsed_time)"
        } else {
            header.text = "\(stringer2(myIn: geo.total_distance)) GEO MILES   \(rt.string_elapsed_time)"
        }
        if rt.total_distance > 0 && geo.total_distance > 0 {
            header.text = "\(stringer1(myIn: rt.total_distance)) (\(stringer1(myIn: geo.total_distance))) MI   \(rt.string_elapsed_time)"
        }
        
    }
    
    
    
    func setButtonAndLabel(l: UILabel, b: UIButton, first: String, second: String, third: String) {
        var bigFontSize: CGFloat = 75
        var smallFontSize: CGFloat = 15
        
        if deviceNum == 4 {
            bigFontSize = 65.0
            smallFontSize = 13.0
        }
        
        if b == out_V1 || b == out_V2 || b == out_V1 {
            
            if deviceNum == 4 {
                bigFontSize = 75.0
                smallFontSize = 15.0
            } else {
                bigFontSize = 85.0
                smallFontSize = 20.0
            }
        }
        
        if b == out_V2 || b == out_H2 {
            bigFontSize = bigFontSize * 1.1
            smallFontSize = smallFontSize * 1.1
        }
        
        let string = first + second as NSString
        let result = NSMutableAttributedString(string: string as String)
        let attributesForFirstWord = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font:  UIFont(
                name: "Yanone Kaffeesatz",
                size: bigFontSize)!
        ]
        let attributesForSecondWord = [
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.font:  UIFont(
                name: "Yanone Kaffeesatz",
                size: smallFontSize)!
        ]
        result.setAttributes(attributesForFirstWord,
                             range: string.range(of: first))
        
        result.setAttributes(attributesForSecondWord,
                             range: string.range(of: second))
        UIButton.setAnimationsEnabled(false)
        b.setAttributedTitle(result, for: .normal)
        
        l.text = third
    }
    
    
    func getFirst(counterNum: Int) -> (f: String, s: String, t: String) {
        
        switch counterNum {
        case 0:
            let f = stringer0(myIn: rt.rt_cadence)
            let s = " RPM"
            let t = "CAD"
            return(f, s, t)
        case 1:
            let f = stringer1(myIn: rt.rt_speed)
            let s = " MPH"
            let t = "SPD"
            return(f, s, t)
        case 2:
            let f = stringer0(myIn: rt.rt_hr)
            let s = " BPM"
            let t = "HRT \n \(stringer0(myIn: rt.rt_score)) %"
            return(f, s, t)
        case 3:
            let f = stringer0(myIn: round.cadence)
            let s = " RPM"
            let t = "CAD (RND)"
            return(f, s, t)
        case 4:
            let f = stringer1(myIn: round.speed)
            let s = " MPH"
            let t = "SPD (RND)"
            return(f, s, t)
        case 5:
            let f = stringer0(myIn: round.hr)
            let s = " BPM"
            let percentofmax = stringer0(myIn: Double((Double(round.hr) / Double(settings_MAXHR)) * Double(100)))
            let t = "HRT(RND) \n \(percentofmax) %"
            return(f, s, t)
        case 6:
            let f = stringer1(myIn: geo.speed)
            let s = " MPH"
            let t = "SPD(GEO) \n \(geo.pace) m/mi"
            return(f, s, t)
        case 7:
            let f = geo.pace
            let s = " MIN"
            let t = "PACE(GEO) \n \(stringer1(myIn: geo.speed)) MPH"
            return(f, s, t)
        default:
            let f = "00.0"
            let s = " MPH"
            let t = "SPD \n (300)"
            return(f, s, t)
        }
        
    }
    
    let maxCounterOptions = 7
    var btnV1_counter: Int = 0
    @IBAction func btn_V1(_ sender: UIButton) {
        
        btnV1_counter = counters[0]
        let c = btnV1_counter
        if c == maxCounterOptions {
            btnV1_counter = 0
        } else {
            btnV1_counter += 1
        }
        counters[0] = btnV1_counter
        let l = out_L1V
        let b = out_V1
        
        let gf = getFirst(counterNum: c)
        
        let f = gf.f
        let s = gf.s
        let t = gf.t
        setButtonAndLabel(l: l!, b: b!, first: f, second: s, third: t)
    }
    
    var btnV2_counter: Int = 0
    @IBAction func btn_V2(_ sender: UIButton) {
        
        btnV2_counter = counters[1]
        let l = out_L2V
        let b = out_V2
        let c = btnV2_counter
        if c == maxCounterOptions {
            btnV2_counter = 0
        } else {
            btnV2_counter += 1
        }
        counters[1] = btnV2_counter
        
        let gf = getFirst(counterNum: c)
        
        let f = gf.f
        let s = gf.s
        let t = gf.t
        setButtonAndLabel(l: l!, b: b!, first: f, second: s, third: t)
    }
    
    var btnV3_counter: Int = 0
    @IBAction func btn_V3(_ sender: UIButton) {
        btnV3_counter = counters[2]
        let l = out_L3V
        let b = out_V3
        let c = btnV3_counter
        if c == maxCounterOptions {
            btnV3_counter = 0
        } else {
            btnV3_counter += 1
        }
        counters[2] = btnV3_counter
        
        let gf = getFirst(counterNum: c)
        
        let f = gf.f
        let s = gf.s
        let t = gf.t
        setButtonAndLabel(l: l!, b: b!, first: f, second: s, third: t)
    }
    
    var btnH1_counter: Int = 0
    @IBAction func btn_H1(_ sender: UIButton) {
        btnH1_counter = counters[3]
        let l = out_L1H
        let b = out_H1
        let c = btnH1_counter
        if c == maxCounterOptions {
            btnH1_counter = 0
        } else {
            btnH1_counter += 1
        }
        counters[3] = btnH1_counter
        
        let gf = getFirst(counterNum: c)
        
        let f = gf.f
        let s = gf.s
        let t = gf.t
        setButtonAndLabel(l: l!, b: b!, first: f, second: s, third: t)
    }
    
    var btnH2_counter: Int = 0
    @IBAction func btn_H2(_ sender: UIButton) {
        btnH2_counter = counters[4]
        let l = out_L2H
        let b = out_H2
        let c = btnH2_counter
        if c == maxCounterOptions {
            btnH2_counter = 0
        } else {
            btnH2_counter += 1
        }
        counters[4] = btnH2_counter
        
        let gf = getFirst(counterNum: c)
        
        let f = gf.f
        let s = gf.s
        let t = gf.t
        setButtonAndLabel(l: l!, b: b!, first: f, second: s, third: t)
    }
    
    var btnH3_counter: Int = 0
    @IBAction func btn_H3(_ sender: UIButton) {
        btnH3_counter = counters[5]
        let l = out_L3H
        let b = out_H3
        let c = btnH3_counter
        if c == maxCounterOptions {
            btnH3_counter = 0
        } else {
            btnH3_counter += 1
        }
        counters[5] = btnH3_counter
        
        let gf = getFirst(counterNum: c)
        
        let f = gf.f
        let s = gf.s
        let t = gf.t
        setButtonAndLabel(l: l!, b: b!, first: f, second: s, third: t)
    }
    
    var HeadL_Counter = 0
    @IBAction func btn_HeadL(_ sender: UIButton) {
        let x = HeadL_Counter
        if x == 0 {
            out_H3.isHidden = true
            out_L3H.isHidden = true
            HeadL_Counter = 1
        }
        if x == 1 {
            //out_V2.isHidden = true
            out_H2.isHidden = true
            //out_L2V.isHidden = true
            out_L2H.isHidden = true
            HeadL_Counter = 2
        }
        if x == 2 {
            //out_V3.isHidden = false
            out_H3.isHidden = false
            //out_V2.isHidden = false
            out_H2.isHidden = false
            //out_L2V.isHidden = false
            out_L2H.isHidden = false
            //out_L3V.isHidden = false
            out_L3H.isHidden = false
            HeadL_Counter = 0
        }
    }
    
    var HeadR_Counter = 0
    @IBAction func btn_HeadR(_ sender: UIButton) {
        let x = HeadR_Counter
        if x == 0 {
            out_V3.isHidden = true
            //out_H3.isHidden = true
            out_L3V.isHidden = true
            //out_L1H.isHidden = true
            HeadR_Counter = 1
        }
        if x == 1 {
            out_V2.isHidden = true
            //out_H2.isHidden = true
            out_L2V.isHidden = true
            //out_L2H.isHidden = true
            HeadR_Counter = 2
        }
        if x == 2 {
            out_V3.isHidden = false
            //out_H3.isHidden = false
            out_V2.isHidden = false
            //out_H2.isHidden = false
            out_L2V.isHidden = false
            //out_L1H.isHidden = false
            out_L3V.isHidden = false
            //out_L2H.isHidden = false
            HeadR_Counter = 0
        }
        
        
        
    }
    
    var swipeUpVal: Int = 1
    var swipeValue: Int = 0
    var totalSwipeValues: Int = 2 //3 with zero - 0, 1, 2
    
    
    
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
            //self.tabBarController?.selectedIndex = 2;
            break
        }
    }
    
    
    @IBOutlet weak var out_L1V: UILabel!
    @IBOutlet weak var out_L2V: UILabel!
    @IBOutlet weak var out_L3V: UILabel!
    
    @IBOutlet weak var out_L1H: UILabel!
    @IBOutlet weak var out_L2H: UILabel!
    @IBOutlet weak var out_L3H: UILabel!
    
    
    var deviceNum: Int = 0
    var buttons = [UIButton]()
    var labels = [UILabel]()
    var counters = [Int]()
    
    
    
    @objc func update1a() {
        var n = 0
        while n < 6 {  //number of labels or buttons needing an update
            
            let l = labels[n]
            let b = buttons[n]
            let gf = getFirst(counterNum: counters[n])
            let f = gf.f
            let s = gf.s
            let t = gf.t
            setButtonAndLabel(l: l, b: b, first: f, second: s, third: t)
            n += 1
        }
        
        getHeader()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice().userInterfaceIdiom == .phone
        {
            switch UIScreen.main.nativeBounds.height
            {
            case 480:
                print("iPhone Classic")
            case 960:
                print("iPhone 4 or 4S")
                deviceNum = 4
                
            case 1136:
                print("iPhone 5 or 5S or 5C")
                
            case 1334:
                print("iPhone 6 or 6S")
                
            case 2208:
                print("iPhone 6+ or 6S+")
                
            default:
                print("unknown")
                
            }
        }
        
        buttons.append(out_V1)
        labels.append(out_L1V)
        counters.append(0)
        
        buttons.append(out_V2)
        labels.append(out_L2V)
        counters.append(1)
        
        buttons.append(out_V3)
        labels.append(out_L3V)
        counters.append(2)
        
        buttons.append(out_H1)
        labels.append(out_L1H)
        counters.append(3)
        
        buttons.append(out_H2)
        labels.append(out_L2H)
        counters.append(4)
        
        buttons.append(out_H3)
        labels.append(out_L3H)
        counters.append(5)
        
        var n = 0
        while n < 6 {
            
            let l = labels[n]
            let b = buttons[n]
            let gf = getFirst(counterNum: counters[n])
            let f = gf.f
            let s = gf.s
            let t = gf.t
            setButtonAndLabel(l: l, b: b, first: f, second: s, third: t)
            n += 1
        }
        
        self.view.bringSubview(toFront: out_L1V)
        self.view.bringSubview(toFront: out_L2V)
        self.view.bringSubview(toFront: out_L3V)
        
        self.view.bringSubview(toFront: out_L1H)
        self.view.bringSubview(toFront: out_L2H)
        self.view.bringSubview(toFront: out_L3H)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(update1a), name: Notification.Name("update"), object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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
