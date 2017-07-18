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


class FirstViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
//    var timerTotal: Timer!
//    var timerRound: Timer!
    var timerEachSecond: Timer!
    
    var msCounter = 1
    var roundCounter = 1
    var timeNewMS = 0.0
    

    
    @IBAction func btn_Round(_ sender: UIButton) {
        dockView1_open()
    }
    
    func prepareForPlaybackWithData(audioData: NSData) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    var str = "Hello Kazumi, let's get started"
    
    func mySpeaker() {
        
        let str = self.str
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: str)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        let lang = "en-US"
        
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
        synth.speak(utterance)
    }
    
    
    
    func BleDisconnectSpeaker() {
        
        let str = "Bluetooth has been disconnected"
        let synth = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: str)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        let lang = "en-US"
        
        utterance.voice = AVSpeechSynthesisVoice(language: lang)
        synth.speak(utterance)
    }
    
//    func EndofRoundSpeaker() {
//        
//        //TODO, GET FROM LAST ROUND ARR
//        
//        let str = "Round complete!  Your speed for the last round Speed was \(String(format:"%.2f", Rounds.avg_speed)).  Your score for the last round was \(String(format:"%.1f", Rounds.avg_score))"
//        let synth = AVSpeechSynthesizer()
//        let utterance = AVSpeechUtterance(string: str)
//        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
//        let lang = "en-US"
//        
//        utterance.voice = AVSpeechSynthesisVoice(language: lang)
//        synth.speak(utterance)
//        print("Running in BG")
//        print("Rounds.avg_score  \(Rounds.avg_score)")
//    }
    
    @IBOutlet var dockView1: UIView!
    @IBOutlet weak var dock1_lastSpeed: UILabel!
    @IBOutlet weak var dock1_lastScore: UILabel!
    @IBOutlet weak var dock1_lastCadence: UILabel!
    
    @IBOutlet weak var lbl_TotalTime: UILabel!
    @IBOutlet weak var lbl_RoundTime: UILabel!
    
    @IBOutlet weak var lbl_Speed: UILabel!
    @IBOutlet weak var lbl_Cadence: UILabel!
    @IBOutlet weak var lbl_Heartrate: UILabel!
    @IBOutlet weak var lbl_Score: UILabel!
    
    @IBOutlet weak var lbl_Distance: UILabel!

    @IBOutlet weak var lbl_round_speed: UILabel!
    @IBOutlet weak var lbl_round_hr: UILabel!
    @IBOutlet weak var lbl_total_speed: UILabel!
    @IBOutlet weak var lbl_total_hr: UILabel!
    
    @IBOutlet weak var lbl_button_start: UIButton!
    
    var hasPressedStart = false
    
    
    // Core Bluetooth properties
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral?
    var peripheralCSC:CBPeripheral?
    var arrPeripheral = [CBPeripheral?]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        AllRounds.arrHR.append(0)
        AllRounds.arrSPD.append(0)
        
        if ConnectionCheck.isConnectedToNetwork() {
            print("Connected")

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
                    self.dockView1.removeFromSuperview()
                    self.httpPost()
                    print("httpPost")
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                    self.httpPut()
                    print("httpPut")
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: {
                    
                    self.httpGet()
                    print("httpGet")
                })
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(40), execute: {
//                    self.httpGetTotals()
//                    print("httpGetTotals")
//                })
            
        }
        else{
            print("Disconnected")
        }
        
        
        Device.wheelCircumference = 2105
        //print(Device.wheelCircumference as Any)
        
        //set date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        Settings.dateToday = formatter.string(from: date)
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func dockView1_close(_ sender: UIButton) {
       dockView1.removeFromSuperview()
    }

    @IBAction func btn_Scan(_ sender: UIButton) {
        startScanning()
    }
    
    @IBAction func btn_action_start(_ sender: UIButton) {
        alert(message: "", title: "Starting")
        mySpeaker()
        
        if ConnectionCheck.isConnectedToNetwork() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
            self.httpPost()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20), execute: {
            self.httpPut()
            })
        }
        
        if hasPressedStart == true {
            print("already started")
            return
        }
        
        //let secondsPerRound = 300.0

        
        //Rounds.roundStartTime = NSDate()
        Rounds.distanceRound = 0
        Rounds.totalWheelEventTime = 0
        Rounds.arrHRRound = []
        
        lbl_button_start.setTitle("🔴🔴🔴🔴🔴", for: .normal)
        
        if timerEachSecond == nil {

            timerEachSecond = Timer()
            timerEachSecond = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerEachSecond), userInfo: nil, repeats: true)
            
            Totals.startTime = NSDate()
            Rounds.roundStartTime = NSDate()
            
            
            
