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
import SystemConfiguration

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
    
    var secondsCounter: Int = 1
    
    var secondsSinceStart = Double(0)
    var secondsInRound = Double(0)
    var secondsInCurrentMile = Double(0)
    //MAKE ZERO AT ROUND END/MILE END

    var distanceAtStartOfRoundBT = Double(0)
    var distanceAtStartOfRoundGEO = Double(0)
    var distanceAtStartOfMile = Double(0)
    var lastLocationTimeStamp: Date!
    
    var timer = Timer()
    var timerIntervalValue: Double = 1
    
    var inRoundGeoDistance: Double = 0
    var inRoundBtDistance: Double = 0
    var inRoundGeoSpeed: Double = 0
    var inRoundBtSpeed: Double = 0
    var roundSpeed: Double = 0 //best between bt and geo

    var inRoundHR = [Int]()
    var inRoundCadence = [Int]()
    var roundHR: Double = 0
    var roundScore: Double = 0
    var roundCadence: Double = 0
    
    
    var secondsPerRound: Int = 300
    var roundGeoSpeed: Double = 0
    
    var roundsCompleted: Double = 0
    var currentRound: Double = 1.0
    var currentMile: Double = 1.0
    
    var bestRoundSpeed: Double = 0
    var bestRoundHR: Double = 0
    var bestRoundCadence: Double = 0
    var bestRoundScore: Double = 0
    var bestRoundPace: String = ""
    
    var longestDistance: Double = 0
    
    
    var speedForLastMile: Double = 0
    var paceForLastMile: Double = 0
    var fastestMile: Double = 0 //MPH
    var arrMileSpeeds = [Double]()
    
    
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
    
    @IBOutlet weak var btSpdRnd: UILabel!
    @IBOutlet weak var btCadRnd: UILabel!
    @IBOutlet weak var btHrRnd: UILabel!
    @IBOutlet weak var btScoreRnd: UILabel!
    
    func processUD(st: String) {
        udString = "\(secondsCounter):  \(st) \n"
        udArray = []
        udArray.append(udString)
        let defaults = UserDefaults.standard
        defaults.set(udArray, forKey: "SavedStringArray")
    }
    
    
    //EACH SECOND
    @objc func timerInterval() {
        secondsCounter += 1
        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        
        secondsInCurrentMile += 1
        secondsSinceStart = round(system.actualElapsedTime)
        secondsInRound = (secondsSinceStart - (Double(secondsPerRound) * roundsCompleted)) - 1
        
        //NEW ROUND IDENTIFIED
        if secondsSinceStart >= (currentRound * Double(secondsPerRound)) + 1 {
            print("\nNEW ROUND, ROUND \(roundsCompleted) COMPLETE")
            print("SEC IN ROUND:  \(secondsInRound)")
            print("secondsSinceStart:  \(secondsSinceStart)")
            roundsCompleted += 1
            currentRound += 1
            processUD(st: "NEW ROUND IDENTIFIED")

            
            updateRound()

            distanceAtStartOfRoundBT = current.totalDistance
            distanceAtStartOfRoundGEO = geo.distance
        }

        totalTime.text = "\(createTimeString(seconds: Int(round(system.actualElapsedTime)))) TOTAL TIME"
        
        print("each second:  \(createTimeString(seconds: Int(round(system.actualElapsedTime))))")
        print("each second:  \(system.actualElapsedTime)")
        print("current.currentSpeed: \(current.currentSpeed)")
        print("current.totalDistance: \(current.totalDistance)")
        print("current.totalMovingTime: \(current.totalMovingTime)")
        print("current.totalAverageSpeed: \(current.totalAverageSpeed)")
        print("current.currentCadence: \(current.currentCadence)")
        let str: String = "\(current.currentHR),\(current.currentScore)"
        print("HR/Score:  \(str)")
        print("geo.speed \(geo.speed)")
        print("geo.elapsedTime \(geo.elapsedTime)")
        print("geo.distance \(geo.distance)")
        print("geo.pace \(geo.pace)")
        print("geo.avgSpeed \(geo.avgSpeed)")
        print("\n")
        
        btHR.text = "\(current.currentHR) BPM (HR)"
        btMovingSpeed.text = "\(stringer(dbl: current.currentSpeed, len: 1)) MPH(BT)"
        btMovingCadence.text = "\(stringer(dbl: current.currentCadence, len: 0)) RPM(BT)"
        btScore.text = "\(stringer(dbl: current.currentScore, len: 1)) %MAX"
        btDistance.text = "\(stringer(dbl: current.totalDistance, len: 2)) MI(BT)"
        btMovingTime.text = "\(createTimeString(seconds: Int(current.totalMovingTime))) MOVING(BT)"
        btMovAvg.text = "\(stringer(dbl: current.totalAverageSpeed, len: 1)) AVG SPD(BT)"
        
        //TEST FOR NEW ROUND
        print("seconds since start:  \(secondsSinceStart)")
        print("secondsInRound:  \(secondsInRound)")
        print("currentRound:  \(currentRound)")
        
        //CALC ROUND SPEEDS BEFORE ROUND ENDS
        processUD(st: "CALC ROUND SPEEDS")
        if current.totalDistance > 0 {
            inRoundBtDistance = current.totalDistance - distanceAtStartOfRoundBT
            if inRoundBtDistance > 0.1 && secondsInRound > 10 {
                inRoundBtSpeed = inRoundBtDistance / (secondsInRound / 60.0 / 60.0)
                print("inRoundBtSpeed:   \(inRoundBtSpeed)")
                btSpdRnd.text = "\(stringer(dbl: inRoundBtSpeed, len: 1)) RND SPD"
            } else {inRoundBtSpeed = 0}
        }
        
        if geo.distance > 0 {
            inRoundGeoDistance = geo.distance - distanceAtStartOfRoundGEO
            if inRoundGeoDistance > 0.1 && secondsInRound > 10 {
                inRoundGeoSpeed = inRoundGeoDistance / (secondsInRound / 60.0 / 60.0)
                print("inRoundGeoSpeed:   \(inRoundGeoSpeed)")
                gpsRoundSpeed.text = "\(stringer(dbl: inRoundGeoSpeed, len: 1)) RND SPD(G)"
            } else {inRoundGeoSpeed = 0}
        }

        //CALC ROUND HR/SCORE BEFORE ROUND ENDS
        processUD(st: "CALC ROUND HR/SCORE")
        if current.currentHR > 0 {
            inRoundHR.append(Int(current.currentHR))
            if inRoundHR.count > 2 {
                roundHR = inRoundHR.average
                roundScore = getScoreFromHR(x: roundHR)
                print("roundHR:   \(roundHR)")
                print("roundScore:   \(roundScore)")
                btHrRnd.text = "\(stringer(dbl: roundHR, len: 1)) RND HR"
                btScoreRnd.text = "\(stringer(dbl: roundScore, len: 1)) % RND SCORE"
            }
        }
        
        //CALC ROUND CAD BEFORE ROUND ENDS
        processUD(st: "CALC ROUND CAD BEFORE ROUND ENDS")
        if current.currentCadence > 0 && current.currentCadence.isNaN == false {
            inRoundCadence.append(Int(current.currentCadence))
            if inRoundCadence.count > 2 {
                //roundCadence = inRoundCadence.average
                
                if inRoundCadence.average > 1 {
                    roundCadence = inRoundCadence.average
                    print("round cadence:  \(roundCadence)")
                } else {
                    roundCadence = 1
                    print("round cadence:  \(roundCadence)")
                }
                
                btCadRnd.text = "\(stringer(dbl: roundCadence, len: 1)) RND CAD"
                print("roundCadence:   \(roundCadence)")
            }
        } else {
            roundCadence = 1
        }
        

        

        
        //TEST FOR NEW MILE
        processUD(st: "TEST FOR NEW MILE")
        if current.totalDistance > currentMile || geo.distance > currentMile {
            print("NEW MILE, MILE \(currentMile) COMPLETED")
            currentMile += 1
            updateMile()
        }
        
        processUD(st: "SET LONGEST DISTANCE")
        if current.totalDistance > geo.distance {
            longestDistance = current.totalDistance
        } else {
            longestDistance = geo.distance
        }
        
        //CREATE DATA FOR VIEWER_VC
        processUD(st: "CREATE VIEWER ARRAY")
        createViewerArray()

    }
    //END SECOND TIMER
    

    //MARK:  UPDATEROUND at ROUND COMPLETE
    func updateRound() {
        processUD(st: "UPDATE ROUND")
        print("UPDATE ROUND")
        rounds.btSpeeds.append(inRoundBtSpeed)
        rounds.geoSpeeds.append(inRoundGeoSpeed)
        rounds.heartrates.append(roundHR)
        rounds.scores.append(getScoreFromHR(x: roundHR))
        rounds.cadences.append(roundCadence)
        
        roundSpeed = rounds.btSpeeds.last!
        if rounds.geoSpeeds.last! > roundSpeed {roundSpeed = rounds.geoSpeeds.last!}
        let roundPace = calcMinPerMile(mph: roundSpeed)
        rounds.speeds.append(roundSpeed)
        
        //RESULTS DATA
        processUD(st: "RESULTS DATA")
        let a = "ROUND \(stringer(dbl: roundsCompleted, len: 0)) "
        let b = "\(stringer(dbl: rounds.heartrates.last!, len: 1)) HR"
        let c = "\(stringer(dbl: rounds.scores.last!, len: 1)) % MAX"
        let d = "\(stringer(dbl: rounds.speeds.last!, len: 2))  MPH/BT"
        let e = "\(stringer(dbl: rounds.cadences.last!, len: 1)) RPM"
        let f = "\(stringer(dbl: rounds.geoSpeeds.last!, len: 2))  MPH/GEO"

        arrResults.append("\(a)\(b)\(c)")
        arrResultsDetails.append("\(d)\(e)\(f)")
        
        
        //ROUNDCOMPLETE POINT
         processUD(st: "ROUNDCOMPLETE POINT")
        newRoundPoint(mileString: "\(a) COMPLETE\n\n\(d)\n\(f)\n\(b)\n\(roundPace) PACE\n\(e)")
        
        
        calcBestRoundMetrics()
        
        print("\n")
        print("End of Round for HR, Spd, Cad, GeoSpd")
        dump(rounds.speeds)
        dump(rounds.heartrates)
        dump(rounds.scores)
        dump(rounds.cadences)
        dump(rounds.btSpeeds)
        dump(rounds.geoSpeeds)
        print("\n")

        inRoundCadence = []
        inRoundHR = []
        
        if ConnectionCheck.isConnectedToNetwork() {
            print("Connected to Internet")
            print("calling fbPushII")
            //fbPush(rSpeed: stringer(dbl: spdToUse, len: 2), rHeartrate: stringer(dbl: roundHR, len: 2), rScore: stringer(dbl: (roundHR / (Double(maxHRvalue)) * 100), len: 2), rCadence: stringer(dbl: roundCadence, len: 2))
            
            fbPushII()
            
            
        }
        else{
            print("disConnected")
        }
    }
    
    
    // CALC BESTROUND METRICS
    func calcBestRoundMetrics() {
        processUD(st: "CALC BEST ROUND METRICS")
        print("CALCBESTROUND METRICS")
        print("roundSpeed:  \(roundSpeed)")
        print("bestRoundSpeed:  \(bestRoundSpeed)")
        
        if roundSpeed > bestRoundSpeed {
            processUD(st: "roundSpeed > bestRoundSpeed")
            
            bestRoundSpeed = roundSpeed
            bestRoundPace = calcMinPerMile(mph: roundSpeed)
            if bestRoundSpeed == 0 {bestRoundPace = "00:00"}
            
            if audioStatus == "ON" {
                if roundHR > bestRoundHR {
                    Utils.shared.say(sentence: "That was your fastest round and your highest score. \(stringer(dbl: roundSpeed, len: 1)) MPH.  Your pace was \(calcMinPerMile(mph: roundSpeed)) PER MILE")
                } else {
                    Utils.shared.say(sentence: "That was your fastest round. \(stringer(dbl: roundSpeed, len: 1)) MPH.  Your pace was \(calcMinPerMile(mph: roundSpeed)) PER MILE")
                }
            }
        } else {
            if audioStatus == "ON" {Utils.shared.say(sentence: "Round Complete. \(stringer(dbl: roundSpeed, len: 1)) MPH.  Your pace was \(calcMinPerMile(mph: roundSpeed)) PER MILE")}
        }
        if roundCadence > bestRoundCadence {bestRoundCadence = roundCadence}
        if roundHR > bestRoundHR {
            bestRoundHR = roundHR
            bestRoundScore = getScoreFromHR(x: bestRoundHR)
        }

        print("roundSpeed:  \(roundSpeed)")
        print("after...bestRoundSpeed:  \(bestRoundSpeed)")
        
        //MY BEST ROUNDS POINT
        
        let when = DispatchTime.now() + 25
        DispatchQueue.main.asyncAfter(deadline: when){
            self.processUD(st: "MY BEST ROUNDS POINT")
            self.newBestRoundPoint(mileString: "MY BEST ROUNDS\n\n\(stringer(dbl: self.bestRoundSpeed, len: 1)) SPEED\n\(stringer(dbl: self.bestRoundCadence, len: 1)) CADENCE\n\(stringer(dbl: self.bestRoundHR, len: 1)) HR\n\(stringer(dbl: self.bestRoundScore, len: 1)) SCORE\n\(self.bestRoundPace) PACE")
            
            print("\nMY BEST ROUNDS\n\(stringer(dbl: self.bestRoundSpeed, len: 1)) SPEED\n\(stringer(dbl: self.bestRoundCadence, len: 1)) CADENCE\n\(stringer(dbl: self.bestRoundHR, len: 1)) HR\n\(stringer(dbl: self.bestRoundScore, len: 1)) SCORE\n\(self.bestRoundPace) PACE\n")
            
            udArray.append("\(getFormattedTimeAndDate(d: Date()))\nMY BEST ROUNDS\n\(stringer(dbl: self.bestRoundSpeed, len: 1)) SPEED\n\(stringer(dbl: self.bestRoundCadence, len: 1)) CADENCE\n\(stringer(dbl: self.bestRoundHR, len: 1)) HR\n\(stringer(dbl: self.bestRoundScore, len: 1)) SCORE\n\(self.bestRoundPace) PACE\n")
            
            
        }
    }
    
    
    
    
    //MARK:  UPDATEMILE
    func updateMile() {
        processUD(st: "UPDATE MILE")
        speedForLastMile = 1.0 / (secondsInCurrentMile / 60.0 / 60.0)
        secondsInCurrentMile = 0
        
        print("SPD FOR LAST MILE: \(speedForLastMile)")
        print("PACE FOR LAST MILE:  \(calcMinPerMile(mph: speedForLastMile))")
        
        arrMileSpeeds.append(speedForLastMile)
        //arrMileSpeeds, fastest to slowest
        arrMileSpeeds = arrMileSpeeds.sorted { $0 > $1 }
        let ix = arrMileSpeeds.index(of: speedForLastMile)
        var indexOfLastMileSpeed = 0
        if ix != nil {
            indexOfLastMileSpeed = (ix ?? 100) + 1
        }
        print("indexOfLastMileSpeed  \(indexOfLastMileSpeed)")
        
        if speedForLastMile > fastestMile {
            fastestMile = speedForLastMile
            if audioStatus == "ON" {
                Utils.shared.say(sentence: "Fastest Mile is now  \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE")
                print("Fastest Mile is now  \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE")
            }
        } else {
            if audioStatus == "ON" {
                Utils.shared.say(sentence: "Sorry, not your best mile.  The fastest is still \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE.  Your last mile ranked number \(indexOfLastMileSpeed) out of \(arrMileSpeeds.count).")
                
                print("Sorry, not your best mile.  The fastest is still \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE.  Your last mile ranked number \(indexOfLastMileSpeed) out of \(arrMileSpeeds.count).")
            }
        }
        processUD(st: "NEW MILEPOINT")
        newMilePoint(mileString: "\(stringer(dbl: (currentMile - 1), len: 0)) MILES COMPLETE\n\(stringer(dbl: speedForLastMile, len: 1)) MPH\n\(calcMinPerMile(mph: speedForLastMile)) PACE\nRANKING \(indexOfLastMileSpeed) OF \(arrMileSpeeds.count)\n\n\(stringer(dbl: fastestMile, len: 1)) FASTEST MILE\n\(calcMinPerMile(mph: fastestMile)) FASTEST PACE")
        
        print("\(stringer(dbl: (currentMile - 1), len: 0)) MILES COMPLETE\n\(stringer(dbl: speedForLastMile, len: 1)) MPH\n\(calcMinPerMile(mph: speedForLastMile)) PACE\nRANKING \(indexOfLastMileSpeed) OF \(arrMileSpeeds.count)\n\n\(stringer(dbl: fastestMile, len: 1)) FASTEST MILE\n\(calcMinPerMile(mph: fastestMile)) FASTEST PACE")
        
        udArray.append("\(getFormattedTimeAndDate(d: Date()))\n\(stringer(dbl: (currentMile - 1), len: 0)) MILES COMPLETE\n\(stringer(dbl: speedForLastMile, len: 1)) MPH\n\(calcMinPerMile(mph: speedForLastMile)) PACE\nRANKING \(indexOfLastMileSpeed) OF \(arrMileSpeeds.count)\n\n\(stringer(dbl: fastestMile, len: 1)) FASTEST MILE\n\(calcMinPerMile(mph: fastestMile)) FASTEST PACE")
        
        distanceAtStartOfMile = 0
    }
    //END UPDATEMILE
    
    func newMilePoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(mileString)", "color": "green"])
    }
    
    func newRoundPoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(mileString)", "color": "yellow"])
    }
    
    func newBestRoundPoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(mileString)", "color": "blue"])
    }
    
    func newBestSpeedsPoint(mileString: String) {
        NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(mileString)", "color": "blue"])
    }

    
    
    
    //var availableDataElementsToView = ["Total Elapsed Time", "GPS Moving Time", "GPS Speed", "GPS Average Speed", "GPS Average Pace", "GPS Direction", "GPS Speed - Round", "GPS Pace - Round", "GPS Distance", "Heartrate", "Speed", "Cadence", "%MAX Heartrate", "Pace", "Heartrate - Round", "Speed - Round", "Cadence - Round", "%MAX Heartrate - Round", "Pace - Round", "Distance", "Average Speed", "Average Pace", "Moving Time"]

    //var actualTimeAtMileStart: Date?
    //var timeElapsedForLastMile: Double = 0

    
