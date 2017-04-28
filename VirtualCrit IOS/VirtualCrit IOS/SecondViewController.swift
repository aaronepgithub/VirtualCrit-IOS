//
//  SecondViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    

    
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
        formater.dateFormat = "mm:ss"
        //formater.dateFormat = "HH:mm:ss"
        formater.timeZone = NSTimeZone(name: "GMT") as TimeZone!
        let date = Date(timeIntervalSince1970: timeInterval)
        return formater.string(from: date as Date)
    }
    
    func updateUI() {
        
        lbl_speed.text = "\(String(format:"%.1f", Rounds.avg_speed))"
        lbl_hr.text = "\(String(format:"%.1f", Rounds.avg_hr))"
        
        lbl_spd_avg.text = "\(String(format:"%.1f", Totals.avg_speed))"
        lbl_hr_avg.text = "\(String(format:"%.1f", Totals.avg_hr))"
        

        
        lbl_total_time.text = dateStringFromTimeInterval(timeInterval : Totals.durationTotal!) + " Total"
        lbl_round_time.text = dateStringFromTimeIntervalRound(timeInterval: Rounds.roundCurrentTimeElapsed!) + " Round"
    }

    @IBOutlet weak var btn_update: UIButton!
    
    @IBOutlet weak var lbl_speed: UILabel!
    @IBOutlet weak var lbl_hr: UILabel!
    
    @IBOutlet weak var lbl_spd_avg: UILabel!
    @IBOutlet weak var lbl_hr_avg: UILabel!
    
    @IBOutlet weak var lbl_total_time: UILabel!
    @IBOutlet weak var lbl_round_time: UILabel!
    
    @IBAction func action_update(_ sender: UIButton) {
        updateUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateUI()
        
        updateUITimer = Timer()
        updateUITimer = Timer.scheduledTimer(timeInterval: 1.00, target: self, selector: #selector(updateUI), userInfo: nil, repeats: true)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