//            // get the current date and time
//            let currentDateTime = Date()
//            // initialize the date formatter and set the style
//            let formatter = DateFormatter()
//            formatter.timeStyle = .medium
//            formatter.dateStyle = .long
//            // get the date time String from the date object
//            print(formatter.string(from: currentDateTime)) // October 8, 2016 at 10:48:53 PM
            
            
            
            
            
            
//            AllRounds.arrHR.append(0)
//            AllRounds.arrSPD.append(0)
        }
        
            hasPressedStart = true
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
    
//    public func updateTimerTotal() {
//        //Each second, update
//        
//        Totals.totalTimeInSeconds += 1
//
//        Totals.arrHRTotal.append(Device.currentHeartrate)
//        Rounds.arrHRRound.append(Device.currentHeartrate)
//        Rounds.avg_hr = Rounds.arrHRRound.reduce(0.0) {
//            return $0 + $1/Double(Rounds.arrHRRound.count)
//        }
//        Totals.avg_hr = Totals.arrHRTotal.reduce(0.0) {
//            return $0 + $1/Double(Totals.arrHRTotal.count)
//        }
//        self.lbl_round_speed.text = "\(String(describing: String(self.roundLeaderName)))"  //leader name
//        self.lbl_round_hr.text = "\(String(format:"%.1f",  self.roundLeaderScore)) %MAX"  //leader score
//    }
    
    var roundsCompleted = 0
    
    func updateTimerRound() {
        //every seconds per round (300)
        Rounds.roundsComplete = 1 + Rounds.roundsComplete

//        Totals.arrHRTotal.append(Rounds.avg_hr)
//        AllRounds.arrHR.append(Rounds.avg_hr)
//        AllRounds.arrSPD.append(Rounds.avg_speed)
//        AllRounds.arrCAD.append(Rounds.avg_cadence)
//
//        Rounds.distanceRound = 0
//        Rounds.totalWheelEventTime = 0
//        Rounds.arrHRRound = []
//        Rounds.crankRevolutionTime = 0
//        Rounds.crankRevolutions = 0
//        lbl_Speed.text = "..."
//        lbl_Cadence.text = "..."
//        lbl_Heartrate.text = "..."
//        lbl_Score.text = "..."

        lbl_button_start.setTitle("🔴🔴🔴🔴🔴", for: .normal)
        dockView1_open()

        
        if ConnectionCheck.isConnectedToNetwork() {
            print("Connected")
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30), execute: {
                self.lbl_button_start.setTitle("🔴🔴🔴🔴", for: .normal)
                print("httpPost")
                self.httpPost()
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60), execute: {
                    self.lbl_button_start.setTitle("🔴🔴🔴", for: .normal)
                    self.httpPut()
                    print("httpPut")
                    
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60), execute: {
                        self.lbl_button_start.setTitle("🔴🔴", for: .normal)
                        self.httpGet()
                        print("httpGet")
                        
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60), execute: {
                            self.lbl_button_start.setTitle("🔴", for: .normal)

                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(60), execute: {
                                self.lbl_button_start.setTitle("", for: .normal)
                                self.httpGet()
                                print("httpGet")
                                
                            })
                            
                        })
                    })
                })
            })
            

            

        }
        else{
            print("Disconnected")
        }
        
        
        
        
        
    }
    
    func eachSecondUpdateFctn() {
        // No longer used
    
    }
    
    
    func updateTimerEachSecond() {
        //every 1 second

        
        let x = NSDate()
        Rounds.roundCurrentTimeElapsed = (x.timeIntervalSince(Rounds.roundStartTime! as Date!))
        Totals.durationTotal = (x.timeIntervalSince(Totals.startTime! as Date!))
        
//        lbl_RoundTime.text = dateStringFromTimeIntervalRound(timeInterval: Rounds.roundCurrentTimeElapsed!)
        lbl_TotalTime.text = dateStringFromTimeInterval(timeInterval : Totals.durationTotal!)
        
        let intDurationTotal = Int(Totals.durationTotal!)
        //print("intDurationTotal \(intDurationTotal)")
        
//        let intRoundCurrentTimeElapsed = Int(Rounds.roundCurrentTimeElapsed!)
//        print("intRoundCurrentTimeElapsed \(intRoundCurrentTimeElapsed)")
        
        let tester1 = intDurationTotal - (roundsCompleted * 300)
        //print(tester1)
        let tester2 = 300 - tester1
        //print(tester2)
        
        lbl_RoundTime.text = String(tester2)
        
        if tester2 == 0 {
        print("updateTimerRound")
        roundsCompleted = roundsCompleted + 1
            
            Totals.arrHRTotal.append(Rounds.avg_hr)
            AllRounds.arrHR.append(Rounds.avg_hr)
            AllRounds.arrSPD.append(Rounds.avg_speed)
            AllRounds.arrCAD.append(Rounds.avg_cadence)
            
            Rounds.distanceRound = 0
            Rounds.totalWheelEventTime = 0
            Rounds.arrHRRound = []
            Rounds.crankRevolutionTime = 0
            Rounds.crankRevolutions = 0
            lbl_Speed.text = "..."
            lbl_Cadence.text = "..."
            lbl_Heartrate.text = "..."
            lbl_Score.text = "..."
            
            
            updateTimerRound()
        }
        
        if tester2 < 0 {
        print("negative tester2, hmmm")
            Rounds.roundStartTime = x
            roundsCompleted = roundsCompleted + 1
            print("roundsCompleted:  \(roundsCompleted)")
            
            Totals.arrHRTotal.append(Rounds.avg_hr)
            AllRounds.arrHR.append(Rounds.avg_hr)
            AllRounds.arrSPD.append(Rounds.avg_speed)
            AllRounds.arrCAD.append(Rounds.avg_cadence)
            
            Rounds.distanceRound = 0
            Rounds.totalWheelEventTime = 0
            Rounds.arrHRRound = []
            Rounds.crankRevolutionTime = 0
            Rounds.crankRevolutions = 0
            lbl_Speed.text = "..."
            lbl_Cadence.text = "..."
            lbl_Heartrate.text = "..."
            lbl_Score.text = "..."
            updateTimerRound()
        }
        

        if tester2 == 290 && roundsCompleted > 0 {
            self.str = "Round complete!  Your speed for the last round Speed was \(String(format:"%.2f", Rounds.avg_speed)).  Your score for the last round was \(String(format:"%.1f", Rounds.avg_score))"
            mySpeaker()
        }

        
        Rounds.avg_score = Rounds.avg_hr / Device.maxHR * 100
        lbl_total_hr.text = "\(String(format:"%.1f", Totals.avg_hr)) Bpm"
        lbl_total_speed.text = "\(String(format:"%.1f", Totals.avg_speed)) Mph"
        
        Totals.arrHRTotal.append(Device.currentHeartrate)
        Rounds.arrHRRound.append(Device.currentHeartrate)
        Rounds.avg_hr = Rounds.arrHRRound.reduce(0.0) {
            return $0 + $1/Double(Rounds.arrHRRound.count)
        }
        Totals.avg_hr = Totals.arrHRTotal.reduce(0.0) {
            return $0 + $1/Double(Totals.arrHRTotal.count)
        }
        self.lbl_round_speed.text = "\(String(describing: String(self.roundLeaderName)))"  //leader name
        self.lbl_round_hr.text = "\(String(format:"%.1f",  self.roundLeaderScore)) %MAX"  //leader score
        
        
        if tester2 == 150 {
            self.str = "Midway"
            mySpeaker()
        }
        
//        if tester1 == 240 {
//            self.str = "Beep"
//            mySpeaker()
//        }
//        if tester1 == 180 {
//            self.str = "Beep"
//            mySpeaker()
//        }
//        if tester1 == 120 {
//            self.str = "Beep"
//            mySpeaker()
//        }
//        if tester1 == 60 {
//            self.str = "Beep"
//            mySpeaker()
//        }
        

//        if intRoundCurrentTimeElapsed == 300 {
//            print("updateTimerRound")
//            Rounds.roundStartTime = x
//            updateTimerRound()
//        }
        

        
        
//        eachSecondUpdateFctn()
        
    }
        
        

