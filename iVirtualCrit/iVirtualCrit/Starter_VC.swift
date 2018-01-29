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
    var timer = Timer()
    var timerIntervalValue: Double = 5
    
    
    @objc func timerInterval() {
        //check for 0's
        //update system time

        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        totalTime.text = ("\(  createTimeString(seconds: Int(round(system.actualElapsedTime!))))   [ACTUAL ELAPSED TIME]")
//        print("timerInterval");print(system.actualElapsedTime!);print("\(createTimeString(seconds: Int(round(system.actualElapsedTime!))))");
//        print("\n");
        
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
                        var coords = [CLLocationCoordinate2D]()
                        coords.append(self.locations.last!.coordinate)
                        coords.append(location.coordinate)
                        
                        //geo.speed = ((location.distance(from: self.locations.last!)) * 0.000621371) / ((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)) / 60 / 60)
                        geo.speed = location.speed * 2.23694
                        gpsMovingSpeed.text = "\(stringer(dbl: geo.speed!,len: 1)) MPH [MOVING SPD]"
                        
                        geo.pace = calcMinPerMile(mph: geo.speed!)
                        gpsMovingPace.text = "\(String(describing: geo.pace)) MIN/MI [MOVING PACE]"
                        gpsDistance.text = "\(stringer(dbl: geo.distance, len: 2)) MI  [GEO DISTANCE]"

                        let ts = Double((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)))
                        if ts < 10 {
                            geo.elapsedTime += ts
                        }
                        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
                        totalTime.text = ("\(  createTimeString(seconds: Int(round(system.actualElapsedTime!))))   [ACTUAL ELAPSED TIME]")
                        gpsMovingTime.text = "\(createTimeString(seconds: Int((geo.elapsedTime))))  [MOVING TIME]"
                        
                        geo.direction = String(describing: location.course)
                        
                        if location.course > 316 && location.course < 45 {
                            gpsDirection.text = "\(location.course)  [N]"
                            geo.direction = "\(location.course)  [N]"
                            
                        } else {
                            gpsDirection.text = "\(location.course)  [O]"
                            geo.direction = "\(location.course)  [O]"
                        }
                        
                        //  DO OTHERS
                        //  LOGIC FOR STOP WHEN IN BACKGROUND
                        
                        
                        
                        
                        
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
