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
import Firebase
import SystemConfiguration
import Mapbox

struct displayStrings {
    static var time: String = "00:00:00"
        static var distance: String = "000.00"
        static var speed: String = "00.0"
        static var avgSpeed: String = "00.0"
    static var pace: String = "00:00"
    static var avgPace: String = "00:00"
}

var llNames: String = ""
var llPoints: String = ""
var finalNamesArr = [String]()
var finalPointsArr = [CLLocationCoordinate2D]()

var showUserTrackingPath: Int = 0


var coordsForBuilderCrit = [CLLocationCoordinate2D]()
var collectCoordsInProgress: Bool = false

var todaysDateString: String = "00000000"
var useSimRide: Bool = false
var raceStatusDisplay = "NOT LOADED"
var valueTimelineString = [String]()
var valueTimelineStringDate = [String]()
var currentCritPoint: Int = 0

func addValueToTimelineString(s: String) {
    //print("addValueToTimelineString")
    let t = getFormattedTime()
    valueTimelineString.append("\(s) \n")
    valueTimelineStringDate.append(t)
}


class MainViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapViewMessageBar: UILabel!
    @IBOutlet weak var mapSpeed: UILabel!
    @IBOutlet weak var mapDistance: UILabel!
    
    struct system {
        static var startTime: Date?
        static var stopTime: Date?
        static var actualElapsedTime: Double = 0
        static var timerIntervalValue: Double = 1
    }
    var timer = Timer()
    
    
    //var mapView: MGLMapView!
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        system.startTime = Date()
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        todaysDateString = formatter.string(from: date)
        
        settingsName = UserDefaults.standard.string(forKey: "udName") ?? "TIM\(Int.random(in: 101 ... 999))"
        print("settingsName: \(settingsName)")
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        // Add a gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(longPress)

        
        startAtLaunch()
        
        addValueToTimelineString(s: "VIRTUAL CRIT IS STARTING, LOAD A RACE AND GO")
        
        //add pp gpx
