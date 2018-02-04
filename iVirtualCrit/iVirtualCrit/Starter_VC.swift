//
//  Starter_VC.swift
//  iVirtualCrit
//
//  Created by aaronep on 1/28/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AudioToolbox
import Firebase

extension String {
    var toDouble: Double {
        return Double(self) ?? 0.0
    }
}

//USED FOR VIEWER_VC
var arr = [String]()
var arrSend = [String]()

//USED FOR HISTORY_VC
var arrResults = [String]()
var arrResultsDetails = [String]()

var la: Double = 0
var lo: Double = 0


class Starter_VC: UITableViewController {
    

    @IBOutlet weak var statusValue: UILabel!
    
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var gpsMovingTime: UILabel!
    @IBOutlet weak var gpsMovingPace: UILabel!
    @IBOutlet weak var gpsMovingSpeed: UILabel!
    @IBOutlet weak var gpsAverageSpeed: UILabel!
    @IBOutlet weak var gpsAvergagePace: UILabel!
    @IBOutlet weak var gpsDistance: UILabel!
    @IBOutlet weak var gpsDirection: UILabel!
    @IBOutlet weak var gpsRoundSpeed: UILabel!
    
    @IBOutlet weak var btHR: UILabel!
    @IBOutlet weak var btMovingSpeed: UILabel!
    @IBOutlet weak var btMovingCadence: UILabel!
    @IBOutlet weak var btScore: UILabel!
    @IBOutlet weak var btMovingTime: UILabel!
    @IBOutlet weak var btDistance: UILabel!
    @IBOutlet weak var btMovAvg: UILabel!
    @IBOutlet weak var gpsStatus: UILabel!
    @IBOutlet weak var tDisplayVal: UILabel!
    
    var availableDataElementsToView = ["Total Elapsed Time", "GPS Moving Time", "GPS Speed", "GPS Average Speed", "GPS Average Pace", "GPS Direction", "GPS Speed - Round", "GPS Pace - Round", "GPS Distance", "Heartrate", "Speed", "Cadence", "%MAX Heartrate", "Pace", "Heartrate - Round", "Speed - Round", "Cadence - Round", "%MAX Heartrate - Round", "Pace - Round", "Distance", "Average Speed", "Average Pace", "Moving Time"]
    
    
    var timer = Timer()
    var timerIntervalValue: Double = 1
 
    var inRoundGeoDistance: Double = 0
    var roundsCompleted: Int = 0
    var secondsPerRound: Int = 300
    var roundGeoSpeed: Double = 0
    var roundSpeed: Double = 0
    
