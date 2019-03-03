//
//  MainViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 2/24/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import AudioToolbox
//import Firebase
import SystemConfiguration
import Mapbox

struct displayStrings {
        static var time: String = "0"
        static var distance: String = "0"
        static var speed: String = "0"
        static var avgSpeed: String = "0"
        static var pace: String = "0"
        static var avgPace: String = "0"
}

var valueTimelineString = [String]()

class MainViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapViewMessageBar: UILabel!
    
    @IBOutlet weak var mapSpeed: UILabel!
    @IBOutlet weak var mapDistance: UILabel!
    
    
    //var mapView: MGLMapView!
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        system.startTime = Date()
        
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        startAtLaunch()
        
        valueTimelineString.append("VIRTUAL CRIT IS STARTING, PROCEED TO THE START LINE")
        
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    func addMarker(cll : CLLocationCoordinate2D) {
        print("Adding Marker for CP")
//        40.769189, -73.975280  CP
        
        let hello = MGLPointAnnotation()
//        hello.coordinate = CLLocationCoordinate2D(latitude: 40.769189, longitude: -73.975280)
        hello.coordinate = cll
        hello.title = "START"
//        hello.subtitle = "CENTRAL PARK"
        
        // Add marker `hello` to the map.
        mapView.addAnnotation(hello)
    }
    
    
    struct system {
        static var startTime: Date?
        static var stopTime: Date?
        static var actualElapsedTime: Double = 0
        static var timerIntervalValue: Double = 1
    }
    
    var timer = Timer()

    
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: system.timerIntervalValue,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
        print("Timer Started")
        print(getFormattedTime(d: system.startTime!))
        print(getFormattedTimeAndDate(d: system.startTime!));print("\n");
    
    }
    
    func startAtLaunch() {
        print("startAtLaunch")
        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        startTimer()
        startLocationUpdates()
        
        let cord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.769189, longitude: -73.975280)
        addMarker(cll: cord)
    }
    
    
    //EACH SECOND
    @objc func timerInterval() {
        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        
        _ = "\(createTimeString(seconds: Int(round(system.actualElapsedTime)))) TOTAL TIME"
        //print(_)
        
    }
    
    private let locationManager = LocationManager.shared
    private var locations: [CLLocation] = []
    
    private func startLocationUpdates() {
        print("startLocationUpdates")
        locationManager.delegate = self
//        locationManager.delegate = (self as! CLLocationManagerDelegate)
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        print("stopLocationUpdates")
    }
    
    
//UTIL
    func getFormattedTime(d: Date) -> String {
        let currentDateTime = d
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: currentDateTime as Date)
    }
    
    func getFormattedTimeAndDate(d: Date) -> String {
        let currentDateTime = d
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter.string(from: currentDateTime as Date)
    }
    
    func createTimeString(seconds: Int)->String //"00:00:00"
    {
        let h:Int = seconds / 3600
        let m:Int = (seconds/60) % 60
        let s:Int = seconds % 60
        let a = String(format: "%u:%02u:%02u", h,m,s)
        return a
    }
    
    func getTimeIntervalSince(d1: Date, d2: Date) -> Double {
        return d2.timeIntervalSince(d1 as Date)
    }
    
    
    func calcMinPerMile(mph: Double) -> String {
        let a = (60 / mph)
        if a.isFinite == false {
            return "00:00"
        }
        
        let b = (a - Double(Int(a)))
        let c = b * 60
        
        let d = Int(a)
        let e = Int(c)
        if (e < 10) {
            return "\(d):0\(e)"
        } else {
            return "\(d):\(e)"
        }
    }
    
    func stringer1(dbl: Double) -> String {
        if dbl.isNaN == true || dbl.isInfinite == true  {
            return "0"
        } else {
            return String(format:"%.1f", dbl)
        }
    }
    
    func stringer2(dbl: Double) -> String {
        if dbl.isNaN == true || dbl.isInfinite == true  {
            return "0"
        } else {
            return String(format:"%.2f", dbl)
        }
    }


}