//        let w0: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.66068, longitude: -73.97738)
//        wpts.append(w0)
//        let w1: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.652033131581746, longitude: -73.9708172236974)
//        wpts.append(w1)
//        let w2: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.657608465972885, longitude: -73.96300766854665)
//        wpts.append(w2)
//        let w3: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.671185505128406, longitude: -73.96951606153863)
//        wpts.append(w3)
//        let w4: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.66331, longitude: -73.97495)
//        wpts.append(w4)
//
//
//        let n0: String = "Prospect Park, Brooklyn, Single Loop"
//        gpxNames.append(n0)
//        let n1: String = "PARADE GROUND"
//        gpxNames.append(n1)
//        let n2: String = "LAFREAK CENTER"
//        gpxNames.append(n2)
//        let n3: String = "GRAND ARMY PLAZA"
//        gpxNames.append(n3)
//        let n4: String = "FINISH"
//        gpxNames.append(n4)
        
        setFBListenRequest()
    }
    
    // Use the default marker. See also: our view annotation or custom marker examples.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        return nil
    }
    
    func addUserTrackingPath() {
        print("addUserTrackingPath")
        mapView.delegate = self
        
        //rem all older markers
        if coords.count < 2 {
            print("no coords, return")
            showUserTrackingPath = 0
            return
        }
        if wpts.count < 2 {
            print("no wpts, return")
            showUserTrackingPath = 0
            return
        }
        
        remMarkers()
        
        //ADD ROUTE POLYLINE
        let polyline = MGLPolyline(coordinates: coords, count: UInt(coords.count))
        mapView.addAnnotation(polyline)
        
        //add crit markers back
        if wpts.count > 0 {
        addMarker(cll: wpts[0])
        }

        
        showUserTrackingPath = 0
    }
    
    func addMarker(cll : CLLocationCoordinate2D) {
        print("Adding Markers")
        
        if wpts.count < 2 {
            print("no wpts, return")
            showUserTrackingPath = 0
            return
        }
//        40.769189, -73.975280  CP
        
//        let hello = MGLPointAnnotation()
//        hello.coordinate = cll
//        hello.title = "START"
//        mapView.addAnnotation(hello)
        
        
        
        var cordArrAnnotation = [MGLPointAnnotation]()
        var coordArr =  [CLLocationCoordinate2D]()
        for c: CLLocationCoordinate2D in wpts {
            let h = MGLPointAnnotation()
            h.coordinate = c
            h.title = " "
            cordArrAnnotation.append(h)
            coordArr.append(c)
        }
        //ADD WAYPOINT MARKERS
        mapView.addAnnotations(cordArrAnnotation)

        //ADD ROUTE POLYLINE
        let polyline = MGLPolyline(coordinates: coordArr, count: UInt(coordArr.count))
        mapView.addAnnotation(polyline)
        
        showUserTrackingPath = 0
    }


    func remMarkers() {
        if mapView.annotations != nil {
            mapView.removeAnnotations(mapView.annotations!)
        }
        
        // Remove any existing polyline(s) from the map.
//        if mapView.annotations?.count != nil, let existingAnnotations = mapView.annotations {
//            mapView.removeAnnotations(existingAnnotations)
//        }
        
    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 1
    }
    
    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 1.0
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        // Give our polyline a unique color by checking for its `title` property
        if (annotation.title == "Crema to Council Crest" && annotation is MGLPolyline) {
            // Mapbox cyan
            return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
        } else {
            return .red
        }
    }
    


    
    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // Create a basic point annotation and add it to the map
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "CRITPOINT"
        
        
        //CLEAR ARRAY TO START
        //IF A ROUTE IS COMPLETE, THEN CLEAR
        //IF USER IS FINISHED, SET BOOL TO FALSE
        if collectCoordsInProgress == true {
            coordsForBuilderCrit.append(coordinate)
        }
        print("\(coordinate.latitude), \(coordinate.longitude)")
        mapView.addAnnotation(annotation)

    }

    
    
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
        

        
    }
    
    
    var currentRound: Int = 1
    var distanceAtRoundStart: Double = 0
    var distanceAtRoundEnd: Double = 0
    var distanceRound: Double = 0
    var distanceBestRound: Double = 0.2
    var round_speed: Double = 0
    
    var round_bpmAverage:Double = 0
    var round_bpmScore: Double = 0
    var round_bpmTotals:Int = 0
    var round_bpmCount:Int = 0
    var round_bestHR: Double = 0
    
    
    
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
            round_speed = distanceRound / (Double(settingsSecondsPerRound) / 60.0 / 60.0);
            
            //REMOVE CLUTTER
            if (distanceRound > distanceBestRound) {
                distanceBestRound = distanceRound
                //addValueToTimelineString(s: "Fastest Round\nRound \(currentRound-1) Complete\nSpeed: \(stringer1(dbl: round_speed)) MPH")
            } else {
                //addValueToTimelineString(s: "Round \(currentRound-1) Complete.\nSpeed: \(stringer1(dbl: round_speed)) MPH")
            }
            
            if (round_bpmTotals > 1000) {
                let t: Double = Double(round_bpmTotals)
                let c: Double = Double(round_bpmCount)
                round_bpmAverage = t / c
                round_bpmScore = getScoreFromHR(x: round_bpmAverage)
                if (round_bpmAverage > round_bestHR) {
                    round_bpmAverage = round_bestHR
                }
                //addValueToTimelineString(s: "ROUND HR\nHR: \( stringer1(dbl: round_bpmAverage) ) [\(stringer1(dbl: round_bestHR))] \nROUND SCORE: \( stringer1(dbl: round_bpmScore) )")
            }
            
            //RESET ROUND VARS
            distanceAtRoundStart = distance
            round_bpmCount = 0
            round_bpmTotals = 0
            
            postRoundData(rn: currentRound-1)
            
        }
        //END ROUND COMPLETE LOGIC
        
        //EACH SECOND, PULL BPM FOR ROUND CALC
        if bpmValue > 50 {
            round_bpmCount += 1
            round_bpmTotals += bpmValue
        }

        
        //check for new race
        if critStatus == 0 {
            //new race, start over
            //reset distance, timee, etc.
            currentCritPoint = 0
            print("reset race from critStatus at 0, currentCritPoint is 0")
            
            let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[0].latitude, longitude: wpts[0].longitude)
            addMarker(cll: cord)
            critStatus = 1
            
        }
        
        if critStatus == 100 {
            //get name from UI
            //set crit status to 101
            //requestRaceData(rn: FROM UI)
            print("status == 100")
            requestRaceData(rn: tempName)
            //after processing, set crit status to 101
            
        }
        
        if critStatus == 105 {
            print("critStatus is 105, postRaceProcessingPreRace")
            postRaceProcessingPreRace()
        }
        
        if critStatus == 101 {
            print("status == 101")
            gpxNames = finalNamesArr
            wpts = finalPointsArr
            critStatus = 0
            remMarkers()
        }
        
        if critStatus == 10 {
            if gpxNames.first != nil {
                critStatus = 0
                remMarkers()
                print("critStatus is 10, requestRaceData for \(gpxNames.first!)")
                requestRaceData(rn: gpxNames.first!)
            }

        }
        
        
        if useSimRide == true && system.actualElapsedTime > 20 {
            simRide()
        }
        
        if showUserTrackingPath == 1 {
            //remMarkers()
            addUserTrackingPath()
        }