//    func updateMile() {
//
//
//        udString = "NEW MILE, \(getFormattedTimeAndDate(d: Date()))\n"
//        udArray.append(udString)
//        let defaults = UserDefaults.standard
//        defaults.set(udArray, forKey: "SavedStringArray")
//
//
//        //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))\
//        //timeElapsedForLastMile = getTimeIntervalSince(d1: actualTimeAtMileStart!, d2: Date())
//        //timeElapsedForLastMile = secondsInCurrentMile
//
//        //replace with secondsInCurrentMile
//        if secondsInCurrentMile == 0 {return}
//
////        if Double(timeElapsedForLastMile) < 10 {
////            return
////        }
//
//        //speedForLastMile = 1.0 / (Double(timeElapsedForLastMile) / 60 / 60)
//
//        speedForLastMile = 1.0 / (secondsInCurrentMile / 60 / 60)
//        secondsInCurrentMile = 0
//
//        arrMileSpeeds.append(speedForLastMile)
//        //arrMileSpeeds, fastest to slowest
//        arrMileSpeeds = arrMileSpeeds.sorted { $0 > $1 }
//        let ix = arrMileSpeeds.index(of: speedForLastMile)
//        var indexOfLastMileSpeed = 0
//        if ix != nil {
//            indexOfLastMileSpeed = (ix ?? 100) + 1
//        }
//        print("indexOfLastMileSpeed  \(indexOfLastMileSpeed)")
//
//        if speedForLastMile > fastestMile {
//            fastestMile = speedForLastMile
//
//            if audioStatus == "ON" {
//                Utils.shared.say(sentence: "Fastest Mile is now  \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE")
//
//                print("Fastest Mile is now  \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE")
//            }
//
//        } else {
//            if audioStatus == "ON" {
//                Utils.shared.say(sentence: "Sorry, not your best mile.  The fastest is still \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE.  Your last mile ranked number \(indexOfLastMileSpeed) out of \(arrMileSpeeds.count).")
//
//                print("Sorry, not your best mile.  The fastest is still \(stringer(dbl: fastestMile, len: 1)) Miles Per Hour.  A Pace of \(calcMinPerMile(mph: fastestMile)) PER MILE.  Your last mile ranked number \(indexOfLastMileSpeed) out of \(arrMileSpeeds.count).")
//            }
//        }
//
//
//        newMilePoint(mileString: "\(stringer(dbl: (currentMile - 1), len: 0)) MILES COMPLETE\n\(stringer(dbl: speedForLastMile, len: 1)) MPH\n\(calcMinPerMile(mph: speedForLastMile)) PACE\nRANKING \(indexOfLastMileSpeed) OF \(arrMileSpeeds.count)\n\n\(stringer(dbl: fastestMile, len: 1)) FASTEST MILE\n\(calcMinPerMile(mph: fastestMile)) FASTEST PACE")
//
//        print("\(stringer(dbl: (currentMile - 1), len: 0)) MILES COMPLETE\n\(stringer(dbl: speedForLastMile, len: 1)) MPH\n\(calcMinPerMile(mph: speedForLastMile)) PACE\nRANKING \(indexOfLastMileSpeed) OF \(arrMileSpeeds.count)\n\n\(stringer(dbl: fastestMile, len: 1)) FASTEST MILE\n\(calcMinPerMile(mph: fastestMile)) FASTEST PACE")
//
//        //actualTimeAtMileStart = Date()
//
//    }
    
   
    
