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
    @IBOutlet weak var ctPace: UILabel!
    @IBOutlet weak var lbl_currentCadence: UILabel!
    @IBOutlet weak var lbl_pacer_times: UILabel!
    
    
    @IBAction func btn_pacer_distance(_ sender: UIButton) {
        requestPacerDistance()
    }
    
    @IBAction func btn_pacer_speed(_ sender: UIButton) {
        requestPacerSpeed()
    }
    
    
    
    @IBAction func btn_reset(_ sender: UIButton) {

        Lap_PublicVars.startTime = NSDate()
        Lap_PublicVars.crank_revs = 0
        Lap_PublicVars.wheel_revs = 0
        Lap_PublicVars.distance = 0
        Lap_PublicVars.arr_heartrate = []
        
        Device.idle_time = 0
        Device.total_ble_seconds = 0
        
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
                                        let old_Settings_riderName = Settings.riderName
                                        Settings.riderName = String(enteredText!)
                                        
                                        //if String(enteredText!) != nil { Settings.riderName = String(enteredText!) } else { Settings.riderName = "Tim" }
                                        
                                        if Settings.riderName == "" {
                                            Settings.riderName = old_Settings_riderName
                                        }
                                        
                                        
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
        
        
    }
    
    var counter: Int = 0
    @objc func countManager() {
        counter += 1
        
        if counter == 3 {
            //create_strings()
            updateUI()
            counter = 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //anotherSecondElapsed
        NotificationCenter.default.addObserver(self, selector: #selector(countManager), name: Notification.Name("anotherSecondElapsed"), object: nil)
        
        updateUI()
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

