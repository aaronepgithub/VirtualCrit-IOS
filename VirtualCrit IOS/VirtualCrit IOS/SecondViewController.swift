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
//    @IBOutlet weak var lbl_ctDistance: UILabel!
    @IBOutlet weak var ctPace: UILabel!
    @IBOutlet weak var lbl_currentCadence: UILabel!
    @IBOutlet weak var lbl_elapsed_time: UILabel!
    //@IBOutlet weak var lbl_display_moving_times: UILabel!
    
    @IBOutlet weak var lbl_pacer_times: UILabel!
    
    
    @IBAction func btn_reset(_ sender: UIButton) {

        Lap_PublicVars.startTime = NSDate()
        Lap_PublicVars.crank_revs = 0
        Lap_PublicVars.wheel_revs = 0
        Lap_PublicVars.distance = 0
        Lap_PublicVars.arr_heartrate = []
        
        Device.idle_time = 0
        Device.total_ble_seconds = 0
        
        requestPacerDistance()
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            self.requestPacerSpeed()
        }
        

    }
    
    
    //SET PACER TARGET SPEED
    func requestPacerSpeed() {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Pacer Speed",
                                            message: "Example, 15 (mph)",
                                            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "15"
                textField.keyboardType = .decimalPad
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.default,
                                   handler: {
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        
                                        if (Double(enteredText!) != nil) { Pacer.target_avg_speed = Double(enteredText!)! } else { Pacer.target_avg_speed = 15 }
                                        
                                    }
                                    print(Pacer.target_avg_speed as Any)
        })
        
        alertController?.addAction(action)
        
        self.present(alertController!,
                     animated: true,
                     completion: nil)
    }


    //END SET PACER TARGET SPEED
    
    
    
    //SET PACER TARGET DISTANCE
    func requestPacerDistance() {
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Pacer Distance",
                                            message: "Example, 20 (miles)",
                                            preferredStyle: .alert)
        
        alertController!.addTextField(
            configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "20"
                textField.keyboardType = .decimalPad
        })
        
        let action = UIAlertAction(title: "Submit",
                                   style: UIAlertActionStyle.default,
                                   handler: {
                                    (paramAction:UIAlertAction!) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        
                                        if (Double(enteredText!) != nil) { Pacer.target_distance = Double(enteredText!)! } else { Pacer.target_distance = 5 }
                                        
                                    }
                                    print(Pacer.target_distance as Any)
        })
        
        alertController?.addAction(action)
        
        self.present(alertController!,
                     animated: true,
                     completion: nil)
    }
    // End Alert -SET PACER DISTANCE
    
    
    
    
    @IBAction func btn_total_reset(_ sender: UIButton) {
        let msg = "Moving Spd: \(String(format:"%.1f", Device.total_moving_speed))  BLE Moving Spd: \(String(format:"%.1f", Device.total_moving_speed_ble)) Idle: \(String(format:"%.0f", Device.idle_time))  BLE Idle: \(String(format:"%.0f", Device.total_ble_seconds))"
        
        alert(message: msg)
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
        //lbl_ctDistance.text = String(Int(Device.max_wheel_rev_value))
        
        
        //let str = "Timer Spd: \(String(format:"%.1f", Device.total_moving_speed))   BLE Moving Spd: \(String(format:"%.1f", Device.total_moving_speed_ble))"
        //lbl_display_moving_times.text = str
        
        lbl_pacer_times.text = "Goal:  \(Pacer.goal_time)    ETA:  \(Pacer.eta_time)"
        
        
        
    }
    
    var counter: Int = 0
    
    func countManager() {
        
        updateUI()
        counter += 1

        
        if counter == 30 {
            create_strings()
            
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