//    func createNRArray() {
//
//        udString = "NEW createNRArray, \(getFormattedTimeAndDate(d: Date()))\n"
//        udArray.append(udString)
//        let defaults = UserDefaults.standard
//        defaults.set(udArray, forKey: "SavedStringArray")
//
//
//        if roundsCompleted > 0  {
//
//
//
//            let a = "ROUND # \(roundsCompleted)  "
//            let b = "\(stringer(dbl: roundHR, len: 1)) HR"
//
//            var roundScore = " 0%"
//            if roundHR > 50 {
//                roundScore = "  \(stringer(dbl: (roundHR / Double(maxHRvalue) * 100), len: 1))%"
//            }
//            let c = roundScore
//            let d = "  \(stringer(dbl: roundSpeed, len: 1))  MPH/BT"
//            let e = "  \(stringer(dbl: roundCadence, len: 1)) RPM"
//            let f = "  \(stringer(dbl: roundGeoSpeed, len: 1))  MPH/GEO"
    
    //            arrResults.append("\(a)\(b)\(c)")
    //            arrResultsDetails.append("\(d)\(e)\(f)")
//
//            print("roundSpeed:  \(roundSpeed)")
//            print("roundGeoSpeed:  \(roundGeoSpeed)")
//            var spdToUse = Double(0)
//            if roundSpeed > spdToUse {spdToUse = roundSpeed}
//            if roundSpeed < roundGeoSpeed {spdToUse = roundGeoSpeed}
//
//            if activityType == "RUN" && roundGeoSpeed > 0.1 {
//                spdToUse = roundGeoSpeed
//            }
//            print("spdToUse:  \(spdToUse)")
//            print("bestRoundSpeed:  \(bestRoundSpeed)")
//
//            if spdToUse > bestRoundSpeed {
//                print("spdToUse is > than bestRoundSpeed")
//                bestRoundSpeed = spdToUse;
//                bestRoundPace = calcMinPerMile(mph: spdToUse)
//                if audioStatus == "ON" {
//                    if roundHR > bestRoundHR {
//                        Utils.shared.say(sentence: "That was your fastest round and your highest score. \(stringer(dbl: spdToUse, len: 1)) MPH.  Your pace was \(calcMinPerMile(mph: spdToUse)) PER MILE")
//                    } else {
//                        Utils.shared.say(sentence: "That was your fastest round. \(stringer(dbl: spdToUse, len: 1)) MPH.  Your pace was \(calcMinPerMile(mph: spdToUse)) PER MILE")
//                    }
//                }
//            } else {
//                if audioStatus == "ON" {Utils.shared.say(sentence: "Round Complete. \(stringer(dbl: spdToUse, len: 1)) MPH.  Your pace was \(calcMinPerMile(mph: spdToUse)) PER MILE")}
//            }
//            if roundCadence > bestRoundCadence {bestRoundCadence = roundCadence}
//            if roundHR > bestRoundHR {bestRoundHR = roundHR}
//
//            if roundHR > 50 {
//                bestRoundScore = (bestRoundHR / Double(maxHRvalue)) * 100
//            } else {
//                bestRoundScore = 0
//            }
//
//
//            //MY BEST ROUNDS POINT
//            newRoundPoint(mileString: "MY BEST ROUNDS\n\(stringer(dbl: bestRoundSpeed, len: 1)) SPEED\n\(stringer(dbl: bestRoundCadence, len: 1)) CADENCE\n\(stringer(dbl: bestRoundHR, len: 1)) HR\n\(stringer(dbl: bestRoundScore, len: 1)) SCORE\n\(bestRoundPace) PACE\n")
//
//            arrResults.append("\(a)\(b)\(c)")
//            arrResultsDetails.append("\(d)\(e)\(f)")
//
//            if ConnectionCheck.isConnectedToNetwork() {
//                print("Connected to Internet")
//                print("calling fbPush")
//                fbPush(rSpeed: stringer(dbl: spdToUse, len: 2), rHeartrate: stringer(dbl: roundHR, len: 2), rScore: stringer(dbl: (roundHR / (Double(maxHRvalue)) * 100), len: 2), rCadence: stringer(dbl: roundCadence, len: 2))
//            }
//            else{
//                print("disConnected")
//            }
//
//
//
//        }
//
//    }  //end nrarray
    
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
    
    func createViewerArray() {
        
        processUD(st: "NEW createViewerArray")
        //ADD SUBS WHEN USING GEO...
        
        //HDR
        if geo.status == "ON/USE" || current.totalMovingTime == 0 {
            arr.append("\(createTimeString(seconds: Int(geo.elapsedTime)))  \(stringer(dbl: geo.avgSpeed, len: 1)) AVG")
        } else {
            arr.append("\(createTimeString(seconds: Int(current.totalMovingTime)))  \(stringer(dbl: current.totalAverageSpeed, len: 1)) AVG")
        }
        
        //3 VALS
        arr.append("\(stringer(dbl: Double(current.currentHR), len: 0))")
        tabBarController?.tabBar.items?[0].badgeValue = "\(stringer(dbl: Double(current.currentHR), len: 0))"
        
        if geo.status == "ON/USE" || current.totalMovingTime == 0 {
            arr.append("\(stringer(dbl: geo.speed, len: 1))")
            tabBarController?.tabBar.items?[1].badgeValue = "\(stringer(dbl: geo.speed, len: 1))"
        } else {
            arr.append("\(stringer(dbl: current.currentSpeed, len: 1))")
            tabBarController?.tabBar.items?[1].badgeValue = "\(stringer(dbl: current.currentSpeed, len: 1))"
        }
        
        if activityType == "RUN" {
            arr.append("\(geo.pace)")
        } else {
            arr.append("\(stringer(dbl: current.currentCadence, len: 0))")
            tabBarController?.tabBar.items?[3].badgeValue = "\(stringer(dbl: current.currentCadence, len: 0))"
        }
        
        //3 LBLS
        arr.append("\(stringer(dbl: current.currentScore, len: 0))%\nHR")
        arr.append("SPD\nMPH")
        
        if activityType == "RUN" {
            arr.append("PACE")
        } else {
            arr.append("CAD\nRPM")
        }
        
        //FOOTER
        if geo.distance > current.totalDistance {
            arr.append("\(createTimeString(seconds: Int(system.actualElapsedTime)))  \(stringer(dbl: geo.distance, len: 2)) MILES")
            tabBarController?.tabBar.items?[2].badgeValue = "\(stringer(dbl: longestDistance, len: 1)) MI"
        } else {
            arr.append("\(createTimeString(seconds: Int(system.actualElapsedTime)))  \(stringer(dbl: current.totalDistance, len: 2)) MILES")
            tabBarController?.tabBar.items?[2].badgeValue = "\(stringer(dbl: longestDistance, len: 1)) MI"
        }
        
        arrSend = arr
        arr = []
    }

    
    //NO LONGER USED
