//
//  FirstViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation
import AVKit
import Firebase

//TODO:  DISPLAY BLE MOVING TIME

extension UIViewController {
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            alertController.dismiss(animated: true, completion: nil)
        }
    }
    

    
}

public var tempArrHR = [String]()
public var tempArrSPD = [String]()
public var tempArrScore = [String]()

struct PublicVars {
    //static var elapsedMilliseconds: Double = 0
    static var startTime: NSDate?
    //static var currentTime: NSDate?
    static var duration: TimeInterval?
    //static var array_active_time = [TimeInterval]()
    
    static var wheel_revs: Double = 0
    static var crank_revs: Double = 0
    
    static var cadence: Double = 0
    static var speed: Double = 0
    static var arr_heartrate = [Double]()
    static var heartrate: Double = 0
    static var score: Double = 0
    
    static var distance: Double = 0
    static var string_elapsed_time: String = "00:00:00"
}

struct Round_PublicVars {
    //static var elapsedMilliseconds: Double = 0
    static var startTime: NSDate?
    //static var currentTime: NSDate?
    static var duration: TimeInterval?
    
    static var wheel_revs: Double = 0
    static var crank_revs: Double = 0
    
    static var cadence: Double = 0
    static var speed: Double = 0
    static var arr_heartrate = [Double]()
    static var heartrate: Double = 0
    static var score: Double = 0
    
    static var distance: Double = 0
    static var string_elapsed_time: String = "00:00:00"
}

struct Lap_PublicVars {
    static var startTime: NSDate?
    static var duration: TimeInterval?
    
    static var wheel_revs: Double = 0
    static var crank_revs: Double = 0
    
    static var cadence: Double = 0
    static var speed: Double = 0
    static var arr_heartrate = [Double]()
    static var heartrate: Double = 0
    static var score: Double = 0
    
    static var distance: Double = 0
    static var string_elapsed_time: String = "00:00:00"
}

//TODO
struct RT_PublicVars {
    static var startTime: NSDate?
    static var duration: TimeInterval?
    
    static var wheel_revs: Double = 0
    static var crank_revs: Double = 0
    
    static var cadence: Double = 0
    static var speed: Double = 0
    static var arr_heartrate = [Double]()
    static var heartrate: Double = 0
    static var score: Double = 0
    
    static var distance: Double = 0
    static var string_elapsed_time: String = "00:00:00"
}


class FirstViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var timerEachSecond: Timer!
    var timerMilliSecond: Timer!
    
    var msCounter = 1
    var roundCounter = 1
    var timeNewMS = 0.0

    var str = "Hi, this is Kazumi. Let's get started"
    func newSpeakerWithClass() {
        let str = self.str
        let x = TextToSpeechUtils.init()
        x.synthesizeSpeech(forText: str)
    
    }
    
    @IBOutlet var dockView1: UIView!
    @IBOutlet weak var dock1_lastSpeed: UILabel!
    @IBOutlet weak var dock1_lastScore: UILabel!
    @IBOutlet weak var dock1_lastCadence: UILabel!
    @IBOutlet weak var dock1_closeBtn: UIButton!
    @IBOutlet weak var doc1_bttmLabel: UILabel!
    
    @IBOutlet weak var lbl_Speed: UILabel!
    @IBOutlet weak var lbl_Cadence: UILabel!
    @IBOutlet weak var lbl_Heartrate: UILabel!
    @IBOutlet weak var lbl_Score: UILabel!
    
    @IBOutlet weak var lbl_Distance: UILabel!
    var hasPressedStart = false
    
    @IBAction func btn_ble_scan(_ sender: UIButton) {
        startScanning()
    }
    
    @IBAction func btn_change_display(_ sender: UIButton) {
        changeDisplay()
    }
    
    // Core Bluetooth properties
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral?
    var peripheralCSC:CBPeripheral?
    var arrPeripheral = [CBPeripheral?]()
    
    
    func changeDisplay() {
    
        if data_to_display == "round" {
            data_to_display = "total"
            return
        }
        
        if data_to_display == "total" {
            data_to_display = "lap"
            return
        }
        if data_to_display == "lap" {
            data_to_display = "realtime"
            return
        }
        
        if data_to_display == "realtime" {
            data_to_display = "round"
            return
        }

        
        
        print(data_to_display)
    }
    
    func normalTap(_ sender: UIGestureRecognizer){
        
        changeDisplay()
        print("Normal tap")
    }
    
    func longTap(_ sender: UIGestureRecognizer){
        print("Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
            //            startScanning()
        }
        else if sender.state == .began {
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
            //startScanning()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        lbl_Duration_Button.addGestureRecognizer(tapGesture)
        lbl_Duration_Button.addGestureRecognizer(longGesture)
        
        AllRounds.arrHR.append(0)
        AllRounds.arrSPD.append(0)
        AllRounds.arrTime.append("0")
        
        Device.wheelCircumference = 2105

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        Settings.dateToday = formatter.string(from: date)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        pushFBRound()
        pushFBTotals()
        start_function()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    }

    
    @IBAction func dockView1_close(_ sender: UIButton) {
       dockView1.removeFromSuperview()
    }
    
    @IBAction func btn_Duration(_ sender: UIButton) {
        startScanning()
    }
    
    @IBOutlet weak var lbl_Duration_Button: UIButton!
    
    
    var milli_counter: Int = 0
    var milli_elapsed_milliseconds: Int = 0
    var milli_elapsed_seconds: Int = 0
    
    
//MARK:  DISPLAY UPDATE
    
    var data_to_display = "round"
    func update_main_display_values() {
    

        //ROUND
        if data_to_display == "round" {
            
            lbl_Duration_Button.setTitle(Round_PublicVars.string_elapsed_time, for: .normal)
            lbl_Distance.text = "\(String(format:"%.2f", Round_PublicVars.distance)) Round"
            lbl_Heartrate.text = "\(String(format:"%.0f", Round_PublicVars.heartrate))"
            
            lbl_Score.text = "\(String(format:"%.1f", Round_PublicVars.score))"
            lbl_Speed.text = "\(String(format:"%.1f", Round_PublicVars.speed))"
            lbl_Cadence.text = "\(String(format:"%.0f", Round_PublicVars.cadence))"
            
        }
        
        //TOTAL
        if data_to_display == "total" {
        
            lbl_Duration_Button.setTitle(PublicVars.string_elapsed_time, for: .normal)
            lbl_Distance.text = "\(String(format:"%.2f", PublicVars.distance)) Total"
            lbl_Heartrate.text = "\(String(format:"%.0f", PublicVars.heartrate))"
            
            lbl_Score.text = "\(String(format:"%.1f", PublicVars.score))"
            lbl_Speed.text = "\(String(format:"%.1f", PublicVars.speed))"
            lbl_Cadence.text = "\(String(format:"%.0f", PublicVars.cadence))"
  
        }
        
        //LAP
        if data_to_display == "lap" {
            
            lbl_Duration_Button.setTitle(Lap_PublicVars.string_elapsed_time, for: .normal)
            lbl_Distance.text = "\(String(format:"%.2f", Lap_PublicVars.distance)) Lap"
            lbl_Heartrate.text = "\(String(format:"%.0f", Lap_PublicVars.heartrate))"
            
            lbl_Score.text = "\(String(format:"%.1f", Lap_PublicVars.score))"
            lbl_Speed.text = "\(String(format:"%.1f", Lap_PublicVars.speed))"
            lbl_Cadence.text = "\(String(format:"%.0f", Lap_PublicVars.cadence))"
            
        }
        
        //REALTIME
        if data_to_display == "realtime" {
            
            lbl_Duration_Button.setTitle(PublicVars.string_elapsed_time, for: .normal)
            lbl_Distance.text = "\(String(format:"%.2f", PublicVars.distance)) Current"
            lbl_Heartrate.text = "\(String(format:"%.0f", RT_PublicVars.heartrate))"
            
            lbl_Score.text = "\(String(format:"%.1f", RT_PublicVars.score))"
            lbl_Speed.text = "\(String(format:"%.1f", RT_PublicVars.speed))"
            lbl_Cadence.text = "\(String(format:"%.0f", RT_PublicVars.cadence))"
            
        }
        
        
        
    }
    
    // EACH SECOND UPDATE
    func milli_each_second_update() {
        
        milli_elapsed_seconds += 1
        
        let x = NSDate()
        
        let y = x.timeIntervalSince(PublicVars.startTime! as Date!)
        let yy = x.timeIntervalSince(Round_PublicVars.startTime! as Date!)
        let yyy = x.timeIntervalSince(Lap_PublicVars.startTime! as Date!)
        let yyyy = x.timeIntervalSince(RT_PublicVars.startTime! as Date!)

        
        let z = Double(y)
        let zz = Double(yy)
        let zzz = Double(yyy)  //lap time as Double, in seconds
        let zzzz = Double(yyyy)
        
//        //MARK:  RT CALC
        let cadence_rt = RT_PublicVars.crank_revs / zzzz * 60
        let distance_rt = RT_PublicVars.wheel_revs * (Device.wheelCircumference! / 1000) * 0.000621371  //round distance, in miles
        let speed_rt = distance_rt / (zzzz / 60 / 60) //miles per hour
        RT_PublicVars.cadence = cadence_rt
        RT_PublicVars.distance = distance_rt
        RT_PublicVars.speed = speed_rt
        RT_PublicVars.arr_heartrate.append(Device.currentHeartrate)
        let hr_rt = RT_PublicVars.arr_heartrate.reduce(0.0) {
            return $0 + $1/Double(RT_PublicVars.arr_heartrate.count)
        }
        RT_PublicVars.heartrate = hr_rt
        RT_PublicVars.score = hr_rt / Device.maxHR * 100
        RT_PublicVars.string_elapsed_time = dateStringFromTimeInterval(timeInterval : yyyy)
//        //  END CALC FOR RT
        
        

        //MARK:  ROUND CALC
        let cadence_r = Round_PublicVars.crank_revs / zz * 60
        let distance_r = Round_PublicVars.wheel_revs * (Device.wheelCircumference! / 1000) * 0.000621371  //round distance, in miles
        let speed_r = distance_r / (zz / 60 / 60) //miles per hour
        Round_PublicVars.cadence = cadence_r
        Round_PublicVars.distance = distance_r
        Round_PublicVars.speed = speed_r
        Round_PublicVars.arr_heartrate.append(Device.currentHeartrate)
        let hr_r = Round_PublicVars.arr_heartrate.reduce(0.0) {
            return $0 + $1/Double(Round_PublicVars.arr_heartrate.count)
        }
        Round_PublicVars.heartrate = hr_r
        Round_PublicVars.score = hr_r / Device.maxHR * 100
        Round_PublicVars.string_elapsed_time = dateStringFromTimeInterval(timeInterval : yy)
        //  END CALC FOR ROUND

        
        //MARK:  LAP  CALC
        let cadence_l = Lap_PublicVars.crank_revs / zzz * 60
        let distance_l = Lap_PublicVars.wheel_revs * (Device.wheelCircumference! / 1000) * 0.000621371  //round distance, in miles
        let speed_l = distance_l / (zzz / 60 / 60) //miles per hour
        Lap_PublicVars.cadence = cadence_l
        Lap_PublicVars.distance = distance_l
        Lap_PublicVars.speed = speed_l
        Lap_PublicVars.arr_heartrate.append(Device.currentHeartrate)
        let hr_l = Lap_PublicVars.arr_heartrate.reduce(0.0) {
            return $0 + $1/Double(Lap_PublicVars.arr_heartrate.count)
        }
        Lap_PublicVars.heartrate = hr_l
        Lap_PublicVars.score = hr_l / Device.maxHR * 100
        Lap_PublicVars.string_elapsed_time = dateStringFromTimeInterval(timeInterval : yyy)
        
        
        

        let target_finish_goal_in_seconds = (Pacer.target_distance * (60 / Pacer.target_avg_speed) * 60)
        let pacer_finish_time = Date(timeInterval: target_finish_goal_in_seconds, since: Lap_PublicVars.startTime! as Date!)
        
        
        
        let remaining_distance = Pacer.target_distance - Lap_PublicVars.distance
        let estimated_time_arrival = remaining_distance * (60 / Lap_PublicVars.speed)  //remaining dist * min per mile
        
        let pace_spd_delta = Lap_PublicVars.speed - Pacer.target_avg_speed
        let pace_time_delta = Pacer.target_duration - ((zzz / 60) + estimated_time_arrival)
        
        
        //String(format:"%.2f", eachSPD)
        let string_a = String(format:"%.1f", pace_spd_delta)
        let string_b = String(format:"%.1f", remaining_distance)
        let string_c = String(format:"%.1f", pace_time_delta)
        let string_d = String(format:"%.1f", estimated_time_arrival)
        //let string_e = String(format:"%.0f", (Pacer.target_distance * (60 / Pacer.target_avg_speed)))
        
        
        let second:TimeInterval = 1.0
        //goal - time from now
        //let goal_time = Date(timeIntervalSinceNow: (second * (Pacer.target_distance * (60 / Pacer.target_avg_speed)) * 60 ) )
        
        //eta - time from now
        let eta_time = Date(timeIntervalSinceNow: second * (estimated_time_arrival * 60))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .medium

        Pacer.goal_time = dateFormatter.string(from: pacer_finish_time)
        Pacer.eta_time = dateFormatter.string(from: eta_time)
        
        
        if remaining_distance > 0 {
            Pacer.status = "Speed vs Target \(string_a) Distance Remaining \(string_b) Time vs Target \(string_c) Estimated Min to Finish \(string_d)"
        } else {
            Pacer.status = "Complete"
        }
        
        
        
        //  END CALC FOR LAP & PACE
        
        
        
        //MARK:  TOTALS  CALC
        let cadence = PublicVars.crank_revs / z * 60
        let distance = PublicVars.wheel_revs * (Device.wheelCircumference! / 1000) * 0.000621371  //total distance, in miles
        let speed = distance / (z / 60 / 60) //miles per hour
        
        PublicVars.cadence = cadence
        
        if distance == PublicVars.distance{
            Device.idle_time += 1
        }
        
        PublicVars.distance = distance
        PublicVars.speed = speed
        PublicVars.arr_heartrate.append(Device.currentHeartrate)
            let hr = PublicVars.arr_heartrate.reduce(0.0) {
            return $0 + $1/Double(PublicVars.arr_heartrate.count)
            }
        PublicVars.heartrate = hr
        PublicVars.score = hr / Device.maxHR * 100
        PublicVars.string_elapsed_time = dateStringFromTimeInterval(timeInterval : y)
        
        
        //TEST MOVING SPD CALCS  Device.idle_time  Device.total_ble_seconds
        let total_moving_speed = distance / ((z - Device.idle_time) / 60 / 60) //miles per hour
        Device.total_moving_speed = total_moving_speed
        
        let delta_ble_seconds =  z - Device.total_ble_seconds
        let ble_moving_speed = distance / ((z - delta_ble_seconds) / 60 / 60) //miles per hour
        Device.total_moving_speed_ble = ble_moving_speed
        // END TEST MOVING SPD CALCS
        
        
        //  END CALC FOR TOTALS
        
        

        
        
        //DETERMINE END OF ROUND
        
        let t1 = Double(Rounds.roundsComplete * 300)
        let t2 = Int(t1)
        let t3 = Int(z)
        let t4 = t3 - t2
        if t4 >= 300 {
            print("Round Complete")
            Round_PublicVars.startTime = NSDate()
            
            updateTimerRound()
        }

        
        update_main_display_values()
        NotificationCenter.default.post(name: Notification.Name("anotherSecondElapsed"), object: nil)
    }
    

    var milli_round_counter = 0
    var milli_rt_counter = 0
    func updateTimerMilliSecond() {
        milli_counter += 1
        milli_round_counter += 1
        milli_elapsed_milliseconds += 1
        milli_rt_counter += 1
        
        
        if milli_counter == 100 {
            milli_counter = 0
            milli_each_second_update()
        }  //called for each second
        
        if milli_rt_counter == 3 {
            reset_RT_vars()
        }
    }
    
    func reset_RT_vars() {
    
        RT_PublicVars.startTime = NSDate()
        RT_PublicVars.crank_revs = 0
        RT_PublicVars.wheel_revs = 0
        RT_PublicVars.distance = 0
        RT_PublicVars.arr_heartrate = []
        
        //  RAW CALC
        let cadence_raw = Device.raw_crank_revs / (Device.raw_crank_time / 1024) * 60
        let distance_raw = Device.raw_wheel_revs * (Device.wheelCircumference! / 1000) * 0.000621371  //raw distance, in miles
        let speed_raw = distance_raw / ((Device.raw_wheel_time / 1024) / 60 / 60) //miles per hour
        //Round_PublicVars.cadence = cadence_r
        //Round_PublicVars.distance = distance_r
        //Round_PublicVars.speed = speed_r
        //Round_PublicVars.arr_heartrate.append(Device.currentHeartrate)
        //let hr_r = Round_PublicVars.arr_heartrate.reduce(0.0) {
        //return $0 + $1/Double(Round_PublicVars.arr_heartrate.count)
        //}
        //Round_PublicVars.heartrate = hr_r
        //Round_PublicVars.score = hr_r / Device.maxHR * 100
        //Round_PublicVars.string_elapsed_time = dateStringFromTimeInterval(timeInterval : yy)
        
        // END RAW CALC
        
        print("Raw Speed:  \(speed_raw) Mph")
        print("Raw Cadence:  \(cadence_raw) Rpm")
        Device.raw_speed = speed_raw
        Device.raw_cadence = cadence_raw
        
        Device.raw_crank_revs = 0
        Device.raw_crank_time = 0
        Device.raw_wheel_revs = 0
        Device.raw_wheel_time = 0
        
        
        
        milli_rt_counter = 0
    }
    
    func start_function() {
    
        newSpeakerWithClass()

        Rounds.distanceRound = 0
        Rounds.totalWheelEventTime = 0
        Rounds.arrHRRound = []
        
        if timerMilliSecond == nil {
            
            timerMilliSecond = Timer()
            timerMilliSecond = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimerMilliSecond), userInfo: nil, repeats: true)
            
            let startNSDate = NSDate()
            PublicVars.startTime = startNSDate
            Round_PublicVars.startTime = startNSDate
            Lap_PublicVars.startTime = startNSDate
            RT_PublicVars.startTime = startNSDate
            

        }
        
        getFirebase()
        getFirebaseSpeed()
        
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
                formater.dateFormat = "mm:ss"
        //formater.dateFormat = "HH:mm:ss"
        formater.timeZone = NSTimeZone(name: "GMT") as TimeZone!
        let date = Date(timeIntervalSince1970: timeInterval)
        return formater.string(from: date as Date)
    }
    

    
    var roundsCompleted = 0
    
    func updateTimerRound() {
        //at the end of each round
        roundsCompleted = roundsCompleted + 1

        AllRounds.arrHR.append(Round_PublicVars.heartrate)
        AllRounds.arrSPD.append(Round_PublicVars.speed)
        AllRounds.arrCAD.append(Round_PublicVars.cadence)
        AllRounds.arrTime.append(PublicVars.string_elapsed_time)

        
        Round_PublicVars.arr_heartrate = []
        Round_PublicVars.wheel_revs = 0
        Round_PublicVars.crank_revs = 0
        
        Rounds.roundsComplete = 1 + Rounds.roundsComplete

        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            
            print("Firebase push Round data")
            pushFBRound()
            pushFBTotals()
            

            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                

                print("Firebase get Round data")
                getFirebase()
                getFirebaseSpeed()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                    self.str = "Round complete!  Your speed for the last round Speed was \(String(format:"%.2f", AllRounds.arrSPD.last!)).  Your score for the last round was \(String(format:"%.1f", AllRounds.arrHR.last! / Device.maxHR * 100)) .  The current leaders are \(Leaderboard.roundLeadersString)"
                    
                    self.newSpeakerWithClass()
                })
            })
        })
        //        lbl_button_start.setTitle("🔴🔴🔴", for: .normal)
        dockView1_open()
    }
    

    
    func printCurrentDateAndTime() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        print("Starting...")
        print(formatter.string(from: currentDateTime)) // October 8, 2016 at 10:48:53 PM
    }
    
    //func updateTimerEachSecond() {
      //  Totals.totalTimeInSeconds += 1
