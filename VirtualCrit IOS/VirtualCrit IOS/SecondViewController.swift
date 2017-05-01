//
//  SecondViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    func requestTiresize() {
    
        //  Start Alert
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Enter Tiresize",
                                            message: "Example, X25 = 2015, X32 = 2155",
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
        
        // End Alert
        
    }
    
    
    @IBAction func btn_setTiresize(_ sender: UIButton) {
        requestTiresize()
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
        
//        lbl_speed.text = "\(String(format:"%.1f", Rounds.avg_speed))"
//        lbl_hr.text = "\(String(format:"%.1f", Rounds.avg_hr))"
//        
//        lbl_spd_avg.text = "\(String(format:"%.1f", Totals.avg_speed))"
//        lbl_hr_avg.text = "\(String(format:"%.1f", Totals.avg_hr))"
        

        
//        lbl_total_time.text = dateStringFromTimeInterval(timeInterval : Totals.durationTotal!) + " Total"
//        lbl_round_time.text = dateStringFromTimeIntervalRound(timeInterval: Rounds.roundCurrentTimeElapsed!) + " Round"
        
//        lbl_distance.text =  "\(String(format:"%.2f", Totals.distanceTotal)) Miles"
        
        let tempHR = AllRounds.arrHR.reversed()
        let tempSPD = AllRounds.arrSPD.reversed()
        var stringHR = ""
        var stringSPD = ""
        
        for eachHR in tempHR {
            stringHR = stringHR + String(round(eachHR)) + ", "
        }
        
        for eachSPD in tempSPD {
            stringSPD = stringSPD + String(round(eachSPD)) + ", "
        }
        
        lbl_previous_rounds_spd.text = stringSPD
        lbl_previous_rounds_hr.text = stringHR
        
        
        
    }


    
//    @IBOutlet weak var lbl_speed: UILabel!
//    @IBOutlet weak var lbl_hr: UILabel!
//    
//    @IBOutlet weak var lbl_spd_avg: UILabel!
//    @IBOutlet weak var lbl_hr_avg: UILabel!
//    
//    @IBOutlet weak var lbl_total_time: UILabel!
//    @IBOutlet weak var lbl_round_time: UILabel!
//    
//    @IBOutlet weak var lbl_distance: UILabel!

    @IBOutlet weak var lbl_previous_rounds_hr: UILabel!
    @IBOutlet weak var lbl_previous_rounds_spd: UILabel!
    
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

