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
    
    
    
    var timer = Timer()
    var timerIntervalValue: Double = 1
 
    var inRoundGeoDistance: Double = 0
    var roundsCompleted: Int = 0
    var secondsPerRound: Int = 60
    
    
    @objc func timerInterval() {
        //check for 0's
        //update system time

        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        totalTime.text = ("\(  createTimeString(seconds: Int(round(system.actualElapsedTime!))))   [ACTUAL ELAPSED TIME]")
        
        if  system.actualElapsedTime! >= Double((roundsCompleted + 1) * secondsPerRound) {
            print("New Round")
            roundsCompleted += 1
            rounds.geoDistancesPerRound.append(inRoundGeoDistance)
            inRoundGeoDistance = 0
        }
        
        //print(system.actualElapsedTime! - Double(roundsCompleted * secondsPerRound))
        
    }
    
    @objc func updateBT(not: Notification) {
        print("updateBT")
        print("not:  \(not)")
        // userInfo is the payload send by sender of notification
        if let userInfo = not.userInfo {
            //print(userInfo[AnyHashable("hr")]!)
            if let hrv = userInfo[AnyHashable("hr")] {
                print(String(describing: userInfo[AnyHashable("hr")]!))
                btHR.text = "(\(hrv as! String))    HR"
            }
            if let scv = userInfo[AnyHashable("score")] {
                print(String(describing: userInfo[AnyHashable("score")]!))
                btScore.text = "(\(scv as! String))    %MAX SCORE"
            }
            if let spv = userInfo[AnyHashable("spd")] {
                print(String(describing: userInfo[AnyHashable("spd")]!))
                btMovingSpeed.text = "(\(spv as! String))    SPD RAW"
            }
            if let cav = userInfo[AnyHashable("cad")] {
                print(String(describing: userInfo[AnyHashable("cad")]!))
                btMovingCadence.text = "(\(cav as! String))   CAD RAW"
            }

        }
    }
    
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
            }
            
        default:
            print("DO NOTHING")
        }
        
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if self.locations.count > 2 {
                    if location.distance(from: self.locations.last!) < 161 {  // 1/10th of a mile
                        
                        geo.distance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                        inRoundGeoDistance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                        
                        let avgGeoSpeedThisRound =  inRoundGeoDistance / Double((system.actualElapsedTime! - (Double(roundsCompleted) * Double(secondsPerRound))) / 60.0 / 60.0)
                        
                        gpsRoundSpeed.text = "\(stringer(dbl: avgGeoSpeedThisRound, len: 1))     [ROUND SPEED]"
                        
                        var coords = [CLLocationCoordinate2D]()
                        coords.append(self.locations.last!.coordinate)
                        coords.append(location.coordinate)
                        
                        geo.speed = location.speed * 2.23694
                        gpsMovingSpeed.text = "\(stringer(dbl: geo.speed!,len: 1)) MPH [MOVING SPD]"
                        
                        geo.pace = calcMinPerMile(mph: geo.speed!)
                        gpsMovingPace.text = "\(String(describing: geo.pace)) MIN/MI [MOVING PACE]"
                        gpsDistance.text = "\(stringer(dbl: geo.distance, len: 2)) MI  [GEO DISTANCE]"
                        
                        geo.avgSpeed = Double(Double(geo.distance) / Double(geo.elapsedTime / 60 / 60))
                        gpsAverageSpeed.text = "\(stringer(dbl: geo.avgSpeed!, len: 1)) AVG SPD"
                        gpsAvergagePace.text = "\(calcMinPerMile(mph: geo.avgSpeed!)) AVG PACE"

                        let ts = Double((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)))
                        if ts < 10 {
                            geo.elapsedTime += ts
                        }
                        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
                        
                        totalTime.text = "\(createTimeString(seconds: Int(  round((system.actualElapsedTime)!)  )  ))   [ACTUAL ELAPSED TIME]"
                        gpsMovingTime.text = "\(createTimeString(seconds: Int((geo.elapsedTime))))  [MOVING TIME]"
                        
                        
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