//    func updateViewer_VC() {
//
//        if geo.status == "ON/USE" {
//
//            //HEADER
//            if geo.distance < 0.1 {
//                arr.append("\(getFormattedTime(d: Date()))")
//            } else {
//             arr.append("\(gpsMovingTime.text ?? "00:00:00")  \(gpsAverageSpeed.text ?? "00.0 AVG") AVG MPH")
//            }
//
//
//            //3 VALUES
//            if btHR.text == " " {arr.append("\(gpsAvergagePace.text ?? "00")")} else {arr.append("\(btHR.text ?? "00")")}
//
//            arr.append("\(gpsMovingSpeed.text ?? "00.0")")
//            arr.append("\(gpsMovingPace.text ?? "00")")
//            //3 LABELS
//            if (btHR.text == " " || btHR.text == "") {
//                arr.append("PACE\n(AVG)")
//
//            } else {
//                arr.append("\(btScore.text ?? "00")")
//
//            }
//
//            arr.append("SPD\nMPH")
//            arr.append("PACE\n(MOV)")
//            //FOOTER
//            arr.append("\(totalTime.text ?? "00:00:00")  \(gpsDistance.text ?? "0.00 MILES")")
//            arrSend = arr
//            arr = []
//
//        } else {
//
//            //HDR
//            arr.append("\(btMovingTime.text ?? "00:00:00")  \(btMovAvg.text ?? "00.0 AVG")")
//            //3 VALS
//            arr.append("\(btHR.text ?? "00")")
//            arr.append("\(btMovingSpeed.text ?? "00.0")")
//            arr.append("\(btMovingCadence.text ?? "00")")
//            //3 LBLS
//            arr.append("\(btScore.text ?? "00")\nHR")
//            arr.append("SPD\nMPH")
//            arr.append("CAD\nRPM")
//            //FOOTER
//            arr.append("\(totalTime.text ?? "00:00:00")  \(btDistance.text ?? "0.00 MILES")")
//            arrSend = arr
//            arr = []
//
//        }
//
//
//
//        //NotificationCenter.default.post(name: NSNotification.Name("viewUpdate"), object: nil)
//    }
    
    
    
    
        //TEST FOR MILE