var distance: Double = 0
var activeTime: Double = 0
var speedQuick: Double = 0
var pace: String = "00:00"
var avgSpeed: Double = 0
var avgPace: String = "00:00"
var coords = [CLLocationCoordinate2D]()
//locations[] is used for all location updates

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Loc did fail:  \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("did update locations")
        
        
        
        
        for location in locations {
            let howRecent = location.timestamp.timeIntervalSinceNow
            guard location.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if self.locations.count > 1 {
                let ts = Double((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)))
                if ts < 20 {
                    activeTime += ts
                    //gpsMovingTime.text = "\(createTimeString(seconds: Int((geo.elapsedTime)))) MOVING(G)"
                }
            }
            if self.locations.count > 2 {
                if location.distance(from: self.locations.last!) < 161 {  // 161 for production, 1/10th of a mile
                    print("distance passes the test")
                    //var la: Double = 0;var lo: Double = 0;
                    //let la: Double = (self.locations.last?.coordinate.latitude)!
                    //let lo: Double = (self.locations.last?.coordinate.longitude)!
                    distance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                    
                    //lastLocationTimeStamp = location.timestamp
//                    var coords = [CLLocationCoordinate2D]()
                    //coords.append(self.locations.last!.coordinate)
                    coords.append(location.coordinate)
                    print("location.speed: \(location.speed)")
                    if location.speed > 0 {
                        speedQuick = location.speed * 2.23694
                        pace = calcMinPerMile(mph: speedQuick)
                        avgSpeed = Double(Double(distance) / Double(activeTime / 60 / 60))
                        avgPace = calcMinPerMile(mph: avgSpeed)
                        
                        displayStrings.time = "\(createTimeString(seconds: Int(activeTime)))"
                        displayStrings.distance = "\(stringer1(dbl: distance))"
                        displayStrings.speed = "\(stringer1(dbl: speedQuick))"
                        displayStrings.pace = "\(calcMinPerMile(mph: speedQuick))"
                        displayStrings.avgSpeed = "\(stringer1(dbl: avgSpeed))"
                        displayStrings.avgPace = "\(calcMinPerMile(mph: avgSpeed))"
                        
                        
                        mapSpeed.text = "\(stringer1(dbl: speedQuick)) MPH"
                        mapDistance.text = "\(stringer1(dbl: distance)) MI"
                        
                        print("Speed: \(stringer1(dbl: speedQuick)), Distance: \(stringer1(dbl: distance))")

                        //gpsMovingSpeed.text = "\(stringer(dbl: geo.speed,len: 1)) MPH(G)"
                        //print("\(speedQuick)  MPH")
//                        gpsMovingPace.text = "\(String(describing: geo.pace)) PACE(G)"
//                        gpsDistance.text = "\(stringer(dbl: geo.distance, len: 2)) MI(G)"
//                        geo.avgSpeed = Double(Double(geo.distance) / Double(geo.elapsedTime / 60 / 60))
//                        gpsAverageSpeed.text = "\(stringer(dbl: geo.avgSpeed, len: 1)) AVG(G)"
//                        gpsAvergagePace.text = "\(calcMinPerMile(mph: geo.avgSpeed)) AVG(G)"
                        
//                        if activityType == "RUN" || activityType == "ROW" {
//                            tabBarController?.tabBar.items?[3].badgeValue = "\(String(describing: geo.pace))"
//                            tabBarController?.tabBar.items?[2].badgeValue = "\(stringer(dbl: geo.distance, len: 2)) MI"
//                        }
                    }
                    
//                    if location.course > 315 || location.course <= 45 {
//                        gpsDirection.text = "\(location.course)  [N]"
//                        geo.direction = "\(location.course)  [N]"
//                    }
//                    if location.course > 45 && location.course <= 135 {
//                        gpsDirection.text = "\(location.course)  [E]"
//                        geo.direction = "\(location.course)  [E]"
//                    }
//                    if location.course > 135 && location.course <= 225 {
//                        gpsDirection.text = "\(location.course)  [S]"
//                        geo.direction = "\(location.course)  [S]"
//                    }
//                    if location.course > 225 && location.course <= 315 {
//                        gpsDirection.text = "\(location.course)  [W]"
//                        geo.direction = "\(location.course)  [W]"
//                    }
                }
            } else {
                print("Waiting for the 3rd update  \(self.locations.count)")
                if (self.locations.count == 2) {
                    //print("Last One")
                }
            }
            self.locations.append(location)
        }
    }
    
    
}