//        if showUserTrackingPath == 2 {
//            if coords.count > 0 {
//                remMarkers()
//            addMarker(cll: coords[0])
//            }
//
//        }
        
    }
    
    func postRoundData(rn: Int) {
        print("post round data \(rn)")
        let round_post = [
            "a_calcDurationPost" : rn*settingsSecondsPerRound,
            "a_scoreRoundLast" : (round_bpmScore*1000).rounded()/1000,
            "a_speedRoundLast" : (round_speed*1000).rounded()/1000,
            "fb_CAD" : 0,
            "fb_Date" : todaysDateString,
            "fb_DateNow" : todaysDateString,
            "fb_HR" : (round_bpmAverage*1000).rounded()/1000,
            "fb_RND" : (round_bpmScore*1000).rounded()/1000,
            "fb_SPD" : (round_speed*1000).rounded()/1000,
            "fb_maxHRTotal" : settingsMaxHR,
            "fb_scoreHRRound" : (round_bpmScore*1000).rounded()/1000,
            "fb_scoreHRRoundLast" : (round_bpmScore*1000).rounded()/1000,
            "fb_scoreHRTotal" : (round_bpmScore*1000).rounded()/1000,
            "fb_timAvgCADtotal" : 0,
            "fb_timAvgHRtotal" : (round_bpmScore*1000).rounded()/1000,
            "fb_timAvgSPDtotal" : (round_speed*1000).rounded()/1000,
            "fb_timDistanceTraveled" : distance,
            "fb_timGroup" : settingsActivityType,
            "fb_timName" : settingsName,
            "fb_timTeam" : "Square Pizza"
            ] as [String : Any]
        
        
        let refDB  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds/\(todaysDateString)")
        refDB.childByAutoId().setValue(round_post) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Round Data could not be saved: \(error).")
            } else {
                print("Round Data saved successfully!")
            }
        }
        
        let totals_post = [
            "a_calcDurationPost" : (currentRound-1) * 5,
            "a_scoreHRRoundLast" : (round_bpmScore*1000).rounded()/1000,
            "a_scoreHRTotal" : (round_bpmScore*1000).rounded()/1000,
            "a_speedLast" : (round_speed*1000).rounded()/1000,
            "a_speedTotal" : (round_speed*1000).rounded()/1000,
            "fb_CAD" : 0,
            "fb_Date" : todaysDateString,
            "fb_DateNow" : todaysDateString,
            "fb_maxHRTotal" : settingsMaxHR,
            "fb_scoreHRRound" : (round_bpmScore*1000).rounded()/1000,
            "fb_scoreHRRoundLast" : (round_bpmScore*1000).rounded()/1000,
            "fb_scoreHRTotal" : (round_bpmScore*1000).rounded()/1000,
            "fb_timAvgCADtotal" : 0,
            "fb_timAvgHRtotal" : (round_bpmScore*1000).rounded()/1000,
            "fb_timAvgSPDtotal" : (round_speed*1000).rounded()/1000,
            "fb_timDistanceTraveled" : distance,
            "fb_timGroup" : settingsActivityType,
            "fb_timName" : settingsName,
            "fb_timTeam" : "Square Pizza"
            ] as [String : Any]
        
        let refDBT  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(todaysDateString)/\(settingsName)")
        refDBT.setValue(totals_post) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Totals Data could not be saved: \(error).")
            } else {
                print("Totals Data saved successfully!")
            }
        }
        
    
    }
    
    
    

    var refHandle: UInt = 0
    var refHandleRoundSpeed: UInt = 1
    func setFBListenRequest() {
        print("set listen request")
            //READ, ROUND, SCORE
            let refDB  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds/\(todaysDateString)/")
            //let ref = refDB.child(todaysDateString)
            refHandle = refDB.queryLimited(toLast: 1).queryOrdered(byChild: "fb_RND").observe(DataEventType.value, with: { (snapshot) in
                if ( snapshot.value is NSNull ) {
                    print("no snapshot")
                } else {
                    print("has snapshot")
                    _ = snapshot.value as? [String : AnyObject] ?? [:]
                    for child in (snapshot.children) {
                        print("round-score, have a child")
                        let snap = child as! DataSnapshot //each child is a snapshot
                        let dict = snap.value as! NSDictionary // the value is a dict
                        let fbRND = dict["fb_RND"]!
                        let fbNAME = dict["fb_timName"]!
                        print("name, \(fbNAME).  rnd, \(fbRND)")
                    }
                }
            })
            print("refhandle \(refHandle)")
            //end request round, score, leader
        
        //READ ROUND, SPEED
            let refDBSpd  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
            let refSpd = refDBSpd.child(todaysDateString)

            refHandleRoundSpeed = refSpd.queryLimited(toLast: 1).queryOrdered(byChild: "fb_SPD").observe(DataEventType.value, with: { (snapshot) in
                if ( snapshot.value is NSNull ) {
                    print("no snapshot")
                } else {
                    _ = snapshot.value as? [String : AnyObject] ?? [:]
                    for child in (snapshot.children) {
                        print("round-speed, have a child")
                        let snap = child as! DataSnapshot //each child is a snapshot
                        let dict = snap.value as! NSDictionary // the value is a dict
                        let fbSPD = dict["fb_SPD"]!
                        let fbNAME = dict["fb_timName"]!
                        print("name, \(fbNAME).  spd, \(fbSPD)")

//                        let d = dict["fb_SPD"] as? Double ?? 0.0
                        //REMOVE CLUTTER
//                        if system.actualElapsedTime > 90 {
//                            self.speakThis(spk: "The Speed Leader is now, \(fbNAME),.  \(self.stringer1(dbl: d)) Miles Per Hour")
//                            addValueToTimelineString(s: "NEW SPEED LEADER\n\(fbNAME)\n\(self.stringer1(dbl: d)) MPH")
//                        }
                        

                    }
                }
            })
            //end request round, speed, leader
        
    }
    
    func speakThis(spk: String) {
        if settingsAudioStatus == "ON" {
            Utils.shared.say(sentence: spk)
        }
    }
    
    var arrWaypointTimes = [Int]()
    var refHandleRace: UInt = 3
    var activeRaceName: String = ""
    var activeRaceLeadersName: String = ""
    var activeRaceBestWaypointTimesArray = [Int]()
    
    //REQUEST RACE DATA
    func requestRaceData(rn: String) {
        print("REQUEST RACE DATA")
        if activeRaceName == rn {
            print("already have this being observed")
            critStatus = 0
            return
        }
        if activeRaceName != "" {
            print("remove listener")
            let refDB  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/race/\(activeRaceName)")
            refDB.removeObserver(withHandle: refHandleRace)
        }
        activeRaceName = rn
        let refDB  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/race/\(rn)")
        
        refHandleRace = refDB.queryLimited(toFirst: 1).queryOrdered(byChild: "raceTimeToComplete").observe(DataEventType.value, with: { (snapshot) in
            if ( snapshot.value is NSNull ) {
                print("no snapshot")
            } else {
                _ = snapshot.value as? [String : AnyObject] ?? [:]
                for child in (snapshot.children) {
                    print("race results, have a child")
                    let snap = child as! DataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let rider = dict["riderName"]!
                    let race = dict["raceName"]!
                    let wayptTimes = dict["waypointTimes"] ?? [:]
                    let rtc = dict["raceTimeToComplete"]!
                    
                    let tempLLN = dict["llNames"]!
                    let tempLLP = dict["llPoints"]!
                    
                    print("\(rider), \(race), \(rtc)... BEST WAYPOINT TIMES \(wayptTimes)")
                    
                    if self.arrWaypointTimes.count > 0 {
                        //SPLICE UP THE WAYPOINT TIMES
                        let wtimes: String = wayptTimes as! String
                        let wtimesarr = wtimes.components(separatedBy: ",")
                        self.activeRaceBestWaypointTimesArray.removeAll()
                        for s in (wtimesarr) {
                            print("\(s)")
                            self.activeRaceBestWaypointTimesArray.append(Int(s)!)
                        }
                    } else {
                        self.activeRaceBestWaypointTimesArray.removeAll()
                    }
                    //let rtct = rtc as! Int
                    let rtca = (rtc as! Int) / 1000
                    if rtca > (12 * 60 * 60) { //12 hours
                        addValueToTimelineString(s:"\(race) IS NOW LOADED.")
                        self.speakThis(spk: "\(race) IS NOW LOADED.")
                    } else {
                        addValueToTimelineString(s:"RACE UPDATE FOR \(race).  THE LEADER IS \n\(rider), AT \(self.createTimeString(seconds: rtca))")
                        self.speakThis(spk: "RACE UPDATE FOR: \(race).  THE LEADER IS \n\(rider), AT \(self.createTimeString(seconds: rtca))")
                    }
                    

                    

                    

                    //llN
                    finalNamesArr = [String]()
                    let lln: String = tempLLN as! String
                    llNames = lln
                    let llNamesArr = lln.components(separatedBy: ",")
                    finalNamesArr.removeAll()
                    for sn in (llNamesArr) {
                        print("\(sn)")
                        finalNamesArr.append(sn)
                    }
                    
                    
                    
                    //llP
                    var llp: String = tempLLP as! String
                    if llp.last! == ":" {
                        llp = String(llp.dropLast())
                    }
                    llPoints = llp
                    let llPointsArr = llp.components(separatedBy: ":")

                    finalPointsArr = [CLLocationCoordinate2D]()
                    for sp in (llPointsArr) {
                        print("sp: \(sp)")
                        var temp = sp.components(separatedBy: ",")
                        var tempLats = [String]()
                        var tempLons = [String]()
                        tempLats.append(temp[0])
                        tempLons.append(temp[1])
                        
                        let d1: Double = Double(tempLats[0])!
                        let d2: Double = Double(tempLons[0])!
                        
                        let w0: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: d1, longitude: d2)
                        finalPointsArr.append(w0)
                    }
                    
                    print("NAMES: \(finalNamesArr)")
                    print("POINTS:  \(finalPointsArr)")
                    
                    self.activeRaceLeadersName = rider as! String
                    print("activeRaceBestWaypointTimesArray:    \(self.activeRaceBestWaypointTimesArray)")
                    
                    critStatus = 101

                }
            }
        })
        
    }
    
    
    //POST RACE PROCESSING
    func postRaceProcessing(rt: Int) {
    print("post race processing")
        
        let raceDate: String = todaysDateString
        let raceName: String = gpxNames.first!
        let stringOfWaypointTimes: String = waypointTimesTimString
        let riderName: String = settingsName
        let raceDur: Int = rt * 1000
        
        if (raceName.isEmpty || riderName.isEmpty || waypointTimesTimString.isEmpty || llNames.isEmpty || llPoints.isEmpty) {
            print("missing values, don't post")
            return
        }
        
        let racePost = [
            "raceName" : raceName,
            "riderName" : riderName,
            "raceTimeToComplete" : raceDur,
            "waypointTimes" : stringOfWaypointTimes,
            "raceDate" : raceDate,
            "llNames" : llNames,
            "llPoints" : llPoints
            ] as [String : Any]
        
        //"40.66484,-73.98081:40.664550000000006,-73.98022:40.6646,-73.97686:40.66123,-73.97968:40.65216,-73.97128000000001:40.651990000000005,-73.97055:40.67116,-73.96926:40.66138,-73.97760000000001:40.661150000000006,-73.97796000000001:40.66104,-73.9795:40.66557,-73.98931:40.659670000000006,-73.99517:40.65964,-73.99512"
        
        //"TOSPECTRUM,LEFT,RIGHT,STRAIGHT,LEFT,STRAIGHT,LEFT,RIGHT,RIGHT,STRAIGHT,LEFT,LEFT,FINISH"
        
        let refDB  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/race/\(raceName)")
        refDB.childByAutoId().setValue(racePost) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("RACE Data could not be saved: \(error).")
            } else {
                print("RACE Data saved successfully!")
            }
        }
        
    }

    
    //POST RACE FOR BUILDER OR LOAD GPX
    func postRaceProcessingPreRace() {
        print("post race processing - PRERACE")
        let rt: Int = 2147483646
        
        let raceDate: String = todaysDateString
        let raceName: String = gpxNames.first!
        //let stringOfWaypointTimes: String = waypointTimesTimString
        let riderName: String = settingsName
        let raceDur = rt
        
        if (raceName.isEmpty || riderName.isEmpty || llNames.isEmpty || llPoints.isEmpty) {
            print("missing values, don't post")
            return
        }
        
        let racePost = [
            "raceName" : raceName,
            "riderName" : riderName,
            "raceTimeToComplete" : raceDur,
//            "waypointTimes" : stringOfWaypointTimes,
            "raceDate" : raceDate,
            "llNames" : llNames,
            "llPoints" : llPoints
            ] as [String : Any]
        
        //"40.66484,-73.98081:40.664550000000006,-73.98022:40.6646,-73.97686:40.66123,-73.97968:40.65216,-73.97128000000001:40.651990000000005,-73.97055:40.67116,-73.96926:40.66138,-73.97760000000001:40.661150000000006,-73.97796000000001:40.66104,-73.9795:40.66557,-73.98931:40.659670000000006,-73.99517:40.65964,-73.99512"
        
        //"TOSPECTRUM,LEFT,RIGHT,STRAIGHT,LEFT,STRAIGHT,LEFT,RIGHT,RIGHT,STRAIGHT,LEFT,LEFT,FINISH"
        
        let refDB  = Database.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/race/\(raceName)")
        refDB.childByAutoId().setValue(racePost) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("PRE RACE Data could not be saved: \(error).")
            } else {
                print("PRE RACE Data saved successfully!")
            }
        }
        
        remMarkers()
        
        if gpxNames.count > 0 && wpts.count > 0 {
            addMarker(cll: wpts[0])
            
        speakThis(spk: "\(gpxNames.first ?? "") IS NOW LOADED, PROCEED TO START")
        }
        


        critStatus = 0
        
    }
    //END POST RACE FOR BUILDER OR LOAD GPX
    
    
    
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
    
    var raceStartTime: Double = 0
    var raceFinishTime: Double = 0
    var raceDuration: Double = 0
    var raceDistanceAtStart: Double = 0
    var raceDistanceAtFinish: Double = 0
    //var raceBestTime: Double = 0
    var raceSpeed: Double = 0

    var checkDistanceValue: Double = 100.0
    
    func evaluateLocation(loc: CLLocationCoordinate2D) -> () {
        //print("Eval Location, currentCritPoint: \(currentCritPoint)")
        if wpts.count == 0 {
            print("no race loaded")
            return
        }
        let c1 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        let c2 = CLLocation(latitude: wpts[currentCritPoint].latitude, longitude: wpts[currentCritPoint].longitude)
        let distanceInMeters = c1.distance(from: c2)  //it is a double
        
        let i: Int = Int(distanceInMeters)
        tabBarController?.tabBar.items?[0].badgeValue = "\(i)"
        
        if currentCritPoint == 0 {
            checkDistanceValue = 100
        }
        if wpts.count-1 == currentCritPoint {
            checkDistanceValue = 100
        } else {
            checkDistanceValue = checkDistanceValue * 1.5
        }



        
        if distanceInMeters < checkDistanceValue {
            print("inside 100, currentCritPoint is \(currentCritPoint)")
            print("currentCritPoint \(currentCritPoint) of \(wpts.count-1)")
            tabBarController?.tabBar.items?[2].badgeValue = "\(currentCritPoint)"
            tabBarController?.tabBar.items?[3].badgeValue = "\(wpts.count-1)"
            critStatus = 2
            
            //race complete
            if wpts.count-1 == currentCritPoint {
                print("race finished, reset  \(currentCritPoint) of \(wpts.count-1)")
                currentCritPoint = 0
                print("race finished, currentCritPoint is 0")
                raceStatusDisplay = "RACE COMPLETE"
                raceFinishTime = system.actualElapsedTime
                raceDuration = raceFinishTime - raceStartTime  //seconds
                raceDistanceAtFinish = distance
                remMarkers();
                
                raceSpeed = (raceDistanceAtFinish - raceDistanceAtStart) / (raceDuration / 60.0 / 60.0)
                print ("racespeed:  \(raceSpeed)")
                
                let t = createTimeString(seconds: Int(raceDuration))
                var b = ""
                
                if activeRaceBestWaypointTimesArray.count > 0 {
                    let rbt = activeRaceBestWaypointTimesArray.last
                    if (Int(raceDuration * 1000)) < rbt! {
                        //rbt = raceDuration * 1000
                        b = "FASTEST TIME"
                    } else {
                        let cmp = ((Int(raceDuration)) - (rbt! / 1000))
                        b = "\(createTimeString(seconds: Int(cmp))) BEHIND THE LEADER, \(activeRaceLeadersName)"
                    }
                }
                

                
                waypointTimesTimString += String(Int(raceDuration) * 1000)
                postRaceProcessing(rt: Int(raceDuration))
                addValueToTimelineString(s: "RACE COMPLETE\n\(t)\n\(b)")
                speakThis(spk: "RACE COMPLETE\n\(t)\n\(b)")
                

                self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = nil
                self.tabBarController?.viewControllers?[2].tabBarItem.badgeValue = nil
                self.tabBarController?.viewControllers?[3].tabBarItem.badgeValue = nil
                return
                
                //reset
            }

            
            if currentCritPoint == 0 {
                print("race started  \(currentCritPoint) of \(wpts.count-1)")
                currentCritPoint += 1
                raceStartTime = system.actualElapsedTime
                
                if gpxNames.count == 0 {
                    print("no gpx names, exit")
                    return
                }
                
                var stLeaderInfo: String = ""
                if activeRaceBestWaypointTimesArray.count > 0 {
                    let stLeaderName: String = activeRaceLeadersName
                    let stLeaderTime: String = createTimeString(seconds: activeRaceBestWaypointTimesArray.last! / 1000)
                    stLeaderInfo = "\nTHE FASTEST IS \(stLeaderName) at \(stLeaderTime)"
                }
                
                addValueToTimelineString(s: "RACE STARTED\n\(gpxNames.first!),\nHEAD TO \(gpxNames[currentCritPoint])\(stLeaderInfo)")
                raceStatusDisplay = "RACE STARTED"
                speakThis(spk: "RACE HAS STARTED.  GOTO \(gpxNames[currentCritPoint]).  \(stLeaderInfo)")
                raceDistanceAtStart = distance
                waypointTimesTimString = ""
//                requestRaceData(rn: gpxNames.first!)
                
                //let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[currentCritPoint].latitude, longitude: wpts[currentCritPoint].longitude)
                //addMarker(cll: cord)
                return
            }
            
            //other checkpoint
            print("race not at Start or Finish  \(currentCritPoint) of \(wpts.count-1)")
            var strComp = ""
            
            let currentCritPointTemp = currentCritPoint
            currentCritPoint += 1
            
            
            let timeToCurrentCritPointMilli: Int = (Int(system.actualElapsedTime-raceStartTime)) * 1000
            waypointTimesTimString += String(timeToCurrentCritPointMilli)
            waypointTimesTimString += ","
            
            
            if activeRaceBestWaypointTimesArray.count > 0 {
                //compare
                let w1: Int = timeToCurrentCritPointMilli
                let w2: Int = activeRaceBestWaypointTimesArray[currentCritPointTemp-1] //milli
                let wtimeCompare = (w1 - w2) / 1000  //seconds
                print("W1, W2, wtimeCompare \(w1),\(w2),\(wtimeCompare)")
                
                if wtimeCompare > 0 {
                    strComp = "BEHIND \(activeRaceLeadersName) BY \(createTimeString(seconds: wtimeCompare))"
                } else {
                    strComp = "AHEAD OF \(activeRaceLeadersName) BY \(createTimeString(seconds: ((w2-w1) / 1000)))"
                }
                print(strComp)
                print("activeRaceBestWaypointTimesArray: \(activeRaceBestWaypointTimesArray)")
                print("waypointTimesTimString: \(waypointTimesTimString)")
            }
            
            
            //disp name for next waypoint
            let strJustHitWpName = "ARRIVED AT \(gpxNames[currentCritPointTemp])"
            let strNextWpName = "\nNEXT IS: \(gpxNames[currentCritPointTemp+1]).\n"
            //print("\(strNextWpName)")
            //let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[currentCritPoint+1].latitude, longitude: wpts[currentCritPoint+1].longitude)
            //addMarker(cll: cord)
            raceStatusDisplay = "CHECKPOINT \(currentCritPointTemp) of \(wpts.count-1)"
            let cp: String = "[ \(currentCritPointTemp) of \(wpts.count-1) ], "
            addValueToTimelineString(s: "\(strJustHitWpName) \(cp) \(strNextWpName) \(strComp)  ")
            speakThis(spk: "\(strJustHitWpName), \(strNextWpName), \(strComp)")
            //print("\(strComp)\(strNextWpName)\n\(VirtualCrit3.getFormattedTime())")
//did this earlier to avoid race
//            currentCritPoint += 1
            
        }
        
    }
    
    //END GPX CRIT
    
    
    