//        if btDistanceForMileCalc > currentMile || geo.distance > currentMile {
//            currentMile += 1.0
//            updateMile()
//        }
        
        //CALC ROUND SPEEDS BEFORE ROUND ENDS
//        if inRoundBtDistance > 0 && secondsInRound > 0 {
//            roundSpeed = inRoundBtDistance / (secondsInRound / 60.0 / 60.0)
//        }
        //ROUND END
//        if secondsInRound >= Double(secondsPerRound) {
//
//        //if  (((system.actualElapsedTime) != nil) && system.actualElapsedTime! >= Double(Double((roundsCompleted + 1)) * Double(secondsPerRound))) {
//            print("New Round")
//            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
//            roundsCompleted += 1
//            secondsInRound = 0
//
//            rounds.geoDistancesPerRound.append(inRoundGeoDistance)
//            rounds.btDistancesPerRound.append(inRoundBtDistance)

//            print("\n")
//            print("End of Round for HR, Spd, Cad, GeoSpd")
//            print(roundHR, roundSpeed, roundCadence, roundGeoSpeed)
//
//            print("secondsInRound, secondsSinceStart")
//            print(secondsInRound, secondsSinceStart)
//            print("\n")
            
            //createNRArray()
            
            //let tle = "ROUND COMPLETE"
            //let clr = "blue"
            
//            udString = "NEW SEND END ROUND TLUPDATE UPDATE NOTIFICATION, \(getFormattedTimeAndDate(d: Date()))\n"
//            udArray.append(udString)
//            let defaults = UserDefaults.standard
//            defaults.set(udArray, forKey: "SavedStringArray")
            
            
               //NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "\(tle) \n", "color": "\(clr)", "geospeed": stringer(dbl: roundGeoSpeed, len: 2),"hr": stringer(dbl: roundHR, len: 1), "score": stringer(dbl: (roundHR / (Double(maxHRvalue)) * 100.0), len: 1),"pace": (calcMinPerMile(mph: roundGeoSpeed)),"cadence": stringer(dbl: roundCadence, len: 1), "geodistance": stringer(dbl: geo.distance, len: 2), "btdistance": stringer(dbl: btDistanceForMileCalc, len: 2), "speed": stringer(dbl: roundSpeed, len: 2)])
            
//            rounds.speeds.append(roundSpeed)
//            rounds.geoSpeeds.append(roundGeoSpeed)
//            rounds.heartrates.append(roundHR)
//            if roundHR > 50 {rounds.scores.append(Double(roundHR/Double(maxHRvalue)*100))} else {rounds.scores.append(0)}
//            rounds.cadences.append(roundCadence)
            
//            print("\n")
//            print("End of Round for HR, Spd, Cad, GeoSpd")
//            dump(rounds.speeds)
//            dump(rounds.heartrates)
//            dump(rounds.cadences)
//            dump(rounds.geoSpeeds)
//            print("\n")
//            print("btAvgSpeed:  \(stringer(dbl: btAverageSpeed, len: 2))")
//            print("\n")
            
//            inRoundGeoDistance = 0
//            inRoundBtDistance = 0
//            inRoundCadence = []
//            inRoundHR = []
//        }
        
        
        //MID ROUND - DAILY UPDATE
        //if ( Int(secondsInRound) == (secondsPerRound / 2) ) {

            //let tle = "DAILY UPDATE"
            //let clr = "red"
            
            
//            NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"),
//                object: nil, userInfo: ["title": "\(tle) \n", "color": "\(clr)",
//                    "geodistance": stringer(dbl: geo.distance, len: 2),
//                    "btdistance": stringer(dbl: btDistanceForMileCalc, len: 2),
//                    "totaltime": totalTime.text as Any,
//                    "btmovingtime": btMovingTime.text as Any,
//                    "avgspeed": btMovAvg.text as Any,
//                    "gpsmovingtime": gpsMovingTime.text as Any,
//                    "avgpacegeo": gpsAvergagePace.text as Any,
//                    "avgspeedgeo": gpsAverageSpeed.text as Any])
            
//            if freshFB == true {
//                freshFB = false
//                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "DAILY AVG SPEEDS\n\n\(leaderNamesBySpeedTotals)", "color": "green"])
//
//                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "DAILY AVG SCORES\n\n\(leaderNamesByScoreTotals)", "color": "red"])
//
//                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "TOP 5 SPEEDS\n\n\(arrLeaderNamesBySpeed)", "color": "blue"])
//
//                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "TOP 5 SCORES\n\n\(arrLeaderNamesByScore)", "color": "black"])
//            }
            
        //}
        //end mid round
        