//        if newtimeTimes10 % 100 == 0  {
//            
//            eachSecondUpdateFctn()
//        }

//        if newtimeTimes10 % 6000 == 0 {
//            print("Each Minute")
//            //lbl_button_start.setTitle(" 🔴🔴🔴🔴", for: .normal)
//        }
        
//        if timeNewMS == (121 * 1000) {
//            lbl_button_start.setTitle("  🔴🔴🔴", for: .normal)
//        }
//        if timeNewMS == (181 * 1000) {
//            lbl_button_start.setTitle("   🔴🔴", for: .normal)
//        }
//        if timeNewMS == (241 * 1000) {
//            lbl_button_start.setTitle("   🔴", for: .normal)
//        }
//        if timeNewMS == (271 * 1000) {
//            lbl_button_start.setTitle(" 🕙🕙🕙", for: .normal)
//        }
//        if timeNewMS == (281 * 1000) {
//            lbl_button_start.setTitle("  🕙🕙", for: .normal)
//        }
        
        
//        if newtimeTimes10 % 29000 == 0 {
//            lbl_button_start.setTitle("   🕙", for: .normal)
//        }
        
//        if newtimeTimes10 % 30000 == 0 {
//            print("300 Seconds Elapsed")
//            updateTimerRound()
//        }
        

    
    
    func dockView1_open() {

        //AllRounds.arrSPD.last!
//        dock1_lastSpeed.text = "\(String(format:"%.2f", Rounds.avg_speed))"
//        dock1_lastScore.text = "\(String(format:"%.1f", Rounds.avg_score))"
//        dock1_lastCadence.text = "\(String(format:"%.1f", Rounds.avg_cadence))"
        
        dock1_lastSpeed.text = "\(String(format:"%.2f", AllRounds.arrSPD.last!))"
        dock1_lastScore.text = "\(String(format:"%.1f", AllRounds.arrHR.last! / Device.maxHR * 100))"
        dock1_lastCadence.text = "\(String(format:"%.1f", AllRounds.arrCAD.last!))"
        
        
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
            // disconnect directly
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
                        return
                    }
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristicCSC) {
                        peripheral.setNotifyValue(false, for: characteristic)
                        
                        



                        
                        return
                    }
                }
            }
        }
        // disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
        Rounds.avg_speed = 0
        Rounds.avg_cadence = 0
        Rounds.avg_score = 0
        Rounds.avg_hr = 0
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
        print("didDisconnectPeripheral")
        // verify we have a peripheral
        
        alert(message: "Please rescan and connect to your Bluetooth Sensor", title: "BLE Sensor STOPPED")
        BleDisconnectSpeaker()
        
        
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
            // disconnect directly
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        for service in services {
            // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Device struct
                    if characteristic.uuid == CBUUID.init(string: Device.TransferCharacteristic) {
                        // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                        // didUpdateNotificationStateForCharacteristic method will be called automatically
                        peripheral.setNotifyValue(false, for: characteristic)
                        return
                    }
                }
            }
        }
        // We have a connection to the device but we are not subscribed to the Transfer Characteristic for some reason.
        // Therefore, we will just disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
        Rounds.avg_speed = 0
        Rounds.avg_cadence = 0
        Rounds.avg_score = 0
        Rounds.avg_hr = 0
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Peripheral Connected!!!")
        
        // IMPORTANT: Set the delegate property, otherwise we won't receive the discovery callbacks, like peripheral(_:didDiscoverServices)
        peripheral.delegate = self
        
        // Now that we've successfully connected to the peripheral, let's discover the services.
        // This time, we will search for the transfer service UUID
        print("Looking for Transfer Service...")
        peripheral.discoverServices([CBUUID.init(string: Device.TransferService), CBUUID.init(string: Device.TransferServiceCSC)])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            //self.dataBuffer.length = 0
        })
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
                }
                if characteristic.uuid == CBUUID(string: Device.TransferCharacteristicCSC) {
                    // subscribe to dynamic changes
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    

    
    var zeroTesterSpeed     : Double = 0
    var zeroTester          : Double = 0
    
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
                var bpmValue : Int = 0;
                if ((array[0] & 0x01) == 0) {
                    bpmValue = Int(array[1])
                } else {
                    //Convert Endianess from Little to Big
                    bpmValue = Int(UInt16(array[2] * 0xFF) + UInt16(array[1]))
                }
                
                Device.currentHeartrate = Double(bpmValue)
                //MARK:  CURRENT HR
                return bpmValue
            }
            
            let newValue = decodeHRValue(withData: characteristic.value!)
            //print(newValue)

            
            if newValue < 100 {
                lbl_Heartrate.text = "0\(String(newValue))"
//                lbl_Score.text = "\(String(Int((round(Double(newValue) / 185 * 100)))))"
//                lbl_Score.text = "\(String(Int(Rounds.avg_score)))"
                lbl_Score.text = "\(String(format:"%.1f", Rounds.avg_score))"
            } else {
                lbl_Heartrate.text = "\(String(newValue))"
//                lbl_Score.text = "\(String(Int((round(Double(newValue) / 185 * 100)))))"
//                lbl_Score.text = "\(String(Int(Rounds.avg_score)))"
                lbl_Score.text = "\(String(format:"%.1f", Rounds.avg_score))"

            }
            
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
            
            

            
            
           
            func processWheelData(withData data :Data) -> Double {

                var wheelRevolution     :Double = 0
                var wheelEventTime      :Double = 0
                var wheelRevolutionDiff :Double = 0
                var wheelEventTimeDiff  :Double = 0
                
                var travelDistance      :Double = 0
                //var travelSpeed         :Double = 0
                
                var newWheelRevs        :UInt32 = 0
                var newWheelRevsTime    :UInt16 = 0
                


                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))

                //using newWheelRevs and newWheelTime
                newWheelRevs = UInt32(CFSwapInt32LittleToHost(UInt32(value[1])))
                newWheelRevsTime = (UInt16(value[6]) * 0xFF) + UInt16(value[5])
                let val2 = UInt32(CFSwapInt32LittleToHost(UInt32(value[2])))
                
                
                
                //wheelRevolution = Double(newWheelRevs)
                wheelEventTime = Double(newWheelRevsTime)
                wheelRevolution = Double(Double(newWheelRevs) + (255 * Double(val2)))
                
                