//        NotificationCenter.default.post(name: Notification.Name("anotherSecondElapsed"), object: nil)
        //let x = NSDate()
//        Rounds.roundCurrentTimeElapsed = (x.timeIntervalSince(Rounds.roundStartTime! as Date!))
//        Totals.durationTotal = (x.timeIntervalSince(Totals.startTime! as Date!))

        //MARK:  SET DURATION BUTTON & DISPLAY
        //lbl_Duration_Button.setTitle(dateStringFromTimeInterval(timeInterval : Totals.durationTotal!), for: .normal)
        
//        let doubleDurationTotal = Double(Totals.durationTotal!)
//        let dblElapsedTime = Double(doubleDurationTotal - ((Double(roundsCompleted) * 300)))
//        let dblElapsedRoundTime = Int(300 - (Int(round(dblElapsedTime))))
        //        lbl_RoundTime.text = String(dblElapsedRoundTime)
        
//        //MARK:  SET DURATION BUTTON & DISPLAY - ONLY DISPLAY WHEN SHOWING ROUND DATA
//        let str = "\(String(dblElapsedRoundTime))  (\(dateStringFromTimeInterval(timeInterval : Totals.durationTotal!)))"
//        lbl_Duration_Button.setTitle(str, for: .normal)

        
        
        //MARK:  END OF ROUND
       // if dblElapsedRoundTime <= 0 {
