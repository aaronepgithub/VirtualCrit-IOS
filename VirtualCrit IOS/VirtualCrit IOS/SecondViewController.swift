//
//  SecondViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

public var tempArrHR = [String]()
public var tempArrSPD = [String]()
public var tempArrScore = [String]()
public var ctDistance = 0.0

class SecondViewController: UIViewController {
    
    
    @IBOutlet weak var lbl_ctTimer: UILabel!
    @IBOutlet weak var lbl_ctDistance: UILabel!
    @IBOutlet weak var ctPace: UILabel!
    
    @IBAction func btn_ctStart(_ sender: UIButton) {
        
        ctMiles = 5.0
        ctPaceTimeInSeconds = 1200
        ctDistance = 0.0
        
    }
    
    
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
    
    
    
    var ctMiles = 5.0
    var ctPaceTimeInSeconds = 1200
    //var ctActualMilesTraveled = 0.0
    var targetMilesPerSecond = 0.004166667  // based on 15 Mph
    var actualMilesPerSecond = 0.0
    
    

    
    func updateUI() {
        
        // start ct
        
        if ctPaceTimeInSeconds > 1 {
            ctPaceTimeInSeconds -= 1 //based on timer increments
            
            let z = ctPaceTimeInSeconds
            let hr = Int(z) / 3600
            let mn = Int(z) / 60 % 60
            let sc = Int(z) % 60
            let timeString = String(hr) + " : " + String(mn) + " : " + String(sc)
            print ("time in sec \(z)")
            
            lbl_ctTimer.text = timeString

            let x = ctDistance
            print("miles traveled \(x)") //
            lbl_ctDistance.text = "\(String(format:"%.2f", x)) Mi"
            

            let y = Double(targetMilesPerSecond) * Double(1200 - z) // miles that should have been traveled
            print("targetMiles \(y)")
            
            
            let w = (x - y)
            print("actual miles - target miles \(w)")
            
            if w > 0 {
                print("ahead")
                ctPace.text = "Ahead  \(String(format:"%.2f", w))"
            } else {
                let absW = abs(w)
                print("behind")
                ctPace.text = "Behind \(String(format:"%.2f", absW))"
                
            }
            
            
        
        
        } else {
        
            ctPace.text = "Done"
            lbl_ctDistance.text = "..."
            lbl_ctTimer.text = "..."
            
        }
        

        
        // end ct
        
        
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
        
//        lbl_previous_rounds_spd.text = stringSPD
//        lbl_previous_rounds_hr.text = stringHR
        
        
        
    }



//    @IBOutlet weak var lbl_previous_rounds_hr: UILabel!
//    @IBOutlet weak var lbl_previous_rounds_spd: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateUI()
        
        updateUITimer = Timer()
        updateUITimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