//                print("wheelRevolution and wheelEventTime")
//                print(wheelRevolution, wheelEventTime)
                
                
                if Device.oldWheelRevolution > 0 {  //test for first time reading
 
//                        let wheelRevsDelta: UInt32 = deltaWithRollover(UInt32(newWheelRevs), old: UInt32(Device.oldWheelRevolution), max: 255)
//                        let wheelTimeDelta: UInt16 = deltaWithRollover(UInt16(newWheelRevsTime), old: UInt16(Device.oldWheelEventTime), max: UInt16.max)
                    
//                        wheelRevolutionDiff = Double(wheelRevsDelta)
//                        wheelEventTimeDiff = Double(wheelTimeDelta / 1024)

                    let a = wheelRevolution - Device.oldWheelRevolution
                    let b = wheelEventTime - Device.oldWheelEventTime
                    
                    
//                    print("wheelRevDiff and wheelTimeDiff")
//                    print(a, b)
                    
                    if a >= 0 && b >= 0 {
                        wheelRevolutionDiff = a
                        wheelEventTimeDiff = b / 1024
                        
                        travelDistance = wheelRevolutionDiff * Device.wheelCircumference! / 1000 * 0.000621371  //segment, in miles
                        Totals.totalWheelEventTime = Totals.totalWheelEventTime + wheelEventTimeDiff  //use actual time
                        Rounds.totalWheelEventTime = Rounds.totalWheelEventTime + wheelEventTimeDiff  //use actual time
                        
                        Totals.distanceTotal = Totals.distanceTotal + travelDistance
                        Rounds.distanceRound = Rounds.distanceRound + travelDistance
                        
                        ctDistance = ctDistance + travelDistance
                        lbl_Distance.text = "\(String(format:"%.2f", Rounds.distanceRound)) Mi & \(String(format:"%.2f", Totals.distanceTotal)) Mi"
                        
                        
                        //theTravelSpeed = Double(Double(travelDistance) / Double(Double(wheelEventTimeDiff) / 60.0 / 60.0)) //miles/hour
                        Device.currentSpeed = Double(Double(travelDistance) / Double(Double(wheelEventTimeDiff) / 60.0 / 60.0)) //miles/hour


                        
                        Totals.avg_speed = Totals.distanceTotal / (Totals.totalWheelEventTime / 60 / 60)
                        Rounds.avg_speed = Rounds.distanceRound / (Rounds.totalWheelEventTime / 60 / 60)
                        
                        if Rounds.avg_speed > 0 && Rounds.avg_speed < 55 {
                            lbl_Speed.text = "\(String(format:"%.1f", Rounds.avg_speed))"
                        }
                        
                    }
                    
                }

                Device.oldWheelRevolution = Double(wheelRevolution)  //changed from newWheelRevs
                Device.oldWheelEventTime = Double(newWheelRevsTime)
                return 999
            }

            func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) -> Double {
                
                var crankEventTime      : Double = 0
                var crankRevolutionDiff : Double = 0
                var crankEventTimeDiff  : Double = 0
                var crankRevolution     : Double = 0
                var travelCadence       : Double = 0
                
                
                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
                
                crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
                crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
                
                
                if Device.oldCrankRevolution > 0 {  //test for first time reading
                    if Device.oldCrankRevolution == crankRevolution && Device.oldCrankEventTime == crankEventTime { //test for 0 cadence
                        //print("Current Cadence is 0")
                        travelCadence = 0
                    } else {
                        
                        if Device.oldCrankRevolution > crankRevolution || Device.oldCrankEventTime > crankEventTime { //ignore readings when counter resets
                            //print("reset counter, ignore")
                        } else {
                            crankRevolutionDiff = crankRevolution - Device.oldCrankRevolution
                            crankEventTimeDiff = (((crankEventTime - Device.oldCrankEventTime) / 1024))
                            travelCadence = crankRevolutionDiff/crankEventTimeDiff*60
                            
                            Rounds.crankRevolutions = Rounds.crankRevolutions + crankRevolutionDiff
                            Rounds.crankRevolutionTime = Rounds.crankRevolutionTime + crankEventTimeDiff
                            
                        }
                    }
                    if travelCadence == 0 && zeroTester == 0 {
                        zeroTester += 1
                        
                    } else {
//                        lbl_Cadence.text = "\(String(format:"%.f", travelCadence))"
                        let x = Rounds.crankRevolutions/Rounds.crankRevolutionTime*60
                        //print(x)
                        
                        if travelCadence > 0 {
                            lbl_Cadence.text = "\(String(format:"%.f", x))" //round cadence
                            Rounds.avg_cadence = x
                        }

                        
                        zeroTester = 0
                        Device.currentCadence = travelCadence
                        //MARK:  CURRENT CADENCE
                    }
                }
                Device.oldCrankRevolution = crankRevolution
                Device.oldCrankEventTime = crankEventTime
                return 999
                
            }
            
            func decodeCSC(withData data : Data) -> Double {
                let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
                //    var wheelRevDiff :Double = 0
                //    var crankRevDiff :Double = 0
                var returnedCadence : Double = 0
                var returnedSpeed   : Double = 0
                //var returnedSpeedII   : Double = 0
                let flag = value[0]
                
                //print((returnedSpeed) + (returnedCadence))
                if returnedSpeed == 10000 {
                    //print((returnedSpeed) + (returnedCadence))
                }
                
                if flag & Device.WHEEL_REVOLUTION_FLAG == 1 {
                    returnedSpeed = processWheelData(withData: data)
                    //returnedSpeedII = processWheelDataII(withData: data)
                    //print(returnedSpeed)
                    if flag & 0x02 == 2 {
                        returnedCadence = processCrankData(withData: data, andCrankRevolutionIndex: 7)
                        if returnedCadence == 2000 {print(returnedCadence)}
                    }
                } else {
                    if flag & Device.CRANK_REVOLUTION_FLAG == 2 {
                        returnedCadence = processCrankData(withData: data, andCrankRevolutionIndex: 1)
                        //print(returnedCadence)
                    }
                }
                return 0 //use later for testing to display or remove
            }
            
            
            
            func deltaWithRollover<T: Integer>(_ new: T, old: T, max: T) -> T {
                return old > new ? max - old + new : new - old
            }
            
            
            
            

            
            let x = decodeCSC(withData: characteristic.value!)
            if x == 100 {
                //print(x)
            }
               
            
        }
    }
    
    
    
    
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
        }
        
            }
    
    
