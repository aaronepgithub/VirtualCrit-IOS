//
//  Settings.swift
//  xxyy
//
//  Created by aaronep on 11/29/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit
import CoreLocation



extension Settings: CLLocationManagerDelegate {
    
    
    
    @objc func eachSecond(timer: Timer) {
        
        if locations.count > 3 {
            let x = NSDate()
            let y = x.timeIntervalSince(geoStartTime as Date!)
            let z = Double(y)  //time in seconds
            
            geo.total_moving_time_string = createTimeString(seconds: Int(z))
            geo.total_moving_time_seconds = z  //int for seconds
            geo.avgSpeed = geo.total_distance / ( geo.total_moving_time_seconds / 60.0 / 60.0)
            geo.avgPace = calcMinPerMile(mph: geo.avgSpeed)
            
            
            if Int(geo.total_moving_time_seconds) - oldGeoTime == 60 {
                //lbl_Moving_Speed.text = "1 Minute"
                print("\n  60S Update:")
                print("geo.total_distance:  \(geo.total_distance) Miles")
                print("geo.avgSpeed:  \(geo.avgSpeed) Avg Mph")
                print("geo.avgPace:  \(geo.avgPace) Min/Mile")
                print("geo.total_moving_time_string:  \(geo.total_moving_time_string)")
                print("\n")
                oldGeoTime = Int(geo.total_moving_time_seconds)
            }
            lbl_GPS.text = "DISABLE GPS: (\(String(format: "%.01f", geo.speed))MPH, \(geo.pace) PACE)"
        }
        
    }
    
//    func stopTimer() {
//        //timer.invalidate()
//    }
    
    func startLocationUpdates() {
        print("startLocationUpdates")
        locationManager.startUpdatingLocation()
    }
    
    func stopWorkout() {
        //stopTimer()
        locationManager.stopUpdatingLocation()
        //lbl_btn_Start_Stop.setTitle("Restart", for: .normal)
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if self.locations.count > 2 {
                    if location.distance(from: self.locations.last!) < 161 {  // 1/10th of a mile
                        distanceInMeters += location.distance(from: self.locations.last!)  //meters
                        geo.total_distance = distanceInMeters * 0.000621371 //Miles
                        var coords = [CLLocationCoordinate2D]()
                        coords.append(self.locations.last!.coordinate)
                        coords.append(location.coordinate)
                        
                        geo.speed = ((location.distance(from: self.locations.last!)) * 0.000621371) / ((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)) / 60 / 60)
                        geo.pace = calcMinPerMile(mph: geo.speed)
                    }
                } else {
                    print("Waiting for the 3rd update")
                    if (self.locations.count == 2) {
                        geoStartTime = NSDate()
                        print("startTime:  \(String(describing: geoStartTime))")
                    }
                }
                self.locations.append(location)
            }
        }
    }
    
    func startGeo() {
        print("Geo Started")
        geo.total_distance = 0.0
        locations.removeAll(keepingCapacity: false)
        
        timer = Timer.scheduledTimer(timeInterval: 1,
         target: self,
         selector: #selector(self.eachSecond),
         userInfo: nil,
         repeats: true)
        
        startLocationUpdates()
    }
}


class Settings: UITableViewController {
    
    @IBOutlet weak var lbl_AudioToggle: UILabel!
    @IBOutlet weak var lbl_NameCell: UILabel!
    @IBOutlet weak var lbl_MaxHR: UILabel!
    @IBOutlet weak var lbl_TireSizeCell: UILabel!
    

    var distanceInMeters = 0.0
    var geoStartTime: NSDate?
    var oldGeoTime: Int = 0
    
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.activityType = .fitness
        _locationManager.distanceFilter = 5.0
        
        //locationManager.requestAlwaysAuthorization()
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = Timer()
    
    
    
    
    
    
    
    func callNameActionSheet() {
        let alert = UIAlertController(title: "Enter Name", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Name Input", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            print(textField.text as Any)
            
            if textField.text != nil {
                name = textField.text!.uppercased()
                self.lbl_NameCell.text = textField.text?.uppercased()
            } else {
                self.lbl_NameCell.text = name.uppercased()
            }
            
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
        self.lbl_NameCell.text = name
        
    }
    
    func callTireSizeActionSheet() {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Tire Size", preferredStyle: .actionSheet)
        
        let Action700x25 = UIAlertAction(title: "700x25", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x25")
            wheelCircumference = 2105
            self.lbl_TireSizeCell.text = "700X25 TIRE SIZE"
        })
        
        let Action700x26 = UIAlertAction(title: "700x26", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x26")
            wheelCircumference = 2110
            self.lbl_TireSizeCell.text = "700X26 TIRE SIZE"
        })
        