//            print("New Round...")
//            printCurrentDateAndTime()

//            roundsCompleted = roundsCompleted + 1
//            
//            Totals.arrHRTotal.append(Rounds.avg_hr)
//            AllRounds.arrHR.append(Rounds.avg_hr)
//            AllRounds.arrSPD.append(Rounds.avg_speed)
//            AllRounds.arrCAD.append(Rounds.avg_cadence)
//            
//            Rounds.distanceRound = 0
//            Rounds.totalWheelEventTime = 0
//            Rounds.arrHRRound = []
//            Rounds.crankRevolutionTime = 0
//            Rounds.crankRevolutions = 0
//            lbl_Speed.text = "..."
//            lbl_Cadence.text = "..."
//            lbl_Heartrate.text = "..."
//            lbl_Score.text = "..."
            //updateTimerRound()
            
        //}
        
        
        
//        if dblElapsedRoundTime == 295 {
//            if ConnectionCheck.isConnectedToNetwork() {
//                //getRoundDataGlobal()
//                //getFirebase()
//                //getFirebaseSpeed()
//            }
//            
//        }
        

//        if dblElapsedRoundTime == 290 && roundsCompleted > 0 {
//            self.str = "Round complete!  Your speed for the last round Speed was \(String(format:"%.2f", AllRounds.arrSPD.last!)).  Your score for the last round was \(String(format:"%.1f", AllRounds.arrHR.last! / Device.maxHR * 100)) .  The current leaders are \(Leaderboard.roundLeadersString)"
//
//            newSpeakerWithClass()
//        }

        
//        Rounds.avg_score = Rounds.avg_hr / Device.maxHR * 100

        //TODO:  WHERE ARE ACTUAL TOTALS COMING FROM...