//        if roundSpeed > 0 {
//            btSpdRnd.text = stringer(dbl: roundSpeed, len: 1)
//        }
//        if roundCadence > 0 {
//            btCadRnd.text = stringer(dbl: roundCadence, len: 0)
//        }
//        if roundHR > 0 {
//            btHrRnd.text = stringer(dbl: roundHR, len: 0)
//            if roundHR > 50 {btScoreRnd.text = stringer(dbl: roundHR/Double(maxHRvalue)*100, len: 1)} else {btScoreRnd.text = "0"}
//        }
//
//
//        updateViewer_VC()
        
//    }  //END SECOND TIMER
    
    

    
    
    //@objc func updateBT(not: Notification) {
//        print("updateBT")
//        print("not:  \(not)")
        
//        // userInfo is the payload send by sender of notification
//        if let userInfo = not.userInfo {
//            // Safely unwrap the name sent out by the notification sender
//            if let userName = userInfo["name"] as? String {
//                print(userName)
//            }
//        }
        
        // userInfo is the payload send by sender of notification
        //if let userInfo = not.userInfo {
            //print(userInfo[AnyHashable("hr")]!)
            
            //better way, doesn't work
//            if let hrv2 = userInfo["hr"] as? Double {
//                //print("hrv2 as string \(stringer(dbl: hrv2, len: 0))")
//                let hrv3 = Double(hrv2)
//                btHR.text = stringer(dbl: hrv3, len: 0)
//                 tabBarController?.tabBar.items?[0].badgeValue = "\(stringer(dbl: hrv3, len: 0))"
//            }
            
            //if let hrv = userInfo[AnyHashable("hr")] {
                //print(String(describing: userInfo[AnyHashable("hr")]!))