    func newMilePoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(mileString)", "color": "green"])
    }
    
    func newRoundPoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(mileString)", "color": "yellow"])
    }
    
    
    
    var actualTimeAtMileStart: Date?
    var timeElapsedForLastMile: Double = 0
    var currentMile: Double = 1.0
    var speedForLastMile: Double = 0
    var paceForLastMile: Double = 0
    var fastestMile: Double = 0 //MPH
    
    func updateMile() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        timeElapsedForLastMile = getTimeIntervalSince(d1: actualTimeAtMileStart!, d2: Date())
        speedForLastMile = 1.0 / (Double(timeElapsedForLastMile) / 60 / 60)
        
        if speedForLastMile > fastestMile {
            fastestMile = speedForLastMile
            
            if audioStatus == "ON" {
                Utils.shared.say(sentence: "Fastest Mile is now.  \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.")
            }
            
        }
        
        
        newMilePoint(mileString: "\(stringer(dbl: (currentMile - 1), len: 0)) MILES\n\(stringer(dbl: speedForLastMile, len: 1)) MPH\n\(calcMinPerMile(mph: speedForLastMile)) PACE\n\(stringer(dbl: fastestMile, len: 1)) FASTEST MILE")
        
        actualTimeAtMileStart = Date()
    }
    
    var bestRoundSpeed: Double = 0
    var bestRoundHR: Double = 0
    var bestRoundCadence: Double = 0
    var bestRoundScore: Double = 0
    var bestRoundPace: String = ""
    
    func createNRArray() {
        if roundsCompleted > 0  {
            
            let a = "ROUND # \(roundsCompleted)  "
            let b = "\(stringer(dbl: roundHR, len: 1)) HR"
            let c = "  \(stringer(dbl: (roundHR / Double(maxHRvalue) * 100), len: 1))%"
            let d = "  \(stringer(dbl: roundSpeed, len: 1))  MPH/BT"
            let e = "  \(stringer(dbl: roundCadence, len: 1)) RPM"
            let f = "  \(stringer(dbl: roundGeoSpeed, len: 1))  MPH/GEO"
            
            var spdToUse = roundSpeed
            if roundSpeed < roundGeoSpeed {spdToUse = roundGeoSpeed}
            
            fbPush(rSpeed: "\(stringer(dbl: spdToUse, len: 2))", rHeartrate: "\(stringer(dbl: roundHR, len: 1))", rScore: "\(stringer(dbl: (roundHR / Double(maxHRvalue) * 100), len: 1))", rCadence: "\(stringer(dbl: roundCadence, len: 1))")
            
            if roundSpeed > bestRoundSpeed {bestRoundSpeed = roundSpeed}
            if roundGeoSpeed > bestRoundSpeed {bestRoundSpeed = roundGeoSpeed}
            if roundCadence > bestRoundCadence {bestRoundCadence = roundCadence}
            if roundHR > bestRoundHR {bestRoundHR = roundHR}
            bestRoundScore = (bestRoundHR / Double(maxHRvalue)) * 100
            bestRoundPace = calcMinPerMile(mph: bestRoundSpeed)
            
            //MY BEST ROUNDS POINT
            newRoundPoint(mileString: "MY BEST ROUNDS\n\(stringer(dbl: bestRoundSpeed, len: 1)) SPEED\n\(stringer(dbl: bestRoundCadence, len: 1)) CADENCE\n\(stringer(dbl: bestRoundHR, len: 1)) HR\n\(stringer(dbl: bestRoundScore, len: 1)) SCORE\n\(bestRoundPace) PACE\n")
            
            arrResults.append("\(a)\(b)\(c)")
            arrResultsDetails.append("\(d)\(e)\(f)")
            
            print("\n");
            dump(arrResults)
            dump(arrResultsDetails)
            print("\n");
            
            if audioStatus == "ON" {
                Utils.shared.say(sentence: "Round Complete, \(stringer(dbl: spdToUse, len: 1)) Miles Per Hour.  \(stringer(dbl: (roundHR / Double(maxHRvalue) * 100), len: 0)) PERCENT OF MAX.  ")
            }
            
            
        }

    }  //end nrarray
    
    func stopAndSave() {
        //save
        //REMOVE OLD HISTORY
        udArray = []
        udArray.append(udString)
        let defaults = UserDefaults.standard
        defaults.set(udArray, forKey: "SavedStringArray")
    }
    
    func presentHistory() {
        dump(udArray)
    }
    
    func updateViewer_VC() {
        
        if geo.status == "ON/USE" {
            
            //HEADER
            if geo.distance < 0.1 {
                arr.append("\(getFormattedTime(d: Date()))")
            } else {
             arr.append("\(gpsMovingTime.text ?? "00:00:00")  \(gpsAverageSpeed.text ?? "00.0 AVG") AVG MPH")
            }
            
            
            //3 VALUES
            if btHR.text == " " {arr.append("\(gpsAvergagePace.text ?? "00")")} else {arr.append("\(btHR.text ?? "00")")}
            
            arr.append("\(gpsMovingSpeed.text ?? "00.0")")
            arr.append("\(gpsMovingPace.text ?? "00")")
            //3 LABELS
            if btHR.text == " " {arr.append("PACE\n(AVG)")} else {arr.append("\(btScore.text ?? "00")")}
            
            arr.append("SPD\nMPH")
            arr.append("PACE\n(MOV)")
            //FOOTER
            arr.append("\(totalTime.text ?? "00:00:00")  \(gpsDistance.text ?? "0.00 MILES")")
            arrSend = arr
            arr = []
            
        } else {
           
            //HDR
            arr.append("\(btMovingTime.text ?? "00:00:00")  \(btMovAvg.text ?? "00.0 AVG")")
            //3 VALS
            arr.append("\(btHR.text ?? "00")")
            arr.append("\(btMovingSpeed.text ?? "00.0")")
            arr.append("\(btMovingCadence.text ?? "00")")
            //3 LBLS
            arr.append("\(btScore.text ?? "00")\nHR")
            arr.append("SPD\nMPH")
            arr.append("CAD\nRPM")
            //FOOTER
            arr.append("\(totalTime.text ?? "00:00:00")  \(btDistance.text ?? "0.00 MILES")")
            arrSend = arr
            arr = []
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("viewUpdate"), object: nil)
    }
    
    //EACH SECOND
    @objc func timerInterval() {

        if inRoundBtDistance > 0 {
            roundSpeed = inRoundBtDistance / Double((system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) / 60.0 / 60.0)
        }
        //print("roundSpeed:  \(roundSpeed)")
        
//        if system.actualElapsedTime != nil {
//
//        }
        
        if btDistanceForMileCalc > currentMile || geo.distance > currentMile {
            currentMile += 1.0
            updateMile()
        }
        
        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        totalTime.text = "\(  createTimeString(seconds: Int(round(system.actualElapsedTime!))))" //[ACTUAL ELAPSED TIME]
        
        //ROUND END
        if  system.actualElapsedTime! >= Double((roundsCompleted + 1) * secondsPerRound) {
            print("New Round")
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            roundsCompleted += 1
            
            rounds.geoDistancesPerRound.append(inRoundGeoDistance)
            rounds.btDistancesPerRound.append(inRoundBtDistance)

//            print("\n")
//            print("End of Round for HR, Spd, Cad, GeoSpd")
//            print(roundHR, roundSpeed, roundCadence, roundGeoSpeed)
//            print("\n")
            createNRArray()
            
            let tle = "ROUND COMPLETE"
            let clr = "blue"
            
            
               NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(tle) \n", "color": "\(clr)", "geospeed": stringer(dbl: roundGeoSpeed, len: 2),"hr": stringer(dbl: roundHR, len: 1), "score": stringer(dbl: (roundHR / (Double(maxHRvalue)) * 100.0), len: 1),"pace": (calcMinPerMile(mph: roundGeoSpeed)),"cadence": stringer(dbl: roundCadence, len: 1), "geodistance": stringer(dbl: geo.distance, len: 2), "btdistance": stringer(dbl: btDistanceForMileCalc, len: 2), "speed": stringer(dbl: roundSpeed, len: 2)])
            
            rounds.speeds.append(roundSpeed)
            rounds.geoSpeeds.append(roundGeoSpeed)
            rounds.heartrates.append(roundHR)
            rounds.scores.append(Double(roundHR/Double(maxHRvalue)*100))
            rounds.cadences.append(roundCadence)
            
            print("\n")
            print("End of Round for HR, Spd, Cad, GeoSpd")
            dump(rounds.speeds)
            dump(rounds.heartrates)
            dump(rounds.cadences)
            dump(rounds.geoSpeeds)
            print("\n")
            //print("btAvgSpeed:  \(stringer(dbl: btAverageSpeed, len: 2))")
            print("\n")
            
            inRoundGeoDistance = 0
            inRoundBtDistance = 0
            inRoundCadence = []
            inRoundHR = []
        }
        
        if Int(system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) == Int((Double(secondsPerRound) * (0.2))) {
            let _ = fb1()
        }
        if Int(system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) == Int((Double(secondsPerRound) * (0.4))) {
            let _ = fb2()
        }
        if Int(system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) == Int((Double(secondsPerRound) * (0.6))) {
            let _ = fb3()
        }
        if Int(system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) == Int((Double(secondsPerRound) * (0.8))) {
            let _ = fb4()
        }
        
        //MID ROUND - DAILY UPDATE
        if Int(system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) == (secondsPerRound / 2) {

            let tle = "DAILY UPDATE"
            let clr = "red"
            
            NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"),
                object: nil, userInfo: ["title": "\(tle) \n", "color": "\(clr)",
                    "geodistance": stringer(dbl: geo.distance, len: 2),
                    "btdistance": stringer(dbl: btDistanceForMileCalc, len: 2),
                    "totaltime": totalTime.text as Any,
                    "btmovingtime": btMovingTime.text as Any,
                    "avgspeed": btMovAvg.text as Any,
                    "gpsmovingtime": gpsMovingTime.text as Any,
                    "avgspeedgeo": gpsAverageSpeed.text as Any])
            
                }
        
        if roundSpeed > 0 {
            btSpdRnd.text = stringer(dbl: roundSpeed, len: 1)
        }
        if roundCadence > 0 {
            btCadRnd.text = stringer(dbl: roundCadence, len: 0)
        }
        if roundHR > 0 {
            btHrRnd.text = stringer(dbl: roundHR, len: 0)
            btScoreRnd.text = stringer(dbl: roundHR/Double(maxHRvalue)*100, len: 1)
        }

        
        updateViewer_VC()
        
    }  //END SECOND TIMER
    
    
    @IBOutlet weak var btSpdRnd: UILabel!
    @IBOutlet weak var btCadRnd: UILabel!
    @IBOutlet weak var btHrRnd: UILabel!
    @IBOutlet weak var btScoreRnd: UILabel!
    
    
    @objc func updateBT(not: Notification) {
//        print("updateBT")
//        print("not:  \(not)")
        // userInfo is the payload send by sender of notification
        if let userInfo = not.userInfo {
            //print(userInfo[AnyHashable("hr")]!)
            if let hrv = userInfo[AnyHashable("hr")] {
                //print(String(describing: userInfo[AnyHashable("hr")]!))
                btHR.text = "\(hrv as! String)"  //HR
                tabBarController?.tabBar.items?[0].badgeValue = "\(hrv as! String)"
            }
            if let scv = userInfo[AnyHashable("score")] {
                //print(String(describing: userInfo[AnyHashable("score")]!))
                btScore.text = "\(scv as! String) %"
                tabBarController?.tabBar.items?[3].badgeValue = "\(scv as! String)%"
            }
            if let spv = userInfo[AnyHashable("spd")] {
                //print(String(describing: userInfo[AnyHashable("spd")]!))
                btMovingSpeed.text = "\(spv as! String)"//SPD BT
                tabBarController?.tabBar.items?[1].badgeValue = "\(spv as! String)"
            }
            if let cav = userInfo[AnyHashable("cad")] {
                //print(String(describing: userInfo[AnyHashable("cad")]!))
                btMovingCadence.text = "\(cav as! String)"  //   CAD BT"
                tabBarController?.tabBar.items?[2].badgeValue = "\(cav as! String)"
            }
            if let dsv = userInfo[AnyHashable("dist")] {
                btDistance.text = "\(dsv as! String) MILES"  //DISTANCE BT
                //btDistanceForMileCalc = dsv as! Double
            }
            if let mtv = userInfo[AnyHashable("mov")] {
                btMovingTime.text = "\(mtv as! String)"   //MOVING TIME BT
            }
            if let mvavg = userInfo[AnyHashable("mov_avg")] {
                btMovAvg.text = "\(mvavg as! String) AVG"  //MOV AVG
            }

        }
    }
    
    
    @IBOutlet weak var lblRiderName: UILabel!
    
    func showInputDialog() {
        
        let alertController = UIAlertController(title: "Rider Name", message: "", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let name = alertController.textFields?[0].text
            self.lblRiderName.text = name!.uppercased()
            self.riderName = name!.uppercased()
            print("riderName:  \(self.riderName)")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = self.riderName
        }

        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    var riderName: String = "TIM"
    var activityType: String = "BIKE"
    var audioStatus: String = "OFF"
    @IBOutlet weak var lblTireSize: UILabel!
    @IBOutlet weak var lblMaxHeartrateValue: UILabel!
    
    @IBOutlet weak var lblSecPerRound: UILabel!
    @IBOutlet weak var lblActivityType: UILabel!
    
    @IBOutlet weak var lblAudioStatus: UILabel!
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        
        switch indexPath.row {
        case 1:
            print("Start/Stop/Reset")
            if system.status == "STOPPED" {
                system.status = "STARTED";statusValue.text = "STARTED";
                system.startTime = Date()
                
                if geo.status == "ON" {
                    geo.startTime = Date()
                    startLocationUpdates()
                }
                
                if geo.status == "ON/USE" {
                    geo.startTime = Date()
                    startLocationUpdates()
                }
                
                timer = Timer.scheduledTimer(timeInterval: timerIntervalValue,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
                print("Started")
                print(getFormattedTime(d: system.startTime!))
                print(getFormattedTimeAndDate(d: system.startTime!));print("\n");
                
                NotificationCenter.default.addObserver(self, selector: #selector(updateBT(not:)), name: Notification.Name("bleUpdate"), object: nil)
                
                actualTimeAtMileStart = system.startTime
            } else {
                system.status = "STOPPED";statusValue.text = "STOPPED";
                system.stopTime = Date()
                print("Stopped")
                print(getFormattedTime(d: system.stopTime!))
                print(getFormattedTimeAndDate(d: system.stopTime!));print("\n");
                print(getTimeIntervalSince(d1: system.startTime!, d2: system.stopTime!));print("\n");
                timer.invalidate()
                stopLocationUpdates()
                stopAndSave()
            }
        case 2:
            let gst = geo.status
            if gst == "ON" {geo.status = "ON/USE";gpsStatus.text = "ON/USE";startLocationUpdates();}
            if gst == "ON/USE" {geo.status = "OFF";gpsStatus.text = "OFF";stopLocationUpdates()}
            if gst == "OFF" {geo.status = "ON";gpsStatus.text = "ON";startLocationUpdates()}
        case 3:
            //ble
            self.tabBarController?.selectedIndex = 1
        case 5:
            showInputDialog()
        case 6:
            let at = activityType
            if at == "BIKE" {activityType = "RUN";lblActivityType.text = "RUN";}
            if at == "RUN" {activityType = "ROW";lblActivityType.text = "ROW";}
            if at == "ROW" {activityType = "BIKE";lblActivityType.text = "BIKE";}
        case 7:
            if lblAudioStatus.text == "OFF" {audioStatus = "ON";lblAudioStatus.text = "ON"} else {audioStatus = "OFF";lblAudioStatus.text = "OFF"}
        case 8:
            let hrz = maxHRvalue
            if hrz == 185 {maxHRvalue = 190;lblMaxHeartrateValue.text = "190";}
            if hrz == 190 {maxHRvalue = 195;lblMaxHeartrateValue.text = "195";}
            if hrz == 195 {maxHRvalue = 200;lblMaxHeartrateValue.text = "200";}
            if hrz == 200 {maxHRvalue = 185;lblMaxHeartrateValue.text = "185";}
            print("Max HR:  \(maxHRvalue)")
            
        case 9:
            let tsz = wheelCircumference
            if tsz == 2105 {lblTireSize.text = "700X26";wheelCircumference = 2115;}
            if tsz == 2115 {lblTireSize.text = "700X32";wheelCircumference = 2155;}
            if tsz == 2155 {lblTireSize.text = "700X25";wheelCircumference = 2105;}
            print("WheelCir:  \(wheelCircumference)")
        case 12:
            if lblSecPerRound.text == "60"{secondsPerRound = 300;lblSecPerRound.text = "300";} else {secondsPerRound = 60;lblSecPerRound.text = "60";}
        case 13:
            print("13")
            if audioStatus == "ON" {Utils.shared.say(sentence: "OK Kazumi, Let's Go")}
            let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/")
            refDB.removeValue()
            
        default:
            print("DO NOTHING")
        }
        
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        udArray = defaults.stringArray(forKey: "SavedStringArray") ?? [String]()
        udString = "NEW ACTIVITY, \(getFormattedTimeAndDate(d: Date()))\n"
        
        //dump(availableDataElementsToView)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewDidAppear")
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5.0
        locationManager.requestAlwaysAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    //FB PUSH, AT ROUND COMPLETE
    func fbPush(rSpeed: String, rHeartrate: String, rScore: String, rCadence: String) {
        //send round data to fb
        print("Start fbPush")
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        
        if roundsCompleted > 0 {
            // FIREBASE PUSH  - START
            let round_post = [
                "a_calcDurationPost" : roundsCompleted * 5,
                "a_scoreRoundLast" : rScore.toDouble,
                "a_speedRoundLast" : rSpeed.toDouble,
                "fb_CAD" : rCadence.toDouble,
                "fb_Date" : result,
                "fb_DateNow" : result,
                "fb_HR" : rHeartrate.toDouble,
                "fb_RND" : rScore.toDouble,
                "fb_SPD" : rSpeed.toDouble,
                "fb_maxHRTotal" : maxHRvalue,
                "fb_scoreHRRound" : rScore.toDouble,
                "fb_scoreHRRoundLast" : rScore.toDouble,
                "fb_scoreHRTotal" : rScore.toDouble,
                "fb_timAvgCADtotal" : rCadence.toDouble,
                "fb_timAvgHRtotal" : rScore.toDouble,
                "fb_timAvgSPDtotal" : rSpeed.toDouble,
                "fb_timDistanceTraveled" : total_distance ?? 0,
                "fb_timGroup" : "iOS",
                "fb_timName" : riderName,
                "fb_timTeam" : "Square Pizza"
                ] as [String : Any]
            
            let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds/\(result)")
            refDB.childByAutoId().setValue(round_post)
            print("Complete pushFBRound")
        }
        print("Complete pushFBRound II")
        let _ = fbPost()
    }
    
    //FB POST, AT ROUND COMPLETE
    func fbPost() {
        var tSpeed = "\(stringer(dbl: btAverageSpeed, len: 2))"
        if geo.elapsedTime > 0 {
            if btAverageSpeed > 0 {
                tSpeed = stringer(dbl: btAverageSpeed, len: 2)
            } else {
                if geo.avgSpeed! > 0 {tSpeed = stringer(dbl: geo.avgSpeed!, len: 2)} else {tSpeed = "0"}
            }
        }
        
        let tScore = stringer(dbl: (rounds.heartrates.average / Double(maxHRvalue)) * 100, len: 1)
        //let tScore = round(((rounds.heartrates.average / Double(maxHRvalue)) * 100) * 100) / 100
        
        let tCadence = stringer(dbl: rounds.cadences.average, len: 1)
        
        print("Start fbPost for Totals")
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        
        if roundsCompleted > 0 {
            // FIREBASE TOTALS POST
            let totals_post = [
                "a_calcDurationPost" : roundsCompleted * 5,
                "a_scoreHRRoundLast" : tScore.toDouble,
                "a_scoreHRTotal" : tScore.toDouble,
                "a_speedLast" : tSpeed.toDouble,
                "a_speedTotal" : tSpeed.toDouble,
                "fb_CAD" : tCadence.toDouble,
                "fb_Date" : result,
                "fb_DateNow" : result,
                "fb_maxHRTotal" : maxHRvalue,
                "fb_scoreHRRound" : tScore.toDouble,
                "fb_scoreHRRoundLast" : tScore.toDouble,
                "fb_scoreHRTotal" : tScore.toDouble,
                "fb_timAvgCADtotal" : tCadence.toDouble,
                "fb_timAvgHRtotal" : tScore.toDouble,
                "fb_timAvgSPDtotal" : tSpeed.toDouble,
                "fb_timDistanceTraveled" : total_distance ?? 0,
                "fb_timGroup" : "iOS",
                "fb_timName" : riderName,
                "fb_timTeam" : "Square Pizza"
                ] as [String : Any]
            
            let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)/\(riderName)")
            refDB.setValue(totals_post)
            print("Complete postFBTotals")
        }
        print("Complete postFBTotals II")
        //let _ = fb1()
    }
    
    //FB GETS (1,2,3,4)
    func fb1() -> String {
        print("start fb1")
        var arrLeaderNamesByScore: String = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        //let result = "20170527"
        let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
        let ref = refDB.child(result)
        _ = ref.queryLimited(toLast: 5).queryOrdered(byChild: "fb_RND").observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    var sRND: String = "0"
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let fbRND = dict["fb_RND"]!
                    let fbNAME = dict["fb_timName"]!
                    
                    if let dRND = fbRND as? Double {
                        sRND = stringer(dbl: dRND, len: 1)
                    } else {
                        sRND = "0"
                    }
//                    print("fbRND    :\(fbRND)")
//                    print("sRND    :\(sRND)")
//                    arrLeaderNamesByScore = "\(fbRND) %  \(fbNAME)\n" + arrLeaderNamesByScore
                    arrLeaderNamesByScore = "\(sRND) %  \(fbNAME)\n" + arrLeaderNamesByScore
                }
                print("Completed:  (Round) Get 5 leaders, ordered by score")
                print(arrLeaderNamesByScore)
                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "TOP 5 SCORES\n\n\(arrLeaderNamesByScore)", "color": "black"])
                
                //WHEN FINISHED...CHAIN SOMETHING ELSE HERE
                //let _ = self.fb2()
            }
            return
        })
        { (error) in
            print(error.localizedDescription)}
        return "fb1 completed"
    }
    
    func fb2() -> String {
        print("\nstart fb2")
        var arrLeaderNamesBySpeed: String = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
        let ref = refDB.child(result)
        _ = ref.queryLimited(toLast: 5).queryOrdered(byChild: "fb_SPD").observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    //let fbRND = dict["fb_RND"]!
                    let fbNAME = dict["fb_timName"]!
                    let fbSPD = dict["fb_SPD"]!
                    arrLeaderNamesBySpeed = "\(fbSPD) MPH  \(fbNAME)\n" + arrLeaderNamesBySpeed
                }
                print("Completed:  (Round) Get 5 leaders, ordered by speed")
                print(arrLeaderNamesBySpeed)
                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "TOP 5 SPEEDS\n\n\(arrLeaderNamesBySpeed)", "color": "blue"])

                //let _ = self.fb3()
            }
            return
        })
        { (error) in
            print(error.localizedDescription)}
        return "fb2 completed"
    }
    
    func fb3() -> String { //get Totals from fb, ordered by score
        print("\nstart fb3")
        var leaderNamesByScoreTotals: String = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        var sSCORE: String = "0"
        let ref = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)")
        ref.queryLimited(toLast: 5).queryOrdered(byChild: "a_scoreHRTotal").observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let fbNAME = dict["fb_timName"]!
                    let fbSCORE = dict["a_scoreHRTotal"]!
                    //let fbSPEED = dict["a_speedTotal"]!
                    
                    if let dSCORE = fbSCORE as? Double {
                        sSCORE = stringer(dbl: dSCORE, len: 1)
                    } else {
                        sSCORE = "0"
                    }
                    
                    leaderNamesByScoreTotals = "\(sSCORE)%  \(fbNAME)\n" + leaderNamesByScoreTotals
                    
                }
                print("leaderNamesByScoreTotals\n\(leaderNamesByScoreTotals)")
                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "BEST DAILY AVG SCORES\n\n\(leaderNamesByScoreTotals)", "color": "red"])
                print("Complete fb3")
                //let _ = self.fb4()
            }
        })
        return "Complete fb3"
    }  //fb3 complete
    
    func fb4() -> String { //get Totals from fb, ordered by speed
        print("\nstart fb4")
        var leaderNamesBySpeedTotals: String = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        
        let ref = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)")
        ref.queryLimited(toLast: 5).queryOrdered(byChild: "a_speedTotal").observeSingleEvent(of: .value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let fbNAME = dict["fb_timName"]!
                    //let fbSCORE = dict["a_scoreHRTotal"]!
                    let fbSPEED = dict["a_speedTotal"]!
                    
                    leaderNamesBySpeedTotals = "\(fbSPEED) MPH  \(fbNAME)\n" + leaderNamesBySpeedTotals
                    
                }
                print("Complete fb4")
                print("leaderNamesBySpeedTotals\n\(leaderNamesBySpeedTotals)")
                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "FASTEST AVG SPEEDS\n\n\(leaderNamesBySpeedTotals)", "color": "green"])
            }
        })
        return "Complete fb4"
    }  //fb4 complete
   
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        _locationManager.distanceFilter = 5.0

        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()

}