//        Totals.arrHRTotal.append(Device.currentHeartrate)
//        Rounds.arrHRRound.append(Device.currentHeartrate)
//        Rounds.avg_hr = Rounds.arrHRRound.reduce(0.0) {
//            return $0 + $1/Double(Rounds.arrHRRound.count)
//        }
//        Totals.avg_hr = Totals.arrHRTotal.reduce(0.0) {
//            return $0 + $1/Double(Totals.arrHRTotal.count)
//        }

//        self.lbl_round_speed.text = "\(String(format:"%.1f", AllRounds.arrSPD.max()!))"  // my best spd
//        self.lbl_round_hr.text = "\(String(format:"%.1f",  AllRounds.arrHR.max()!)) Bpm"  //my best hr

//        if dblElapsedRoundTime == 240 {
//            if ConnectionCheck.isConnectedToNetwork() {
//                //getFirebase()
//                //getFirebaseSpeed()
//            }
        
            //dock1_closeBtn.setTitle("4 Minutes Remain", for: .normal)
            //self.dockView1_open()
            
        //}

        
//        if dblElapsedRoundTime == 180 {
//        }
        
//        if dblElapsedRoundTime == 150 {
//            pushFBTotals()
//            getFirebase()
//            getFirebaseSpeed()
//            self.str = "Midway"
//            //newSpeakerWithClass()
//        }
        

//        if dblElapsedRoundTime == 120 {
//            //dock1_closeBtn.setTitle("2 Minutes Remain", for: .normal)
//            //self.dockView1_open()
//            
//        }
        
//        if dblElapsedRoundTime == 75 {
//            if ConnectionCheck.isConnectedToNetwork() {
//                //getRoundDataGlobal()
//            }
//
//        }
        