        let Action700x28 = UIAlertAction(title: "700x28", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x28")
            wheelCircumference = 2130
            self.lbl_TireSizeCell.text = "700X28 TIRE SIZE"
        })
        
        let Action700x32 = UIAlertAction(title: "700x32", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x32")
            wheelCircumference = 2155
            self.lbl_TireSizeCell.text = "700X32 TIRE SIZE"
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(Action700x25)
        optionMenu.addAction(Action700x26)
        optionMenu.addAction(Action700x28)
        optionMenu.addAction(Action700x32)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var lbl_GPS: UILabel!
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Your action here
        
        print(indexPath)
        
        if indexPath.section == 0 && indexPath.row == 3 {
            print("Pressed GPS Cell")
            let x = gpsEnabled
            if x == false {
                lbl_GPS.text = "DISABLE GPS"
                gpsEnabled = true
                startGeo()
            }
            if x == true {
                lbl_GPS.text = "ENABLE GPS"
                gpsEnabled = false
                //stopTimer()
                locationManager.stopUpdatingLocation()
            }
            
        }
        
        
        
        if indexPath.section == 0 && indexPath.row == 0 {
            print("Pressed Name Cell")
            callNameActionSheet()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            print("Audio Cell")
            
            if lbl_AudioToggle.text == "AUDIO ON" {
                lbl_AudioToggle.text = "AUDIO OFF"
                settings_Audio = false
            } else {
                lbl_AudioToggle.text = "AUDIO ON"
                settings_Audio = true
            }
            
            
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            
            let x = lbl_MaxHR.text
            //print("HR Cell:  \(x)")
            
            if x == "MAX HR: 185" {
                lbl_MaxHR.text = "MAX HR: 190"
                settings_MAXHR = 190
            }
            if x == "MAX HR: 190" {
                lbl_MaxHR.text = "MAX HR: 195"
                settings_MAXHR = 195
            }
            
            if x == "MAX HR: 195" {
                lbl_MaxHR.text = "MAX HR: 185"
                settings_MAXHR = 185
            }
            
            lbl_MaxHR.text = "MAX HR: \(stringer0(myIn: settings_MAXHR))"
            
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            print("pressed tire size cell")
            callTireSizeActionSheet()
        }
        
        //        if indexPath.section == 1 && indexPath.row == 1 {
        //            print("duration cell")
        //
        //            let x = lbl_RT_Avg_Duration.text
        //
        //            if x == "INTERVAL FOR AVG = 1.0" {
        //                lbl_RT_Avg_Duration.text = "INTERVAL FOR AVG = 1.5"
        //                rtTimer_Interval = 1.5
        //
        //            }
        //
        //            if x == "INTERVAL FOR AVG = 1.5" {
        //                lbl_RT_Avg_Duration.text = "INTERVAL FOR AVG = 2.0"
        //                rtTimer_Interval = 2.0
        //
        //            }
        //
        //            if x == "INTERVAL FOR AVG = 2.0" {
        //                lbl_RT_Avg_Duration.text = "INTERVAL FOR AVG = 2.5"
        //                rtTimer_Interval = 2.5
        //
        //            }
        //
        //            if x == "INTERVAL FOR AVG = 2.5" {
        //                lbl_RT_Avg_Duration.text = "INTERVAL FOR AVG = 3.0"
        //                rtTimer_Interval = 3.0
        //
        //            }
        //
        //            if x == "INTERVAL FOR AVG = 3.0" {
        //                lbl_RT_Avg_Duration.text = "INTERVAL FOR AVG = 1"
        //                rtTimer_Interval = 1.0 //rt
        //
        //            }
        //
        //        }
        
        //        if indexPath.section == 1 && indexPath.row == 2 {
        //            //launch ble
        //            self.tabBarController?.selectedIndex = 4;
        //        }
        
        if indexPath.section == 3 && indexPath.row == 0 {
            //launch history
            self.performSegue(withIdentifier: "segue_History", sender: nil)
        }
        
        if indexPath.section == 0 && indexPath.row == 4 {
            //launch ble
            self.tabBarController?.selectedIndex = 4;
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        //backgroundImage.image = UIImage(named: "Default-7506-landscape_1334x750")
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        backgroundImage.alpha = 0.2
        self.view.insertSubview(backgroundImage, at: 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
}