//UTIL
    
    func getScoreFromHR(x: Double) -> Double {
        if x == 0 {
            return 0
        } else {
            let y = Double(settingsMaxHR)
            let z = Double(100)
            return (x / y) * z
        }
    }
    
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
    
//    func createTimeStringForSpeaking(seconds: Int)->String //"00:00:00"
//    {
//        let h:Int = seconds / 3600
//        let m:Int = (seconds/60) % 60
//        let s:Int = seconds % 60
//        let a = String(format: "%u:%02u:%02u", h,m,s)
//        let b = String(format: "%02u:%02u", m,s)
//        let c = String(format: "%02u", s)
//        var ret = ""
//        if s > 0 {
//            ret = c
//        }
//        if m > 0 {
//            ret = b
//        }
//        if h > 0 {
//            ret = a
//        }
//        return ret
//    }
    
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
        }
        if simCount > 1 {
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
                    displayStrings.distance = "\(stringer2(dbl: distance))"
                    displayStrings.speed = "\(stringer1(dbl: speedQuick))"
                    displayStrings.pace = "\(calcMinPerMile(mph: speedQuick))"
                    displayStrings.avgSpeed = "\(stringer1(dbl: avgSpeed))"
                    displayStrings.avgPace = "\(calcMinPerMile(mph: avgSpeed))"
                    
                    
                    mapSpeed.text = "\(stringer1(dbl: speedQuick)) MPH"
                    mapDistance.text = "\(stringer2(dbl: distance)) MI"
                    
                    //print("Speed: \(stringer1(dbl: speedQuick)), Distance: \(stringer1(dbl: distance))")
                    
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
//                let cord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: wpts[0].latitude, longitude: wpts[0].longitude)
//                addMarker(cll: cord)
                //tabBarController?.tabBar.items?[0].badgeValue = "1"
            }
            
            if self.locations.count > 1 {
                //tabBarController?.tabBar.items?[0].badgeValue = "2"
                let ts = Double((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)))
                if ts < 20 {
                    activeTime += ts
                    //gpsMovingTime.text = "\(createTimeString(seconds: Int((geo.elapsedTime)))) MOVING(G)"
                }
            }
            if self.locations.count > 2 {
                if location.distance(from: self.locations.last!) < 161 {  // 161 for production, 1/10th of a mile
                    //print("distance passes the test")
                    //var la: Double = 0;var lo: Double = 0;
                    //let la: Double = (self.locations.last?.coordinate.latitude)!
                    //let lo: Double = (self.locations.last?.coordinate.longitude)!
                    distance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                    
                    //EVALUATE WAYPOINT FOR CRIT.
                    evaluateLocation(loc: location.coordinate)

                    coords.append(location.coordinate)
                    print("location.speed: \(location.speed)")

                    if location.speed > 0 || useSimRide == true {
                        speedQuick = location.speed * 2.23694
                        if useSimRide == true {
                            speedQuick = 5.0
                        }
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