//                btHR.text = "\(hrv as! String)"  //HR
//                tabBarController?.tabBar.items?[0].badgeValue = "\(hrv as! String)"
//            }
//            if let scv = userInfo[AnyHashable("score")] {
//                //print(String(describing: userInfo[AnyHashable("score")]!))
//                btScore.text = "\(scv as! String) %"
//                tabBarController?.tabBar.items?[1].badgeValue = "\(scv as! String)%"
//            }
//            if let spv = userInfo[AnyHashable("spd")] {
//                //print(String(describing: userInfo[AnyHashable("spd")]!))
//                btMovingSpeed.text = "\(spv as! String)"//SPD BT
//                tabBarController?.tabBar.items?[3].badgeValue = "\(spv as! String)"
//            }
//            if let cav = userInfo[AnyHashable("cad")] {
//                //let d_cav = cav as? Double
//                //print(d_cav ?? 0.0)
//                btMovingCadence.text = "\(cav as! String)"  //   CAD BT"
//                tabBarController?.tabBar.items?[2].badgeValue = "\(cav as! String)"
//            }
//            if let dsv = userInfo[AnyHashable("dist")] {
//                btDistance.text = "\(dsv as! String) MILES"  //DISTANCE BT
//            }
//            if let mtv = userInfo[AnyHashable("mov")] {
//                btMovingTime.text = "\(mtv as! String)"   //MOVING TIME BT
//            }
//            if let mvavg = userInfo[AnyHashable("mov_avg")] {
//                btMovAvg.text = "\(mvavg as! String) AVG"  //MOV AVG
//            }
//
//        }
//    }
    
    
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: timerIntervalValue,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
        print("Started")
        print(getFormattedTime(d: system.startTime!))
        print(getFormattedTimeAndDate(d: system.startTime!));print("\n");
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        
        switch indexPath.row {
        case 1:
            print("Start/Stop/Reset")
            
            if ConnectionCheck.isConnectedToNetwork() {
                print("Connected to Internet")
            }
            else{
                print("disConnected")
            }
            
            if system.status == "STOPPED" {
                system.status = "STARTED";statusValue.text = "STARTED";
                //system.startTime = Date()
                system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
                
                if geo.status == "ON" {
                    //geo.startTime = Date()
                    startLocationUpdates()
                }
                
                if geo.status == "ON/USE" {
                    //geo.startTime = Date()
                }
                
                startTimer()
                

                
                //NotificationCenter.default.addObserver(self, selector: #selector(updateBT(not:)), name: Notification.Name("bleUpdate"), object: nil)
                
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
//            if gst == "ON" {geo.status = "ON/USE";gpsStatus.text = "ON/USE";startLocationUpdates();}
                if gst == "ON" {geo.status = "ON/USE";gpsStatus.text = "ON/USE";}
//            if gst == "ON/USE" {geo.status = "OFF";gpsStatus.text = "OFF";stopLocationUpdates()}
            if gst == "ON/USE" {geo.status = "OFF";gpsStatus.text = "OFF";stopLocationUpdates();}
//            if gst == "OFF" {geo.status = "ON";gpsStatus.text = "ON";startLocationUpdates()}
            if gst == "OFF" {geo.status = "ON";gpsStatus.text = "ON";}
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
            if lblAudioStatus.text == "OFF" {audioStatus = "ON";lblAudioStatus.text = "ON";print("audioStatus is ON");} else {audioStatus = "OFF";lblAudioStatus.text = "OFF"}
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
            let spr = secondsPerRound
            //if lblSecPerRound.text == "60"{secondsPerRound = 300;lblSecPerRound.text = "300";} else {secondsPerRound = 60;lblSecPerRound.text = "60";}
            if spr == 60 {secondsPerRound = 300;lblSecPerRound.text = "300"}
            if spr == 300 {secondsPerRound = 1800;lblSecPerRound.text = "1800"}
            if spr == 1800 {secondsPerRound = 60;lblSecPerRound.text = "60"}
            
        case 13:
            print("13")
            if audioStatus == "ON" {Utils.shared.say(sentence: "OK Kazumi, Let's Go")}

            //CLEAR HISTORY
            udArray = []
            udArray.append("CLEARED")
            let defaults = UserDefaults.standard
            defaults.set(udArray, forKey: "SavedStringArray")
            //CLEAR DB
            let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/")
            refDB.removeValue()


            
        default:
            print("DO NOTHING")
        }
        
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        system.startTime = Date()
        system.actualElapsedTime = getTimeIntervalSince(d1: system.startTime!, d2: Date())
        
        let defaults = UserDefaults.standard
        udArray = defaults.stringArray(forKey: "SavedStringArray") ?? [String]()
        udString = "NEW ACTIVITY, \(getFormattedTimeAndDate(d: Date()))\n"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //FB PUSH, AT ROUND COMPLETE
    func fbPushII() {
        
       
//    func fbPush(rSpeed: String, rHeartrate: String, rScore: String, rCadence: String) {
        //send round data to fb
        print("Start fbPush")
        processUD(st: "Start fbPush")
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        
        if roundsCompleted > 0 {
            // FIREBASE PUSH  - START
            let round_post = [
                "a_calcDurationPost" : roundsCompleted * 5,
                "a_scoreRoundLast" : rounds.scores.last!,
                "a_speedRoundLast" : rounds.speeds.last!,
                "fb_CAD" : rounds.cadences.last!,
                "fb_Date" : result,
                "fb_DateNow" : result,
                "fb_HR" : rounds.heartrates.last!,
                "fb_RND" : rounds.scores.last!,
                "fb_SPD" : rounds.speeds.last!,
                "fb_maxHRTotal" : maxHRvalue,
                "fb_scoreHRRound" : rounds.scores.last!,
                "fb_scoreHRRoundLast" : rounds.scores.last!,
                "fb_scoreHRTotal" : rounds.scores.last!,
                "fb_timAvgCADtotal" : rounds.cadences.last!,
                "fb_timAvgHRtotal" : rounds.scores.last!,
                "fb_timAvgSPDtotal" : rounds.speeds.last!,
                "fb_timDistanceTraveled" : longestDistance,
                "fb_timGroup" : "iOS",
                "fb_timName" : riderName,
                "fb_timTeam" : "Square Pizza"
                ] as [String : Any]
            
            
//            let round_post = [
//                "a_calcDurationPost" : roundsCompleted * 5,
//                "a_scoreRoundLast" : rScore.toDouble,
//                "a_speedRoundLast" : rSpeed.toDouble,
//                "fb_CAD" : rCadence.toDouble,
//                "fb_Date" : result,
//                "fb_DateNow" : result,
//                "fb_HR" : rHeartrate.toDouble,
//                "fb_RND" : rScore.toDouble,
//                "fb_SPD" : rSpeed.toDouble,
//                "fb_maxHRTotal" : maxHRvalue,
//                "fb_scoreHRRound" : rScore.toDouble,
//                "fb_scoreHRRoundLast" : rScore.toDouble,
//                "fb_scoreHRTotal" : rScore.toDouble,
//                "fb_timAvgCADtotal" : rCadence.toDouble,
//                "fb_timAvgHRtotal" : rScore.toDouble,
//                "fb_timAvgSPDtotal" : rSpeed.toDouble,
//                "fb_timDistanceTraveled" : current.totalDistance,
//                "fb_timGroup" : "iOS",
//                "fb_timName" : riderName,
//                "fb_timTeam" : "Square Pizza"
//                ] as [String : Any]
            
            let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds/\(result)")
            refDB.childByAutoId().setValue(round_post)
            print("Complete pushFBRound")
            processUD(st: "Complete pushFBRound")
        }
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            print("calling fbPost for Totals")
            self.fbPost()
        }
        
        

    }
    
    //FB POST, AT ROUND COMPLETE
    func fbPost() {
        processUD(st: "fbPost")
        var tSpeed = geo.avgSpeed
        if current.totalAverageSpeed > geo.avgSpeed {
            tSpeed = current.totalAverageSpeed
        }
        tSpeed = tSpeed * 100
        tSpeed = round(tSpeed)
        tSpeed = tSpeed / 100
        
        
        //var tScore = stringer(dbl: (rounds.heartrates.average / Double(maxHRvalue)) * 100, len: 1)
        //let tScore = round(((rounds.heartrates.average / Double(maxHRvalue)) * 100) * 100) / 100
        
        let tScore = getScoreFromHR(x: rounds.heartrates.average)
        
        //let tCadence = stringer(dbl: rounds.cadences.average, len: 1)
        let tCadence = rounds.cadences.average
        
        print("Start fbPost for Totals")
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        
        if roundsCompleted > 0 {
            // FIREBASE TOTALS POST
            let totals_post = [
                "a_calcDurationPost" : roundsCompleted * 5,
                "a_scoreHRRoundLast" : tScore,
                "a_scoreHRTotal" : tScore,
                "a_speedLast" : tSpeed,
                "a_speedTotal" : tSpeed,
                "fb_CAD" : tCadence,
                "fb_Date" : result,
                "fb_DateNow" : result,
                "fb_maxHRTotal" : maxHRvalue,
                "fb_scoreHRRound" : tScore,
                "fb_scoreHRRoundLast" : tScore,
                "fb_scoreHRTotal" : tScore,
                "fb_timAvgCADtotal" : tCadence,
                "fb_timAvgHRtotal" : tScore,
                "fb_timAvgSPDtotal" : tSpeed,
                "fb_timDistanceTraveled" : longestDistance,
                "fb_timGroup" : "iOS",
                "fb_timName" : riderName,
                "fb_timTeam" : "Square Pizza"
                ] as [String : Any]
            
            let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)/\(riderName)")
            refDB.setValue(totals_post)
            print("Complete postFBTotals")
            processUD(st: "Complete fbPost")
        } else {
                self.tabBarController?.selectedIndex = 3
        }
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            
            if ConnectionCheck.isConnectedToNetwork() {
                print("Connected to Internet")
                print("calling fb1")
                self.fb1()
            }
            else{
                print("disConnected")
            }
        }
    }
    
    var freshFB = false
    var arrLeaderNamesByScore: String = ""
    //FB GETS (1,2,3,4)
    func fb1() {
        print("start fb1")
        processUD(st: "start fb1")
        arrLeaderNamesByScore = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        //let result = "20170527"
        let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
        let ref = refDB.child(result)
        _ = ref.queryLimited(toLast: 5).queryOrdered(byChild: "fb_RND").observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                //print("fb1, have a snapshot")
                for child in (snapshot.children) {
                    //print("fb1, have a child")
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

                    self.arrLeaderNamesByScore = "\(sRND) %  \(fbNAME)\n" + self.arrLeaderNamesByScore
                }
                print("Completed:  (Round) Get 5 leaders, ordered by score")
                print(self.arrLeaderNamesByScore)
                udArray.append("\(getFormattedTimeAndDate(d: Date()))\nROUND LEADERS (SCORE)\n\(self.arrLeaderNamesByScore)")
                print("\n")
//                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "TOP 5 SCORES\n\n\(self.arrLeaderNamesByScore)", "color": "black"])
            }
        })
        { (error) in
            print(error.localizedDescription);print("error fb1");}
        print("fb1 complete")
        processUD(st: "fb1 complete")
        let when = DispatchTime.now() + 10
        DispatchQueue.main.asyncAfter(deadline: when){
            print("calling fb2")
            self.fb2()
        }
    }
    
    
    var previousSpeedLeader = ""
    var arrLeaderNamesBySpeed: String = ""
    func fb2() {
        print("start fb2")
        processUD(st: "start fb2")
        arrLeaderNamesBySpeed = ""
        //var readMe: String = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
        let ref = refDB.child(result)
        _ = ref.queryLimited(toLast: 5).queryOrdered(byChild: "fb_SPD").observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    //print("fb2, have a child")
                    var sSPD = "0"
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let fbNAME = dict["fb_timName"]!
                    let fbSPD = dict["fb_SPD"]!
                    
                    
                    if let dSPD = fbSPD as? Double {
                        sSPD = stringer(dbl: dSPD, len: 1)
                    } else {
                        sSPD = "0"
                    }
                    self.arrLeaderNamesBySpeed = "\(sSPD) MPH  \(fbNAME)\n" + self.arrLeaderNamesBySpeed
                }
                print("Completed:  (Round) Get 5 leaders, ordered by speed")
                print(self.arrLeaderNamesBySpeed)
                udArray.append("\(getFormattedTimeAndDate(d: Date()))\nROUND LEADERS (SPEED)\n\(self.arrLeaderNamesBySpeed)")
                print("\n")
                //NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "TOP 5 SPEEDS\n\n\(self.arrLeaderNamesBySpeed)", "color": "blue"])
                
                self.newBestSpeedsPoint(mileString: "TOP SPEEDS\n\n\(self.arrLeaderNamesBySpeed)")
                