//    func httpGetTotals() {
//        
//        totalLeaderScore = 0
//        totalLeaderName = "..."
//        namesArrayTotal = []
//        speedsArrayTotal = []
//        scoresArrayTotal = []
//
//        print("httpGetTotals Started")
//        
//        //let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/totals/20170513/IOS.json"
//        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/totals/" + Settings.dateToday + ".json"
//        let url = NSURL(string: todosEndpoint)
//
//        if ConnectionCheck.isConnectedToNetwork() {
//        
//        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
//            
//            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
//                print(jsonObj as Any)
//                
//                if jsonObj == nil {
//                    return
//                }
//                
//                for (key, _) in jsonObj! {
//                    //print("key \(key)")
//                    
//                    if let nestedDictionary = jsonObj?[key] as? [String: Any] {
//                        
//                        for(key, _) in nestedDictionary {
//                            //print("key \(key)")
//                            
//                            if key == "fb_scoreHRTotal" {
//                                //print("key == fb_scoreHRTotal")
//                                
//                                self.namesArrayTotal.append(nestedDictionary["fb_timName"] as! String!)
//                                self.speedsArrayTotal.append(nestedDictionary["fb_timAvgSPDtotal"] as! Double!)
//                                self.scoresArrayTotal.append(nestedDictionary["fb_scoreHRTotal"] as! Double!)
//                                let x = nestedDictionary["fb_scoreHRTotal"] as! Double!
//                                //print(x!)
//                                if x! > self.totalLeaderScore {
//                                    //print(x!)
//                                    self.totalLeaderScore = x!
//                                    let y = nestedDictionary["fb_timName"] as! String!
//                                    self.totalLeaderName = y!
//                                    //print(x!, y!)
//                                }
//                                
//                                let xx = nestedDictionary["fb_timAvgSPDtotal"] as! Double!
//                                //print(x!)
//                                if xx! > self.totalLeaderSpeed {
//                                    //print(x!)
//                                    self.totalLeaderSpeed = xx!
//                                    let yy = nestedDictionary["fb_timName"] as! String!
//                                    self.totalLeaderNameSpeed = yy!
//                                    //print(xx!, yy!)
//                                }
//                            }
//                        }
//                    }
//                }
//                //at the end
//                print(self.totalLeaderName, self.totalLeaderScore)
//                print(self.namesArrayTotal)
//                print(self.scoresArrayTotal)
//                print(self.speedsArrayTotal)
//                
//            }
//        }).resume()
//            
//        }
//    }
    

        
                
                
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
                


        
        

    
    func httpPost() {
    
//        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/20170513.json"
        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/" + Settings.dateToday + ".json"
        guard let todosURL = URL(string: todosEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "POST"
        
        let aa = AllRounds.arrHR.last
        let ab = aa! / Device.maxHR * 100
        let xx = "\(String(format:"%.1f", aa!))"
        let yy = "\(String(format:"%.1f", AllRounds.arrSPD.last!))"
        let zz = "\(String(format:"%.1f", ab))"
        
        
        
//        let a = Rounds.avg_hr / Device.maxHR * 100
//        let x = "\(String(format:"%.1f", Rounds.avg_hr))"
//        let y = "\(String(format:"%.1f", Rounds.avg_speed))"
//        let z = "\(String(format:"%.1f", a))"
        
        let newTodo: [String: Any] = [
            "a_scoreRoundLast": Double(zz) ?? 0,
            "a_speedRoundLast": Double(yy) ?? 0,
            "a_cadenceRoundLast": 1,
            "a_heartrateRoundLast": Double(xx) ?? 0,
            "a_calcDurationPost": Totals.displayedTime,
            "a_timName": Settings.riderName,
            "a_timGroup": "IOS",
            "a_timTeam": "Square Pizza",
            "a_Date": Settings.dateToday,
            "a_DateNow": Settings.dateToday,
            "a_lastCAD": 1,
            "a_lastHR": Double(xx) ?? 0,
            "a_timDistanceTraveled": 1,
            "a_maxHRTotal": Double(Device.maxHR) ,
            "fb_CAD":0,
            "fb_Date":Settings.dateToday,
            "fb_DateNow":"1494517025335",
            "fb_HR":Double(xx) ?? 0,
            "fb_RND":Double(zz) ?? 0,
            "fb_SPD":Double(yy) ?? 0,
            "fb_maxHRTotal":Device.maxHR,
            "fb_scoreHRRound":Double(zz) ?? 0,
            "fb_scoreHRRoundLast":Double(zz) ?? 0,
            "fb_scoreHRTotal":Double(zz) ?? 0,
            "fb_timAvgCADtotal":0,
            "fb_timAvgHRtotal":0,
            "fb_timAvgSPDtotal":0,
            "fb_timDistanceTraveled":0,
            "fb_timGroup":"IOS",
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