//        if dblElapsedRoundTime == 60 {
//            self.str = Leaderboard.roundLeadersString
//            //newSpeakerWithClass()
//            //dock1_closeBtn.setTitle("1 Minute Remains", for: .normal)
//            //self.dockView1_open()
//        }
        
        
    //}
    
    func dockView1_open() {

        if AllRounds.arrHR.count > 0 && AllRounds.arrCAD.count > 0 {
        
            dock1_lastSpeed.text = "\(String(format:"%.2f", AllRounds.arrSPD.last!))"
            dock1_lastScore.text = "\(String(format:"%.1f", AllRounds.arrHR.last! / Device.maxHR * 100))"
            dock1_lastCadence.text = "\(String(format:"%.1f", AllRounds.arrCAD.last!))"
        
        }
        let str = "\(Leaderboard.scoreLeaderScore) (\(Leaderboard.scoreLeaderName))  |  \(Leaderboard.speedLeaderScore) (\(Leaderboard.speedLeaderName))"
        doc1_bttmLabel.text = str
        
        dockView1.center = view.center
        view.addSubview(dockView1)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            self.dockView1.removeFromSuperview()
        })
    }
    
    
    func startScanning() {
        
        print("Start Scanning")
        
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            return
        } else {
            
            self.centralManager.scanForPeripherals(withServices: [CBUUID.init(string: Device.TransferService), CBUUID.init(string: Device.TransferServiceCSC) ], options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                self.centralManager.stopScan()
                print("Stop Scanning")
                if PublicVars.heartrate == 0 && PublicVars.speed == 0 {
                    self.startScanning()
                }

            })
        }
        
    }
    
    func disconnect() {
        // verify we have a peripheral
        guard let peripheral = self.peripheral else {
            print("Peripheral object has not been created yet.")
            return
        }
        // check to see if the peripheral is connected
        if peripheral.state != .connected {
            print("Peripheral exists but is not connected.")
            self.peripheral = nil
            return
        }
        guard let services = peripheral.services else {
            print("Cancel Peripheral Connection")
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        for service in services {
            // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Device struct
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristic) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("set Notify Value to False")
                        return
                    }
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristicCSC) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("set Notify Value to False")
                        return
                    }
                }
            }
        }
        // disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
        
        Round_PublicVars.wheel_revs = 0
        Round_PublicVars.crank_revs = 0
        Round_PublicVars.heartrate = 0
        Round_PublicVars.arr_heartrate = [0]
        oldWheelRevX = 0

        self.str = "Function Disconnect for \(peripheral.name!)"
        print(self.str)
        newSpeakerWithClass()
        alert(message: self.str)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(String(describing: peripheral.name)) at \(RSSI)")
        
        // check to see if we've already saved a reference to this peripheral
        if self.peripheral != peripheral {
            
            // Save a reference to the peripheral object so Core Bluetooth doesn't get rid of it
            self.peripheral = peripheral
            self.arrPeripheral.append(peripheral)
            
            // Stop scanning
            centralManager.stopScan()
            print("Scanning Stopped! - Discovered")
            
            // connect to the peripheral
            print("Connecting to peripheral: \(peripheral)")

            let alertController = UIAlertController(title: "\(peripheral.name!)", message: "Bluetooth Sensor", preferredStyle: .actionSheet)

            let destructiveAction = UIAlertAction(title:"Connect", style: .destructive) { (action) -> Void in
                print("You selected the Connect action")
                self.centralManager?.connect(peripheral, options: nil)
            }
            
            let cancelAction = UIAlertAction(title:"Cancel", style: .cancel) { (action) -> Void in
                print("You selected the Cancel action")
            }

            alertController.addAction(destructiveAction)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)

            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when){
                alertController .dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?){
        print("Did Disconnect Peripheral")
        // verify we have a peripheral
        
        Round_PublicVars.wheel_revs = 0
        Round_PublicVars.crank_revs = 0
        Round_PublicVars.heartrate = 0
        Round_PublicVars.arr_heartrate = [0]
        oldWheelRevX = 0
        
        self.str = "did Disconnect Peripheral \(peripheral.name!)"
        print(self.str)
        alert(message: self.str)
        newSpeakerWithClass()
        
        
        guard let peripheral = self.peripheral else {
            print("Peripheral object has not been created yet.")
            return
        }
        
        // check to see if the peripheral is connected
        if peripheral.state != .connected {
            print("Peripheral exists but is not connected.")

            //put rescan code here
            centralManager.connect(self.peripheral!, options: nil)
            return
        }
        
        guard let services = peripheral.services else {
            // disconnect directly
            centralManager.cancelPeripheralConnection(peripheral)
            print("Cancel Peripheral Connection")
            return
        }
        
        for service in services {
            // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Device struct
//                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristic) {
//                        // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
//                        // didUpdateNotificationStateForCharacteristic method will be called automatically
//                        peripheral.setNotifyValue(false, for: characteristic)
//                        return
//                    }
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristic) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("set Notify Value to False")
                        return
                    }
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristicCSC) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        print("set Notify Value to False")
                        return
                    }
                    
                }
            }
        }
        // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
        // Therefore, we will just disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
        print("Cancel Connection")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")
        
        // IMPORTANT: Set the delegate property, otherwise we won't receive the discovery callbacks, like peripheral(_:didDiscoverServices)
        peripheral.delegate = self
        
        // Now that we've successfully connected to the peripheral, let's discover the services.
        // This time, we will search for the transfer service UUID
        print("Looking for Transfer Service...")
        peripheral.discoverServices([CBUUID.init(string: Device.TransferService), CBUUID.init(string: Device.TransferServiceCSC)])
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered Services!!!")
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                // If we found either the transfer service, discover the transfer characteristic
                if (service.uuid == CBUUID(string: Device.TransferService)) {
                    let transferCharacteristicUUID = CBUUID.init(string: Device.TransferCharacteristic)
                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
                }
                
                if (service.uuid == CBUUID(string: Device.TransferServiceCSC)) {
                    let transferCharacteristicUUID = CBUUID.init(string: Device.TransferCharacteristicCSC)
                    peripheral.discoverCharacteristics([transferCharacteristicUUID], for: service)
                }
            }
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Transfer Characteristic
                if characteristic.uuid == CBUUID(string: Device.TransferCharacteristic) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                    Device.peri1 = peripheral.name!
                }
                if characteristic.uuid == CBUUID(string: Device.TransferCharacteristicCSC) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                    if Device.peri2 == "peri2" {Device.peri2 = peripheral.name!} else {Device.peri3 = peripheral.name!}
                }
            }
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // if there was an error then print it and bail out
        if error != nil {
            print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        // make sure we have a characteristic value
        guard characteristic.value != nil else {
            //print("Characteristic Value is nil on this go-round")
            return
        }
        
        
        if characteristic.uuid == CBUUID(string: Device.TransferCharacteristic) {
            guard characteristic.value != nil else {
                print("Characteristic Value is nil on this go-round")
                return
            }
            
            if error != nil {
                print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
                return
            }
            
            
            func decodeHRValue(withData data: Data) -> Int {
                let count = data.count / MemoryLayout<UInt8>.size
                var array = [UInt8](repeating: 0, count: count)
                (data as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
                var bpmValue : Int = 0
                
                if ((array[0] & 0x01) == 0) {
                    bpmValue = Int(array[1])
                    
                } else {
                    //Convert Endianess from Little to Big
                    bpmValue = Int(UInt16(array[2] * 0xFF) + UInt16(array[1]))
                }
                
                Device.currentHeartrate = Double(bpmValue)
                //print(Device.currentHeartrate)
                //MARK:  CURRENT HR
                return bpmValue
            }
            
            let newValue = decodeHRValue(withData: characteristic.value!)

            
        }
        
        if characteristic.uuid == CBUUID(string: Device.TransferCharacteristicCSC) {
            // make sure we have a characteristic value
            guard characteristic.value != nil else {
                print("Characteristic Value is nil on this go-round")
                return
            }
            if error != nil {
                print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
                return
            }
            
            //USED FOR RAW & RT
            func processWheelData(withData data :Data) {

                var wheelRevolution     :Double = 0
                var wheelEventTime      :Double = 0
                //var wheelRevolutionDiff :Double = 0
                //var wheelEventTimeDiff  :Double = 0
                
                //var travelDistance      :Double = 0
                //var travelSpeed         :Double = 0
                
                var newWheelRevs        :UInt32 = 0
                var newWheelRevsTime    :UInt16 = 0
            
                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))

                //using newWheelRevs and newWheelTime
                newWheelRevs = UInt32(CFSwapInt32LittleToHost(UInt32(value[1])))
                newWheelRevsTime = (UInt16(value[6]) * 0xFF) + UInt16(value[5])
                //let val2 = UInt32(CFSwapInt32LittleToHost(UInt32(value[2])))
            
                wheelRevolution = Double(newWheelRevs)
                wheelEventTime = Double(newWheelRevsTime)
                //wheelRevolution = Double(Double(newWheelRevs) + (255 * Double(val2)))

                var a: Double = 0;var b: Double = 0; var c: Double = 0;
                
                if Device.oldWheelRevolution > 0 {  //test for NOT first time reading
                    a = wheelRevolution - Device.oldWheelRevolution
                    b = wheelEventTime - Device.oldWheelEventTime
                    
                    if a < 0 {
                        a = (wheelRevolution + 255) - Device.oldWheelRevolution
                    }
                    
                    if b < 0 {
                        b = (wheelEventTime + 255) - Device.oldWheelEventTime
                    }
                    
                    c = b/1024
                    
                    Device.total_ble_seconds += c
                    Device.raw_wheel_revs += a
                    Device.raw_wheel_time += b // still in 1/1024 second
                    
                    
                    
                }
                Device.oldWheelRevolution = Double(wheelRevolution)
                Device.oldWheelEventTime = Double(newWheelRevsTime)
            }
            
            
            
            func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
                
                var crankEventTime      : Double = 0
                //var crankRevolutionDiff : Double = 0
                //var crankEventTimeDiff  : Double = 0
                var crankRevolution     : Double = 0
                //var travelCadence       : Double = 0
                
                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
                
                crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
                crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0

                if Device.oldCrankRevolution > 0 {  //test for first time reading
                    
                    var a = crankRevolution - Device.oldCrankRevolution
                    var b = (crankEventTime - Device.oldCrankEventTime)
                    
                    if a < 0 {
                        a = (crankRevolution + 255) - Device.oldCrankRevolution
                    }
                    
                    if b < 0 {
                        b = (crankEventTime + 255) - Device.oldCrankEventTime
                    }
                    

                    
                    PublicVars.crank_revs += a
                    Round_PublicVars.crank_revs += a
                    Lap_PublicVars.crank_revs += a
                    RT_PublicVars.crank_revs += a
                    
                    Device.raw_crank_revs += a
                    Device.raw_crank_time += b  //still in 1/1024 of a sec
                    

                }
                Device.oldCrankRevolution = crankRevolution
                Device.oldCrankEventTime = crankEventTime
            }
            

            func processWheelDataX(withData data :Data) {
                var wheelRevolution     :UInt8  = 0
                var wheelRevolutionDiff :Double = 0
                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
                wheelRevolution = UInt8(CFSwapInt32LittleToHost(UInt32(value[1])))
                
                if oldWheelRevX != 0 {
                    wheelRevolutionDiff = Double(wheelRevolution) - Double(oldWheelRevX)
                    if wheelRevolutionDiff < 0 {
                        wheelRevolutionDiff = (Double(wheelRevolution) + 255) - Double(oldWheelRevX)
                    }
                }
                oldWheelRevX = Int(wheelRevolution)
                PublicVars.wheel_revs += wheelRevolutionDiff
                Round_PublicVars.wheel_revs += wheelRevolutionDiff
                Lap_PublicVars.wheel_revs += wheelRevolutionDiff
                RT_PublicVars.wheel_revs += wheelRevolutionDiff
            }
            
            func decodeCSC(withData data : Data) {
                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
                
                let flag = value[0]
                
                if flag & Device.WHEEL_REVOLUTION_FLAG == 1 {
                    processWheelData(withData: data)
                    processWheelDataX(withData: data)
                    if flag & 0x02 == 2 {
                        processCrankData(withData: data, andCrankRevolutionIndex: 7)
                        //if returnedCadence == 2000 {print(returnedCadence)}
                    }
                } else {
                    if flag & Device.CRANK_REVOLUTION_FLAG == 2 {
                        processCrankData(withData: data, andCrankRevolutionIndex: 1)
                    }
                }
            }
            
            
            
            func deltaWithRollover<T: Integer>(_ new: T, old: T, max: T) -> T {
                return old > new ? max - old + new : new - old
            }
            
            
            
            

            
            decodeCSC(withData: characteristic.value!)
        }
    }
    
    
    var oldWheelRevX: Int = 0
    var totalWheelRevsX: Double = 0
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // if there was an error then print it and bail out
        if error != nil {
            print("Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }
        
        if characteristic.isNotifying {
            // notification started
            print("Notification STARTED on characteristic: \(characteristic)")
        } else {
            // notification stopped
            print("Notification STOPPED on characteristic: \(characteristic)")
            self.centralManager.cancelPeripheralConnection(peripheral)
            alert(message: "\(peripheral)", title: "BLE Sensor STOPPED")
        }
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Updated: \(central.state)")
        
        
        // if Bluetooth is on, proceed...
        if central.state != .poweredOn {
            self.peripheral = nil
            return
        }
        
        // check for a peripheral object
        guard let peripheral = self.peripheral else {
            return
        }
        
        // see if that peripheral is connected
        guard peripheral.state == .connected else {
            return
        }
        
        
    }
    
    var roundLeaderScore: Double = 0
    var roundLeaderName: String = "..."
    
    var totalLeaderScore: Double = 0
    var totalLeaderSpeed: Double = 0
    var totalLeaderName: String = "..."
    var totalLeaderNameSpeed: String = "..."
    
    var namesArray = [String]()
    var scoresArray = [Double]()
    var speedsArray = [Double]()
    
    var namesArrayTotal = [String]()
    var scoresArrayTotal = [Double]()
    var speedsArrayTotal = [Double]()
    
    var leaderString = ""
    var leaderStringSpeed = ""
    
    var leaderStringTotal = ""
    var leaderStringSpeedTotal = ""
    

    
    
    func httpGet() {
        //print("httpGet Started")
        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/" + Settings.dateToday + ".json"
        let url = NSURL(string: todosEndpoint)
        
        if ConnectionCheck.isConnectedToNetwork() {
            

        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                //print(2)
                //print(jsonObj as Any)
                
                if jsonObj == nil {
                    return
                }
                
                for (key, _) in jsonObj! {
                    //print(3)
                    
                    if let nestedDictionary = jsonObj?[key] as? [String: Any] {
                            //print(4)
                        for(key, _) in nestedDictionary {
                            //print(5)

                            if key == "fb_RND" {
                                //print(6)

                                self.namesArray.append(nestedDictionary["fb_timName"] as! String!)
                                self.speedsArray.append(nestedDictionary["fb_SPD"] as! Double!)
                                self.scoresArray.append(nestedDictionary["fb_RND"] as! Double!)
                                let x = nestedDictionary["fb_RND"] as! Double!
                                //print(x!)
                                if x! > self.roundLeaderScore {
                                    //print(x!)
                                    self.roundLeaderScore = x!
                                    let y = nestedDictionary["fb_timName"] as! String!
                                    self.roundLeaderName = y!
                                }
                            }
                        }
                    }
                }
                //at the end
                
                
            }
        }).resume()
            
        }  //end of network test
        
            } // end of httpGet
    
    
        
                
                
