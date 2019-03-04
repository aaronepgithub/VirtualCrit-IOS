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

var useSimRide: Bool = false
var raceStatusDisplay = "AWAITING START"
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
        
        valueTimelineString.append("VIRTUAL CRIT IS STARTING, PROCEED TO THE START LINE\n[\(VirtualCrit3.getFormattedTime())]")
        
        //add pp gpx
        let w0: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.66068, longitude: -73.97738)
        wpts.append(w0)
        let w1: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.652033131581746, longitude: -73.9708172236974)
        wpts.append(w1)
        let w2: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.657608465972885, longitude: -73.96300766854665)
        wpts.append(w2)
        let w3: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.671185505128406, longitude: -73.96951606153863)
        wpts.append(w3)
        let w4: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.66331, longitude: -73.97495)
        wpts.append(w4)

        
        let n0: String = "Prospect Park, Brooklyn, Single Loop"
        gpxNames.append(n0)
        let n1: String = "PARADE GROUND"
        gpxNames.append(n1)
        let n2: String = "LAFREAK CENTER"
        gpxNames.append(n2)
        let n3: String = "GRAND ARMY PLAZA"
        gpxNames.append(n3)
        let n4: String = "FINISH"
        gpxNames.append(n4)
        
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    func addMarker(cll : CLLocationCoordinate2D) {
        print("Adding Marker")
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
        
//        let cord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.769189, longitude: -73.975280)
//        addMarker(cll: cord)
    }
    
    
    var currentRound: Int = 1
    var distanceAtRoundStart: Double = 0
    var distanceAtRoundEnd: Double = 0
    var distanceRound: Double = 0
    var settingsSecondsPerRound: Int = 300
    var distanceBestRound: Double = 0.2
    
    
    
    //EACH SECOND
    @objc func timerInterval() {
        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        
        _ = "\(createTimeString(seconds: Int(round(system.actualElapsedTime)))) TOTAL TIME"
        //print(_)
        
        if (Int(system.actualElapsedTime) > (currentRound * settingsSecondsPerRound)) {
            currentRound += 1
            print("New Round, #\(currentRound)")
            //PROCESS NEW ROUND
            distanceAtRoundEnd = distance
            distanceRound = distanceAtRoundEnd - distanceAtRoundStart
            let roundSpeed: Double = distanceRound / (Double(settingsSecondsPerRound) / 60.0 / 60.0);
            
            if (distanceRound > distanceBestRound) {
                distanceBestRound = distanceRound
                valueTimelineString.append("Fastest Round\nRound \(currentRound-1) Complete\nSpeed: \(stringer1(dbl: roundSpeed)) MPH\n[\(VirtualCrit3.getFormattedTime())]  ")
            } else {
                valueTimelineString.append("Round \(currentRound-1) Complete.\nSpeed: \(stringer1(dbl: roundSpeed)) MPH\n[\(VirtualCrit3.getFormattedTime())]  ")
            }
            
            //reset
            distanceAtRoundStart = distance
        }  //end round logic
        
        //check for new race
        if critStatus == 0 {
            //new race, start over
            //reset distance, timee, etc.
            currentCritPoint = 0
            
            let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[0].latitude, longitude: wpts[0].longitude)
            addMarker(cll: cord)
            critStatus = 1
            
        }
        
        
        if useSimRide == true && system.actualElapsedTime > 20 {
            simRide()
        }
        
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
    
    
    
    //GPX CRIT
    var currentCritPoint: Int = 0
    var raceStartTime: Double = 0
    var raceFinishTime: Double = 0
    var raceDuration: Double = 0
    var raceDistanceAtStart: Double = 0
    var raceDistanceAtFinish: Double = 0
    var raceBestTime: Double = 10
    var raceSpeed: Double = 0
    
    
    func evaluateLocation(loc: CLLocationCoordinate2D) -> () {
        print("Eval Location")
        
        let c1 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        let c2 = CLLocation(latitude: wpts[currentCritPoint].latitude, longitude: wpts[currentCritPoint].longitude)
        let distanceInMeters = c1.distance(from: c2)  //it is a double
        
        let i: Int = Int(distanceInMeters)
        tabBarController?.tabBar.items?[0].badgeValue = "\(i)"
        
        //print("distanceInMeters:  \(distanceInMeters)")
        //print("distanceInMeters Int:  \(distanceInMeters)")
        if distanceInMeters < 100 {
            print("inside 100, checkpoint")
            print("currentCritPoint \(currentCritPoint), of \(wpts.count-1)")
            tabBarController?.tabBar.items?[2].badgeValue = "\(currentCritPoint)"
            tabBarController?.tabBar.items?[3].badgeValue = "\(wpts.count-1)"
            critStatus = 2
            
            //race complete
            if wpts.count-1 == currentCritPoint {
                print("race finished, reset  \(currentCritPoint) of \(wpts.count-1)")
                currentCritPoint = 0
                raceStatusDisplay = "RACE COMPLETE"
                raceFinishTime = activeTime
                raceDuration = raceFinishTime - raceStartTime
                raceDistanceAtFinish = distance
                
                raceSpeed = (raceDistanceAtFinish - raceDistanceAtStart) / (raceDuration * 60.0 * 60.0)
                print ("racespeed:  \(raceSpeed)")
                
                let t = createTimeString(seconds: Int(raceDuration))
                var b = ""
                if raceDuration < raceBestTime {
                    raceBestTime = raceDuration
                    b = "FASTEST TIME"
                }
                
                valueTimelineString.append("RACE COMPLETE\n\(t)\n\(b)\n[\(VirtualCrit3.getFormattedTime())]")
                tabBarController?.tabBar.items?[0].badgeValue = ""
                tabBarController?.tabBar.items?[2].badgeValue = ""
                tabBarController?.tabBar.items?[3].badgeValue = ""
                return
                
                //reset
            }

            
            if currentCritPoint == 0 {
                print("race started  \(currentCritPoint) of \(wpts.count-1)")
                currentCritPoint += 1
                raceStartTime = activeTime
                valueTimelineString.append("RACE STARTED\n[\(VirtualCrit3.getFormattedTime())]")
                raceStatusDisplay = "RACE STARTED"
                raceDistanceAtStart = distance
                let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[currentCritPoint].latitude, longitude: wpts[currentCritPoint].longitude)
                addMarker(cll: cord)
                return
            }
            
            //other checkpoint
            print("other checkpoint  \(currentCritPoint) of \(wpts.count-1)")
            
            let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[currentCritPoint+1].latitude, longitude: wpts[currentCritPoint+1].longitude)
            addMarker(cll: cord)
            raceStatusDisplay = "CHECKPOINT \(currentCritPoint) of \(wpts.count-1)"
            valueTimelineString.append("CHECKPOINT\n\(currentCritPoint) of \(wpts.count-1)\n[\(VirtualCrit3.getFormattedTime())]")
            currentCritPoint += 1
            
        }
        
    }
    
    //END GPX CRIT
    
    
    
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

    //start sim
    var simCount = 1
    func simRide() {
        //print("simRide")
        
        if trktps.count - 1 == simCount {
            print("startOver")
            simCount = 1
            return
        }
        
        if simCount == 1 {
            //let cord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.769189, longitude: -73.975280)
            let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[0].latitude, longitude: wpts[0].longitude)
            addMarker(cll: cord)
            tabBarController?.tabBar.items?[0].badgeValue = "1"
        }
        if simCount > 1 {
            tabBarController?.tabBar.items?[0].badgeValue = "2"
            activeTime += Double(simCount)
        }
        if simCount > 2 {
            let c1 = CLLocation(latitude: trktps[simCount-1].latitude, longitude: trktps[simCount-1].longitude)
            let c2 = CLLocation(latitude: trktps[simCount].latitude, longitude: trktps[simCount].longitude)
            let distanceInMeters = c1.distance(from: c2)  //it is a double
            
            if distanceInMeters < 161 {  // 161 for production, 1/10th of a mile
                //print("distance passes the test")
                distance += distanceInMeters *  0.000621371 //Miles
                
                //EVALUATE WAYPOINT FOR CRIT.
                let c3: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: trktps[simCount].latitude, longitude: trktps[simCount].longitude)
                evaluateLocation(loc: c3)
                
                
                //lastLocationTimeStamp = location.timestamp
                //                    var coords = [CLLocationCoordinate2D]()
                //coords.append(self.locations.last!.coordinate)
                let simSpeed = distanceInMeters
                coords.append(c3)
                if simSpeed > 0 {
                    speedQuick = simSpeed * 2.23694
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
                    
                }
                //print("sim speed: \(location.speed)")
                
            } //end dist check
            
        }  //end count2
        
        
        simCount += 1
    }
    //end sim

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
            
            if self.locations.count == 1 {
                //let cord:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.769189, longitude: -73.975280)
                let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[0].latitude, longitude: wpts[0].longitude)
                addMarker(cll: cord)
                tabBarController?.tabBar.items?[0].badgeValue = "1"
            }
            
            if self.locations.count > 1 {
                tabBarController?.tabBar.items?[0].badgeValue = "2"
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
                    
                    //EVALUATE WAYPOINT FOR CRIT.
                    evaluateLocation(loc: location.coordinate)
                    
                    
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