//                if readMe != self.previousSpeedLeader {
//                    if self.audioStatus == "ON" {Utils.shared.say(sentence: "\(readMe), is the fastest.")}
//                }
//                print("start fb3")
//                let _ = self.fb3()
//                self.previousSpeedLeader = readMe

            }
        })
        { (error) in
            print(error.localizedDescription);print("error fb2");}
        print("fb2 complete")
        processUD(st: "fb2 complete")
        let when = DispatchTime.now() + 10
        DispatchQueue.main.asyncAfter(deadline: when){
            print("calling fb3")
            self.fb3()
        }
    }
    
    var leaderNamesByScoreTotals: String = ""
    func fb3() { //get Totals from fb, ordered by score
        print("start fb3")
        processUD(st: "start fb3")
        leaderNamesByScoreTotals = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        var sSCORE: String = "0"
        let ref = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)")
        ref.queryLimited(toLast: 10).queryOrdered(byChild: "a_scoreHRTotal").observeSingleEvent(of: .value, with: { snapshot in
            if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let fbNAME = dict["fb_timName"]!
                    let fbSCORE = dict["a_scoreHRTotal"]!
                    
                    
                    if let dSCORE = fbSCORE as? Double {
                        sSCORE = stringer(dbl: dSCORE, len: 1)
                    } else {
                        sSCORE = "0"
                    }
                    
                    self.leaderNamesByScoreTotals = "\(sSCORE)%  \(fbNAME)\n" + self.leaderNamesByScoreTotals
                    
                }
                print("leaderNamesByScoreTotals\n\(self.leaderNamesByScoreTotals) \n")
                udArray.append("\(getFormattedTimeAndDate(d: Date()))\nSCORE LEADERS (TOTAL)\n\(self.leaderNamesByScoreTotals)")
                
//                NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "BEST DAILY AVG SCORES\n\n\(leaderNamesByScoreTotals)", "color": "red"])
                print("Complete fb3")
               

            }
        })
        { (error) in
            print(error.localizedDescription);print("error fb3");}
        print("fb3 complete")
         processUD(st: "complete fb3")
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            print("calling fb4")
            self.fb4()
        }
    }  //fb3 complete
    
    var leaderNamesBySpeedTotals: String = ""
    func fb4() { //get Totals from fb, ordered by speed
        print("start fb4")
         processUD(st: "start fb4")
        leaderNamesBySpeedTotals = ""
        let date = Date();let formatter = DateFormatter();formatter.dateFormat = "yyyyMMdd";let result = formatter.string(from: date)
        
        let ref = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)")
        ref.queryLimited(toLast: 10).queryOrdered(byChild: "a_speedTotal").observeSingleEvent(of: .value, with: { snapshot in
                if ( snapshot.value is NSNull ) {
                print("not found")
            } else {
                for child in (snapshot.children) {
                    var sSPD = "0"
                    let snap = child as! FIRDataSnapshot //each child is a snapshot
                    let dict = snap.value as! NSDictionary // the value is a dict
                    let fbNAME = dict["fb_timName"]!
                    let fbSPEED = dict["a_speedTotal"]!
                    
                    if let dSPD = fbSPEED as? Double {
                        sSPD = stringer(dbl: dSPD, len: 1)
                    } else {
                        sSPD = "0"
                    }

                    self.leaderNamesBySpeedTotals = "\(sSPD) MPH  \(fbNAME)\n" + self.leaderNamesBySpeedTotals
                    
                }
                print("Complete fb4")
                print("leaderNamesBySpeedTotals\n\(self.leaderNamesBySpeedTotals)\n")
                udArray.append("\(getFormattedTimeAndDate(d: Date()))\nSPEED LEADERS (TOTAL)\n\(self.leaderNamesBySpeedTotals)")
                    
                self.freshFB = true
                //NotificationCenter.default.post(name: NSNotification.Name("tlUpdate"), object: nil, userInfo: ["title": "FASTEST AVG SPEEDS\n\n\(leaderNamesBySpeedTotals)", "color": "green"])
            }
        })
        { (error) in
            print(error.localizedDescription);print("error fb4");}
        print("fb4 complete")
        processUD(st: "complete fb4")
    }  //fb4 complete
   
    
    private func startLocationUpdates() {
        print("startLocationUpdates")
        locationManager.delegate = self
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
    
    
    
    private let locationManager = LocationManager.shared
    private var locations: [CLLocation] = []

}

extension Starter_VC: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Loc did fail:  \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {

            
            let howRecent = location.timestamp.timeIntervalSinceNow
            guard location.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if self.locations.count > 1 {
                let ts = Double((location.timestamp.timeIntervalSince(self.locations.last!.timestamp)))
                if ts < 20 {
                    geo.elapsedTime += ts
                    //totalTime.text = "\(createTimeString(seconds: Int((secondsSinceStart)))) TOTAL TIME"
                    gpsMovingTime.text = "\(createTimeString(seconds: Int((geo.elapsedTime)))) MOVING(G)"
                }
            }

            
                if self.locations.count > 2 {
                    if location.distance(from: self.locations.last!) < 161 {  // 1/10th of a mile
                        processUD(st: "calc location data")
                        
                        la = (self.locations.last?.coordinate.latitude)!
                        lo = (self.locations.last?.coordinate.longitude)!
                        geo.distance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                        //inRoundGeoDistance += location.distance(from: self.locations.last!) *  0.000621371 //Miles
                        
                        lastLocationTimeStamp = location.timestamp
                        


                        var coords = [CLLocationCoordinate2D]()
                        coords.append(self.locations.last!.coordinate)
                        coords.append(location.coordinate)
                        
                        if location.speed > 0 {
                            geo.speed = location.speed * 2.23694
                            gpsMovingSpeed.text = "\(stringer(dbl: geo.speed,len: 1)) MPH(G)"
                            
                            
                            geo.pace = calcMinPerMile(mph: geo.speed)
                            gpsMovingPace.text = "\(String(describing: geo.pace)) PACE(G)"
                            gpsDistance.text = "\(stringer(dbl: geo.distance, len: 2)) MI(G)"
                            
                            geo.avgSpeed = Double(Double(geo.distance) / Double(geo.elapsedTime / 60 / 60))
                            gpsAverageSpeed.text = "\(stringer(dbl: geo.avgSpeed, len: 1)) AVG(G)"
                            gpsAvergagePace.text = "\(calcMinPerMile(mph: geo.avgSpeed)) AVG(G)"
                            
                            if activityType == "RUN" {
                            tabBarController?.tabBar.items?[3].badgeValue = "\(String(describing: geo.pace))"
                            tabBarController?.tabBar.items?[2].badgeValue = "\(stringer(dbl: geo.distance, len: 2)) MI"
                            }
                            
                        }





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
