//
//  SecondViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit




class SecondViewController: UIViewController {
    

    
    @IBOutlet weak var lbl_ctTimer: UILabel!
    @IBOutlet weak var lbl_ctDistance: UILabel!
    @IBOutlet weak var ctPace: UILabel!
    @IBOutlet weak var lbl_currentCadence: UILabel!
    @IBOutlet weak var lbl_elapsed_time: UILabel!
    
    @IBAction func btn_reset(_ sender: UIButton) {

        Lap_PublicVars.startTime = NSDate()
        Lap_PublicVars.crank_revs = 0
        Lap_PublicVars.wheel_revs = 0
        Lap_PublicVars.distance = 0
        Lap_PublicVars.arr_heartrate = []

    }
    
    
    @IBAction func btn_total_reset(_ sender: UIButton) {  //pacer
        
        alert(message: String(round(Device.idle_time/1024)))

    }
    
    
    var updateUITimer: Timer!
    
    
    //  Start Alert - Name
    func requestName() {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Rider Name",
                                            message: "Be Unique",
                                            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Tim"
                textField.keyboardType = .default
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.default,
                                   handler: {
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        
                                        if String(enteredText!) != nil { Settings.riderName = String(enteredText!) } else { Settings.riderName = "Tim" }
                                        
                                    }
                                    print(Settings.riderName as Any)
        })
        
        alertController?.addAction(action)
        
        self.present(alertController!,
                     animated: true,
                     completion: nil)
    }
    // End Alert- Name
    
    
    //  Start Alert - Tire Size
    func requestTiresize() {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Tiresize",
            message: "Example, X25 = 2105, X32 = 2155",
            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "2105"
                textField.keyboardType = .decimalPad
                })
        
        let action = UIAlertAction(title: "Submit",
            style: UIAlertActionStyle.default,
            handler: {
                (paramAction:UIAlertAction!) in
                    if let textFields = alertController?.textFields{
                        let theTextFields = textFields as [UITextField]
                        let enteredText = theTextFields[0].text
                                        
                            if (Double(enteredText!) != nil) { Device.wheelCircumference = Double(enteredText!) } else { Device.wheelCircumference = 2105 }
                                        
                        }
                        print(Device.wheelCircumference as Any)
        })
        
        alertController?.addAction(action)
        
        self.present(alertController!,
            animated: true,
            completion: nil)
    }
    // End Alert - Tire Size
    
    //  Start Alert - MAX HR
    
    func requestMAXHR() {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter MAX HR",
                                            message: "185-210",
                                            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "185"
                textField.keyboardType = .decimalPad
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.default,
                                   handler: {
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        
                                        if (Double(enteredText!) != nil) { Device.maxHR = Double(enteredText!)! } else { Device.maxHR = 185 }
                                        
                                    }
                                    print(Device.maxHR as Any)
        })
        
        alertController?.addAction(action)
        
        self.present(alertController!,
                     animated: true,
                     completion: nil)
    }
    
    
    //  End Alert - MAX HR
    
    @IBAction func btn_setTiresize(_ sender: UIButton) {
        requestTiresize()
    }
    
    @IBAction func btn_setName(_ sender: UIButton) {
        requestName()
    }
    
    @IBAction func btn_setMAXHR(_ sender: UIButton) {
        requestMAXHR()
    }
    
    
    
    
    func dateStringFromTimeInterval(timeInterval : TimeInterval) -> String{
        let formater = DateFormatter()
        //        formater.dateFormat = "HH:mm:ss.SS"
        formater.dateFormat = "HH:mm:ss"
        formater.timeZone = NSTimeZone(name: "GMT") as TimeZone!
        let date = Date(timeIntervalSince1970: timeInterval)
        return formater.string(from: date as Date)
    }
    
    func dateStringFromTimeIntervalRound(timeInterval : TimeInterval) -> String{
        let formater = DateFormatter()
        formater.dateFormat = "mm:ss.S"
        //formater.dateFormat = "HH:mm:ss"
        formater.timeZone = NSTimeZone(name: "GMT") as TimeZone!
        let date = Date(timeIntervalSince1970: timeInterval)
        return formater.string(from: date as Date)
    }
    
    func create_strings() {
    
        let tempHR = AllRounds.arrHR.reversed()
        let tempSPD = AllRounds.arrSPD.reversed()
        var stringHR = ""
        var stringSPD = ""
        
        tempArrHR = []
        tempArrSPD = []
        tempArrScore = []
        
        for eachHR in tempHR {
            stringHR = stringHR + String(format:"%.1f", eachHR) + ", "
            tempArrHR.append(String(format:"%.1f", eachHR) + "  BPM")
            tempArrScore.append(String(format:"%.1f", (eachHR / Device.maxHR * 100.0)) + " %MAX")
        }
        
        for eachSPD in tempSPD {
            stringSPD = stringSPD + String(format:"%.2f", eachSPD) + ", "
            tempArrSPD.append(String(format:"%.2f", eachSPD) + "  MPH")
        }
    }

    func updateUI() {
        
//        let tempHR = AllRounds.arrHR.reversed()
//        let tempSPD = AllRounds.arrSPD.reversed()
//        var stringHR = ""
//        var stringSPD = ""
//        
//        tempArrHR = []
//        tempArrSPD = []
//        tempArrScore = []
        
//        let threeSecSpeedTest = Device.ThreeSecondDistance / (Device.ThreeSecondDistanceTime)
//        //print(threeSecSpeedTest)
//        
//        let threeSecCadTest = Device.ThreeSecondCrankRevs / (Device.ThreeSecondCrankRevsTime) * 60
//        //print(threeSecCadTest)
//        
//        Device.ThreeSecondDistance = 0
//        Device.ThreeSecondCrankRevs = 0
//        Device.ThreeSecondCrankRevsTime = 0
//        Device.ThreeSecondDistanceTime = 0
        


//        if threeSecSpeedTest > 0 && threeSecSpeedTest < 50 {
//            lbl_ctTimer.text = "\(String(format:"%.1f", threeSecSpeedTest)) MPH"
//        } else {
//            lbl_ctTimer.text = "0 MPH"
//        }
        
//        lbl_ctDistance.text = "\(String(format:"%.1f", Totals.distanceTotal)) Miles"
//        ctPace.text = "\(String(format:"%.0f", Device.currentHeartrate)) BPM"
        
//        if threeSecCadTest > 0 && threeSecCadTest < 120 {
//            lbl_currentCadence.text = "\(String(format:"%.0f", threeSecCadTest)) RPM"
//        } else {
//            lbl_currentCadence.text = "0 RPM"
//        }
        
//        lbl_ctTimer.text = "  \(String(format:"%.1f", PublicVars.speed))  MH"
//        ctPace.text =   "  \(String(format:"%.0f", PublicVars.heartrate))   BM"
//        lbl_currentCadence.text = "  \(String(format:"%.0f", PublicVars.cadence))   RM"

        
        if Device.peri1 == "peri1" {lbl_ctTimer.text = "  HR"
        } else {
        lbl_ctTimer.text = "  \(Device.peri1)  HR"
        }
        
        
        if Device.peri2 == "peri2" {ctPace.text =   "  CSC"
        } else {
        ctPace.text =   "  \(Device.peri2)   CSC"
        }
        
        
        
        if Device.peri3 == "peri3" {lbl_currentCadence.text = "  CSC"
        } else {
        lbl_currentCadence.text = "  \(Device.peri3)   CSC"
        }
        

        lbl_elapsed_time.text = Pacer.status
        
        lbl_ctDistance.text = String(Int(Device.max_wheel_rev_value))
        
        //TODO:  CREATE STORAGE ARR FOR EACH LAP, POST TO TABLE
        
        
        
    }
    
    var counter: Int = 0
    
    func countManager() {
        
        updateUI()
        counter += 1

        
        if counter == 30 {
            create_strings()
            counter = 0
        }
        
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //anotherSecondElapsed
        NotificationCenter.default.addObserver(self, selector: #selector(countManager), name: Notification.Name("anotherSecondElapsed"), object: nil)
        updateUI()
        
        
//        updateUITimer = Timer()
//        updateUITimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