extension Starter_VC: CLLocationManagerDelegate {
    
    func startLocationUpdates() {
        print("startLocationUpdates")
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        print("stopLocationUpdates")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Loc did fail:  \(error)")
        startLocationUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if self.locations.count > 2 {
                    if location.distance(from: self.locations.last!) < 161 {  // 1/10th of a mile
                        
                        la = (self.locations.last?.coordinate.latitude)!
                        lo = (self.locations.last?.coordinate.longitude)!
                        geo.distance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                        inRoundGeoDistance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                        
                        let avgGeoSpeedThisRound =  inRoundGeoDistance / Double((system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) / 60.0 / 60.0)
                        roundGeoSpeed = avgGeoSpeedThisRound
                        
                        
                        gpsRoundSpeed.text = "\(stringer(dbl: avgGeoSpeedThisRound, len: 1))"
                        
                        var coords = [CLLocationCoordinate2D]()
                        coords.append(self.locations.last!.coordinate)
                        coords.append(location.coordinate)
                        
                        geo.speed = location.speed * 2.23694
                        gpsMovingSpeed.text = "\(stringer(dbl: geo.speed!,len: 1))"
                        
                        geo.pace = calcMinPerMile(mph: geo.speed!)
                        gpsMovingPace.text = "\(String(describing: geo.pace))"
                        gpsDistance.text = "\(stringer(dbl: geo.distance, len: 2)) MI"
                        
                        geo.avgSpeed = Double(Double(geo.distance) / Double(geo.elapsedTime / 60 / 60))
                        gpsAverageSpeed.text = "\(stringer(dbl: geo.avgSpeed!, len: 1))"
                        gpsAvergagePace.text = "\(calcMinPerMile(mph: geo.avgSpeed!))"

                        let ts = Double((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)))
                        if ts < 10 {
                            geo.elapsedTime += ts
                        }
                        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
                        
                        totalTime.text = "\(createTimeString(seconds: Int(  round((system.actualElapsedTime)!))))"
                        gpsMovingTime.text = "\(createTimeString(seconds: Int((geo.elapsedTime))))"
                        
                        
                        if location.course > 315 || location.course <= 45 {
                            gpsDirection.text = "\(location.course)  [N]"
                            geo.direction = "\(location.course)  [N]"
                            
                        }
                        
                        if location.course > 45 && location.course <= 135 {
                            gpsDirection.text = "\(location.course)  [E]"
                            geo.direction = "\(location.course)  [E]"
                            
                        }
                        if location.course > 135 && location.course <= 225 {
                            gpsDirection.text = "\(location.course)  [S]"
                            geo.direction = "\(location.course)  [S]"
                        }
                        if location.course > 225 && location.course <= 315 {
                            gpsDirection.text = "\(location.course)  [W]"
                            geo.direction = "\(location.course)  [W]"
                        }

                        
                    }
                } else {
                    print("Waiting for the 3rd update  \(self.locations.count)")
                    if (self.locations.count == 2) {
                    print("Last One")
                    }
                }
                self.locations.append(location)
            }
        }
    }
    
    
}
