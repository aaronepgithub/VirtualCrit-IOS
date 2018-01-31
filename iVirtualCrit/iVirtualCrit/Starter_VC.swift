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

var arr = [String]()
var arrSend = [String]()

var la: Double = 0
var lo: Double = 0


//USED FOR HISTORY TABLE VIEW
var arrResults = [String]()
var arrResultsDetails = [String]()

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
    
    
    
    
    var timer = Timer()
    var timerIntervalValue: Double = 1
 
    var inRoundGeoDistance: Double = 0
    var roundsCompleted: Int = 0
    var secondsPerRound: Int = 60
    var roundGeoSpeed: Double = 0
    
    func newMilePoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "ANOTHER MILE\n\(mileString)\n", "color": "blue"])
    }
    
    var currentMile: Double = 1.0
    func updateMile() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if btDistanceForMileCalc > 0 && geo.distance > 0 {
            newMilePoint(mileString: "\(stringer(dbl: btDistanceForMileCalc, len: 0)) MILES")
        } else {
            if btDistanceForMileCalc > 0 {
            newMilePoint(mileString: "\(stringer(dbl: btDistanceForMileCalc, len: 0)) MILES")
            }
            if geo.distance > 0 {
                newMilePoint(mileString: "\(stringer(dbl: geo.distance, len: 0)) MILES")
            }
        }
    }
    
    func createNRArray() {
        if roundsCompleted > 0  {
            
            let a = "ROUND # \(roundsCompleted)  "
            let b = "\(stringer(dbl: roundHR, len: 1)) BPM/HR"
            let c = "  \(stringer(dbl: (roundHR / Double(maxHRvalue) * 100), len: 1)) %MAX  "
            let d = "  \(stringer(dbl: roundSpeed, len: 1))  MPH/BT"
            let e = "  \(stringer(dbl: roundCadence, len: 1)) RPM  "
            let f = "  \(stringer(dbl: roundGeoSpeed, len: 1))  MPH/GEO"
            arrResults.append("\(a)\(b)\(c)")
            arrResultsDetails.append("\(d)\(e)\(f)")
            
            print("\n");
            dump(arrResults)
            dump(arrResultsDetails)
            print("\n");
  
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }  //end nrarray
    
    func stopAndSave() {
        //save
        udArray.append(udString)
        let defaults = UserDefaults.standard
        defaults.set(udArray, forKey: "SavedStringArray")
    }
    
    func presentHistory() {
        dump(udArray)
    }
    
    func updateViewer_VC() {
        
        if geo.status == "ON/USE" {
            
            //HDR
            arr.append("\(gpsMovingTime.text ?? "00:00:00")  \(gpsAverageSpeed.text ?? "00.0 AVG")")
            //3 VALS
            if btHR.text == " " {arr.append("\(gpsAvergagePace.text ?? "00")")} else {arr.append("\(btHR.text ?? "00")")}
            
            arr.append("\(gpsMovingSpeed.text ?? "00.0")")
            arr.append("\(gpsMovingPace.text ?? "00")")
            //3 LBLS
            if btHR.text == " " {arr.append("AVG/P")} else {arr.append("\(btScore.text ?? "00")")}
            
            arr.append("SPD")
            arr.append("PACE")
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
            arr.append("\(btScore.text ?? "00")")
            arr.append("SPD")
            arr.append("CAD")
            //FOOTER
            arr.append("\(totalTime.text ?? "00:00:00")  \(btDistance.text ?? "0.00 MILES")")
            arrSend = arr
            arr = []
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("viewUpdate"), object: nil)
    }
    
    //EACH SECOND
    @objc func timerInterval() {

        
        var roundSpeed: Double = 0
        if system.actualElapsedTime != nil {
            
            if inRoundBtDistance > 0 {
                roundSpeed = inRoundBtDistance / Double((system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) / 60.0 / 60.0)
            }
            
        }
        
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
            NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "ROUND COMPLETE \n", "color": "blue", "geospeed": stringer(dbl: roundGeoSpeed, len: 2),"hr": stringer(dbl: roundHR, len: 1), "cadence": stringer(dbl: roundCadence, len: 1), "speed": stringer(dbl: roundSpeed, len: 2)])
            
            rounds.speeds.append(roundSpeed)
            rounds.geoSpeeds.append(roundGeoSpeed)
            rounds.heartrates.append(roundHR)
            rounds.cadences.append(roundCadence)
            
            print("\n")
            print("End of Round for HR, Spd, Cad, GeoSpd")
            dump(rounds.speeds)
            dump(rounds.heartrates)
            dump(rounds.cadences)
            dump(rounds.geoSpeeds)
            print("\n")
            print("btAvgSpeed:  \(stringer(dbl: btAverageSpeed, len: 2))")
            print("\n")
            
            inRoundGeoDistance = 0
            inRoundBtDistance = 0
            inRoundCadence = []
            inRoundHR = []
        }
        
        //print(system.actualElapsedTime! - Double(roundsCompleted * secondsPerRound))
        if Int(system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) == (secondsPerRound / 2) {

            print("\n")
            print("Mid Round for HR, Spd, Cad, GeoSpd")
            print(roundHR, roundSpeed, roundCadence, roundGeoSpeed)
            print("\n")
            
            NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "MID-ROUND UPDATE \n", "color": "blue", "geospeed": stringer(dbl: roundGeoSpeed, len: 2),"hr": stringer(dbl: roundHR, len: 1), "cadence": stringer(dbl: roundCadence, len: 1), "speed": stringer(dbl: roundSpeed, len: 2)])
            
                }
        
        updateViewer_VC()
        
    }  //END SECOND TIMER
    
    
    @objc func updateBT(not: Notification) {
//        print("updateBT")
//        print("not:  \(not)")
        // userInfo is the payload send by sender of notification
        if let userInfo = not.userInfo {
            //print(userInfo[AnyHashable("hr")]!)
            if let hrv = userInfo[AnyHashable("hr")] {
                //print(String(describing: userInfo[AnyHashable("hr")]!))
                btHR.text = "\(hrv as! String)"  //HR
            }
            if let scv = userInfo[AnyHashable("score")] {
                //print(String(describing: userInfo[AnyHashable("score")]!))
                btScore.text = "\(scv as! String) %"
            }
            if let spv = userInfo[AnyHashable("spd")] {
                //print(String(describing: userInfo[AnyHashable("spd")]!))
                btMovingSpeed.text = "\(spv as! String)"//SPD BT
            }
            if let cav = userInfo[AnyHashable("cad")] {
                //print(String(describing: userInfo[AnyHashable("cad")]!))
                btMovingCadence.text = "\(cav as! String)"  //   CAD BT"
            }
            if let dsv = userInfo[AnyHashable("dist")] {
                btDistance.text = "\(dsv as! String) MILES"  //DISTANCE BT
                btDistanceForMileCalc = dsv as! Double
            }
            if let mtv = userInfo[AnyHashable("mov")] {
                btMovingTime.text = "\(mtv as! String)"   //MOVING TIME BT
            }
            if let mvavg = userInfo[AnyHashable("mov_avg")] {
                btMovAvg.text = "\(mvavg as! String) AVG"  //MOV AVG
            }

        }
    }
    
    var btDistanceForMileCalc:Double = 0
    var audioStatus: String = "OFF"
    @IBOutlet weak var lblTireSize: UILabel!
    @IBOutlet weak var lblMaxHeartrateValue: UILabel!
    @IBOutlet weak var lblAudio: UILabel!
    
    
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
        case 7:
            if lblAudio.text == "OFF" {audioStatus = "ON";lblAudio.text = "ON"} else {audioStatus = "OFF";lblAudio.text = "OFF"}
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
                        gpsAverageSpeed.text = "\(stringer(dbl: geo.avgSpeed!, len: 1)) AVG SPD"
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