//                //print(self.scoresArray)
//                let _max = self.scoresArray.max()
//                //print(_max as Any)
//                self.leaderString += "\(_max!) "
//                let indexOfMax = self.scoresArray.index(of: _max!)
//                //print(indexOfMax as Any)
//                let _nameOfLeader = self.namesArray[indexOfMax!]
//                //print(_nameOfLeader as Any)
//                self.leaderString += String(_nameOfLeader) + " \n "
//                
//                
//                //print(self.speedsArray)
//                let _maxSpeed = self.speedsArray.max()
//                //print(_maxSpeed as Any)
//                self.leaderStringSpeed += "\(_maxSpeed!) "
//                let indexOfMaxSpeed = self.speedsArray.index(of: _maxSpeed!)
//                //print(indexOfMaxSpeed as Any)
//                let _nameOfLeaderSpeed = self.namesArray[indexOfMaxSpeed!]
//                //print(_nameOfLeaderSpeed as Any)
//                self.leaderStringSpeed += String(_nameOfLeaderSpeed)
//                
//
//                //print(self.leaderString)
//                //print(self.leaderStringSpeed)
//                //self.alert(message: self.leaderString, title: "Leaders")
                


        
        

    
//    func httpPost() {
//    
////        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/20170513.json"
//        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/" + Settings.dateToday + ".json"
//        guard let todosURL = URL(string: todosEndpoint) else {
//            print("Error: cannot create URL")
//            return
//        }
//        var todosUrlRequest = URLRequest(url: todosURL)
//        todosUrlRequest.httpMethod = "POST"
//        
//        let aa = AllRounds.arrHR.last
//        let ab = aa! / Device.maxHR * 100
//        let xx = "\(String(format:"%.1f", aa!))"
//        let yy = "\(String(format:"%.1f", AllRounds.arrSPD.last!))"
//        let zz = "\(String(format:"%.1f", ab))"
//        
//        
//        let newTodo: [String: Any] = [
//            "a_scoreRoundLast": Double(zz) ?? 0,
//            "a_speedRoundLast": Double(yy) ?? 0,
//            "a_cadenceRoundLast": 1,
//            "a_heartrateRoundLast": Double(xx) ?? 0,
//            "a_calcDurationPost": Totals.displayedTime,
//            "a_timName": Settings.riderName,
//            "a_timGroup": "IOS",
//            "a_timTeam": "Square Pizza",
//            "a_Date": Settings.dateToday,
//            "a_DateNow": Settings.dateToday,
//            "a_lastCAD": 1,
//            "a_lastHR": Double(xx) ?? 0,
//            "a_timDistanceTraveled": 1,
//            "a_maxHRTotal": Double(Device.maxHR) ,
//            "fb_CAD":0,
//            "fb_Date":Settings.dateToday,
//            "fb_DateNow":"1494517025335",
//            "fb_HR":Double(xx) ?? 0,
//            "fb_RND":Double(zz) ?? 0,
//            "fb_SPD":Double(yy) ?? 0,
//            "fb_maxHRTotal":Device.maxHR,
//            "fb_scoreHRRound":Double(zz) ?? 0,
//            "fb_scoreHRRoundLast":Double(zz) ?? 0,
//            "fb_scoreHRTotal":Double(zz) ?? 0,
//            "fb_timAvgCADtotal":0,
//            "fb_timAvgHRtotal":0,
//            "fb_timAvgSPDtotal":0,
//            "fb_timDistanceTraveled":0,
//            "fb_timGroup":"IOS",
//            "fb_timName":Settings.riderName,
//            "fb_timTeam":"Square Pizza"
//        ]
//        
//        
//        let jsonTodo: Data
//        do {
//            jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
//            todosUrlRequest.httpBody = jsonTodo
//        } catch {
//            print("Error: cannot create JSON from todo")
//            return
//        }
//        
//        if ConnectionCheck.isConnectedToNetwork() {
//        //execute
//        let session = URLSession.shared
//        let task = session.dataTask(with: todosUrlRequest) { _, _, _ in }
//        task.resume()
//        }
//        
//        
//        
//    }


    
        func httpPut() {
            
//            let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/totals/20170513/IOS.json"
            let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/totals/" + Settings.dateToday + "/" + Settings.riderName + ".json"
            guard let todosURL = URL(string: todosEndpoint) else {
                print("Error: cannot create URL")
                return
            }
            var todosUrlRequest = URLRequest(url: todosURL)
            todosUrlRequest.httpMethod = "PUT"
            
            let a = Totals.avg_hr / Device.maxHR * 100
            //let x = "\(String(format:"%.1f", Totals.avg_hr))"
            let y = "\(String(format:"%.1f", Totals.avg_speed))"
            let z = "\(String(format:"%.1f", a))"
            
            let newTodo: [String: Any] = [
                "a_speedTotal": Double(y) ?? 0,
                "a_speedLast": Double(y) ?? 0,
                "a_timName": Settings.riderName,
                "a_timGroup": "IOS",
                "a_timTeam": "IOS",
                "a_Date": Settings.dateToday,
                "a_DateNow": Settings.dateToday,
                "a_timDistanceTraveled": 1,
                "a_calcDurationPost":"00:00:05",
                "a_scoreHRRoundLast":Double(z) ?? 0,
                "a_scoreHRTotal":Double(z) ?? 0,
                "fb_Date":Settings.dateToday,
                "fb_DateNow":"1494517025353",
                "fb_maxHRTotal":Device.maxHR,
                "fb_scoreHRRoundLast":0,
                "fb_scoreHRTotal":Double(z) ?? 0,
                "fb_timAvgCADtotal":0,
                "fb_timAvgSPDtotal":Double(y) ?? 0,
                "fb_timDistanceTraveled":0,
                "fb_timGroup":"IOS",
                "fb_timLastSPD":0,
                "fb_timName":Settings.riderName,
                "fb_timTeam":"Square Pizza"
            ]


        
        let jsonTodo: Data
        do {
            jsonTodo = try JSONSerialization.data(withJSONObject: newTodo, options: [])
            todosUrlRequest.httpBody = jsonTodo
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        
            if ConnectionCheck.isConnectedToNetwork() {
        //execute
        let session = URLSession.shared
        let task = session.dataTask(with: todosUrlRequest) { _, _, _ in }
        task.resume()
            }
        
    
    }
    
}





