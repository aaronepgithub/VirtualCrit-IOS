//
//  Model.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation
import Firebase


//func getRoundDataGlobal() {
//    
//    score_string_array = []
//    speed_string_array = []
//    
//    let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/" + Settings.dateToday + ".json"
//    let url = NSURL(string: todosEndpoint)
//    
//    //print(1)
//    URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
//        
//        if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
//            
//            if jsonObj == nil {
//                return
//            }
//            
//            for (key, _) in jsonObj! {
//                
//                if let nestedDictionary = jsonObj?[key] as? [String: Any] {
//                    for(key, _) in nestedDictionary {
//                        
//                        if key == "fb_RND" {
//                            let a = nestedDictionary["fb_RND"] as! Double
//                            let b = nestedDictionary["fb_timName"] as! String!
//                            let c = nestedDictionary["fb_SPD"] as! Double!
//                            
//                            score_string_array.append(String(describing: a) + " %MAX  " + String(describing: b!) + " | " + String(describing: c!) + " MPH")
//                        }
//                        
//                        if key == "fb_SPD" {
//                            let d = nestedDictionary["fb_SPD"] as! Double
//                            let e = nestedDictionary["fb_timName"] as! String!
//                            let f = nestedDictionary["fb_RND"] as! Double!
//                            
//                            speed_string_array.append(String(describing: d) + " MPH  " + String(describing: e!) + " | " + String(describing: f!) + " %MAX")
//                        }
//                    }
//                }
//            }
//            //at the end
//            score_string_array.sort { $0 > $1 }
//            speed_string_array.sort { $0.compare($1, options: .numeric) == .orderedDescending }
//            
//            let stringOfWords = score_string_array[0]
//            let stringOfWordsArray = stringOfWords.components(separatedBy: " ")
//            //                print(stringOfWordsArray[0])
//            //                print(stringOfWordsArray[3])
//            //Rounds.roundLeaderName = stringOfWordsArray[0]
//            //Rounds.roundLeaderScore = stringOfWordsArray[3]
//            Leaderboard.scoreLeaderScore = stringOfWordsArray[0]
//            Leaderboard.scoreLeaderName = stringOfWordsArray[3]
//            
//            let stringOfWords2 = speed_string_array[0]
//            let stringOfWordsArray2 = stringOfWords2.components(separatedBy: " ")
//            //                print(stringOfWordsArray2[0])
//            //                print(stringOfWordsArray2[3])
//            Leaderboard.speedLeaderScore = stringOfWordsArray2[0]
//            Leaderboard.speedLeaderName = stringOfWordsArray2[3]
//            
//            //self.alert(message: "\(Leaderboard.scoreLeaderName) , \(Leaderboard.scoreLeaderScore) , \(Leaderboard.speedLeaderName) , \(Leaderboard.speedLeaderScore)  ", title: "Leaders")
//            
//            Leaderboard.roundLeadersString = "\(Leaderboard.scoreLeaderName),\(Leaderboard.scoreLeaderScore),\(Leaderboard.speedLeaderName),\(Leaderboard.speedLeaderScore)"
//            print(Leaderboard.roundLeadersString)
//            
//            
//        }
//    }).resume()
//}


struct Device {
    //HR
    static let TransferService = "0x180D"
    static let TransferCharacteristic = "0x2A37"
    //CSC
    static let TransferServiceCSC = "0x1816"
    static let TransferCharacteristicCSC = "0x2A5B"
    
    static let WHEEL_REVOLUTION_FLAG               : UInt8 = 0x01
    static let CRANK_REVOLUTION_FLAG               : UInt8 = 0x02
    
    static var oldWheelRevolution                  : Double = 0
    static var oldCrankRevolution                  : Double = 0

    static var oldWheelEventTime                   : Double = 0
    static var oldCrankEventTime                   : Double = 0
    
    static var oldTravelCadence                    : Double = 0
    
    static var currentCadence                      : Double = 0
    static var currentSpeed                        : Double = 0
    static var currentHeartrate                    : Double = 0

    static var totalTravelDistance                 : Double?
    static var travelDistance                      : Double?
    static var wheelCircumference                  : Double?
    
    static var maxHR                                : Double = 185
    
    static var totalDistanceII                      : Double = 0.0
    
    //test for 3 sec real-time reading
    static var ThreeSecondSpeed                     : Double = 0
    static var ThreeSecondCadence                   : Double = 0
    
    static var ThreeSecondDistance                  : Double = 0
    static var ThreeSecondCrankRevs                 : Double = 0
    static var ThreeSecondCrankRevsTime                 : Double = 0
    static var ThreeSecondDistanceTime                 : Double = 0
    
    

}


struct Settings {
    static var riderName = "Tim"
    static var wheelSize_mm = "25"
    static var maxHeartrate = "185"
    static var dateToday = "20170108"
}


struct Totals {
    static var distanceTotal: Double = 0

    static var wheelEventTimeDiffTotal  : Double = 0
    static var wheelRevolutionDiffTotal : Double = 0
    static var crankRevolutionDiffTotal : Double = 0
    static var crankEventTimeDiffTotal  : Double = 0
    
    static var arrHRTotal = [Double]()
    
    static var distance                 : Double = 0
    static var avg_speed                : Double = 0
    static var avg_cad                  : Double = 0
    static var avg_hr                   : Double = 0
    
    static var startTime                : NSDate?
    
    static var currentTime              : NSDate?
    static var durationTotal            : TimeInterval?
    
    static var totalWheelEventTime      : Double = 0
    static var displayedTime = "00:00:00"
    
    static var totalTimeInSeconds       : Int = 0
    
}

struct Rounds {
    static var roundStartTime           : NSDate?
    static var roundCurrentTimeElapsed  : TimeInterval?
    static var roundsComplete           : Int = 0
    
    static var arrHRRound = [Double]()  //during the round
    static var arrDistances = [Double]()
    
    
    static var totalWheelEventTime      : Double = 0
    static var distanceRound            : Double = 0
    
    static var avg_speed                : Double = 0
    static var avg_hr                   : Double = 0
    static var avg_score                : Double = 0
    static var avg_cadence              : Double = 0
    
    static var crankRevolutions         : Double = 0
    static var crankRevolutionTime      : Double = 0
    
    static var fastestSpeed = "0"
    static var highestHR = "0"
    
    static var roundLeaderName = " "
    static var roundLeaderScore = " "
    

}

struct AllRounds {

    static var arrHR = [Double]()
    static var arrSPD = [Double]()
    static var arrCAD = [Double]()
    

}

struct Leaderboard {

    static var scoreLeaderName = "Undefined"
    static var scoreLeaderScore = "0"
    
    static var speedLeaderName = "Undefined"
    static var speedLeaderScore = "0"
    
    static var roundLeadersString = "Undefined"

}

func getFirebase() {  //get Round leaders

    score_string_array = []
    //speed_string_array = []
    
    var arrRoundLeaders = [String]()

    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let result = formatter.string(from: date)
    
    var counter = 0
    
    // FIREBASE GET  - START
    let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
    let ref = refDB.child(result)
    
    
    ref.queryLimited(toLast: 50).queryOrdered(byChild: "fb_RND").observeSingleEvent(of: .value, with: { snapshot in
        
        if ( snapshot.value is NSNull ) {
            print("not found")
        } else {
            for child in (snapshot.children) {
                
                let snap = child as! FIRDataSnapshot //each child is a snapshot
                let dict = snap.value as! NSDictionary // the value is a dict
                let fbRND = dict["fb_RND"]!
                let fbNAME = dict["fb_timName"]!
                let fbSPD = dict["fb_SPD"]!
                
                print("\(counter) : \(fbNAME) score :  \(fbRND) :  \(fbSPD)")
                arrRoundLeaders.insert("\(counter) : \(fbNAME) : \(fbRND) : \(fbSPD)", at: 0)
                
                let x = dict["fb_RND"]! as! Double
                let y = String(format: "%.1f", x)
                
                let xx = dict["fb_SPD"]! as! Double
                let yy = String(format: "%.1f", xx)
                
                score_string_array.insert(String(describing: y) + " %MAX  " + String(describing: fbNAME) + " | " + String(describing: yy) + " MPH", at: 0)
                
                counter += 1
                Leaderboard.scoreLeaderName = "\(fbNAME)"
                Leaderboard.scoreLeaderScore = "\(y)"
                
                Leaderboard.roundLeadersString = "\(Leaderboard.scoreLeaderName),\(Leaderboard.scoreLeaderScore),\(Leaderboard.speedLeaderName),\(Leaderboard.speedLeaderScore)"
            }
            print("Complete getFBScore")
        }
    })
}

func getFirebaseSpeed() {
    
    speed_string_array = []
    
    var arrRoundLeaders = [String]()
    
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let result = formatter.string(from: date)
    
    var counter = 0
    
    // FIREBASE GET ROUND SPEED - START
    let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds")
    let ref = refDB.child(result)
    
    
    ref.queryLimited(toLast: 50).queryOrdered(byChild: "fb_SPD").observeSingleEvent(of: .value, with: { snapshot in
        
        if ( snapshot.value is NSNull ) {
            print("not found")
        } else {
            for child in (snapshot.children) {
                
                let snap = child as! FIRDataSnapshot //each child is a snapshot
                let dict = snap.value as! NSDictionary // the value is a dict
                let fbRND = dict["fb_RND"]!
                let fbNAME = dict["fb_timName"]!
                let fbSPD = dict["fb_SPD"]!
                
                print("\(counter) : \(fbNAME) speed :  \(fbSPD) :  \(fbRND)")
                arrRoundLeaders.insert("\(counter) : \(fbNAME) : \(fbRND) : \(fbSPD)", at: 0)
                
                let x = dict["fb_RND"]! as! Double
                let y = String(format: "%.1f", x)
                
                let xx = dict["fb_SPD"]! as! Double
                let yy = String(format: "%.1f", xx)
                
                speed_string_array.insert(String(describing: yy) + " Mph  " + String(describing: fbNAME) + " | " + String(describing: y) + " %MAX", at: 0)
                //speed_string_array.append(String(describing: d) + " MPH  " + String(describing: e!) + " | " + String(describing: f!) + " %MAX")
                
                
                counter += 1
                Leaderboard.speedLeaderName = "\(fbNAME)"
                Leaderboard.speedLeaderScore = "\(yy)"
                
                Leaderboard.roundLeadersString = "\(Leaderboard.scoreLeaderName),\(Leaderboard.scoreLeaderScore),\(Leaderboard.speedLeaderName),\(Leaderboard.speedLeaderScore)"
            }
            print("Complete getFBSpeed")
        }
    })
}

func pushFBRound() {
    //send round data to fb
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let result = formatter.string(from: date)
    
    let aa = AllRounds.arrHR.last
    let ab = aa! / Device.maxHR * 100
    let xx = "\(String(format:"%.1f", aa!))"
    let yy = "\(String(format:"%.1f", AllRounds.arrSPD.last!))"
    let zz = "\(String(format:"%.1f", ab))"
    let zzz = Double(zz) ?? 0 as Any
    let yyy = Double(yy) ?? 0 as Any
    
    
    if Rounds.roundsComplete >= 0 {
        // FIREBASE PUSH  - START
        let round_post = [
            "a_calcDurationPost" : Rounds.roundsComplete * 5,
            "a_scoreRoundLast" : zzz,
            "a_speedRoundLast" : yyy,
            "fb_CAD" : 0,
            "fb_Date" : result,
            "fb_DateNow" : result,
            "fb_HR" : Double(xx) ?? 0 as Any,
            "fb_RND" : zzz,
            "fb_SPD" : yyy,
            "fb_maxHRTotal" : 0,
            "fb_scoreHRRound" : zzz,
            "fb_scoreHRRoundLast" : zzz,
            "fb_scoreHRTotal" : zzz,
            "fb_timAvgCADtotal" : 0,
            "fb_timAvgHRtotal" : zzz,
            "fb_timAvgSPDtotal" : yyy,
            "fb_timDistanceTraveled" : 0,
            "fb_timGroup" : "iOS",
            "fb_timName" : Settings.riderName,
            "fb_timTeam" : "Square Pizza"
            ] as [String : Any]
        
        let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/rounds/\(result)")
        refDB.childByAutoId().setValue(round_post)
        print("Complete pushFBRound")
    }
} // end fb post


func pushFBTotals() {
    //send totals data to fb
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let result = formatter.string(from: date)
    
    let a = Totals.avg_hr / Device.maxHR * 100
    let y = "\(String(format:"%.1f", Totals.avg_speed))"
    let z = "\(String(format:"%.1f", a))"
    
    let yyy = Double(y) ?? 0 as Any
    let zzz = Double(z) ?? 0 as Any
    
    
    if Rounds.roundsComplete >= 0 {
        // FIREBASE PUSH  - START
        let totals_post = [
            "a_calcDurationPost" : Rounds.roundsComplete * 5,
            "a_scoreHRRoundLast" : zzz,
            "a_scoreHRTotal" : zzz,
            "a_speedLast" : yyy,
            "a_speedTotal" : yyy,
            "fb_CAD" : 0,
            "fb_Date" : result,
            "fb_DateNow" : result,
            "fb_maxHRTotal" : 0,
            "fb_scoreHRRound" : zzz,
            "fb_scoreHRRoundLast" : zzz,
            "fb_scoreHRTotal" : zzz,
            "fb_timAvgCADtotal" : 0,
            "fb_timAvgHRtotal" : zzz,
            "fb_timAvgSPDtotal" : yyy,
            "fb_timDistanceTraveled" : 0,
            "fb_timGroup" : "iOS",
            "fb_timName" : Settings.riderName,
            "fb_timTeam" : "Square Pizza"
            ] as [String : Any]
        
        let refDB  = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)/\(Settings.riderName)")
        refDB.setValue(totals_post)
        
        print("Complete pushFBTotals")
    }
}
// end fb totals post

func getFBTotals() { //get Totals from fb, ordered by score
    
    score_string_array_total = []
    var counter = 0
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let result = formatter.string(from: date)
    
    // FIREBASE GET TOTAL SCORE - START
    
    let ref = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)")
    
    ref.queryLimited(toLast: 50).queryOrdered(byChild: "a_scoreHRTotal").observeSingleEvent(of: .value, with: { snapshot in
        
        if ( snapshot.value is NSNull ) {
            print("not found")
        } else {
            for child in (snapshot.children) {
                let snap = child as! FIRDataSnapshot //each child is a snapshot
                let dict = snap.value as! NSDictionary // the value is a dict
                
                let fbNAME = dict["fb_timName"]!
                let x = dict["a_scoreHRTotal"]! as! Double
                let y = String(format: "%.1f", x)
                
                let xx = dict["a_speedTotal"]! as! Double
                let yy = String(format: "%.1f", xx)
                
                print("\(counter) : \(fbNAME) score :  \(y) :  \(yy)")
                
                score_string_array_total.insert(String(describing: y) + " %MAX  " + "\n" + String(describing: fbNAME) + " | " + String(describing: yy) + " MPH", at: 0)
                counter += 1
            }
            
            print("Complete getFBTotals")
        }
        
    })
    
}

// END get total leaders from fb


func getFBTotalsSpeed() { //get Totals from fb, ordered by Speed
    
    speed_string_array_total = []
    
    var counter = 0
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    let result = formatter.string(from: date)
    
    // FIREBASE GET SPEED TOTALS  - START
    
    let ref = FIRDatabase.database().reference(fromURL: "https://virtualcrit-47b94.firebaseio.com/totals/\(result)")
    
    ref.queryLimited(toLast: 50).queryOrdered(byChild: "a_speedTotal").observeSingleEvent(of: .value, with: { snapshot in
        
        if ( snapshot.value is NSNull ) {
            print("not found")
        } else {
            for child in (snapshot.children) {
                let snap = child as! FIRDataSnapshot //each child is a snapshot
                let dict = snap.value as! NSDictionary // the value is a dict
                let fbNAME = dict["fb_timName"]!

                
                let x = dict["a_scoreHRTotal"]! as! Double
                let y = String(format: "%.1f", x)
                
                let xx = dict["a_speedTotal"]! as! Double
                let yy = String(format: "%.1f", xx)
                
                print("\(counter) : \(fbNAME) speed :  \(yy) :  \(y)")
                
                speed_string_array_total.insert(String(describing: yy) + " MPH  " + "\n" + String(describing: fbNAME) + " | " + String(describing: y) + " %MAX", at: 0)
                counter += 1
            }
            
            print("Complete getFBTotals - Speed")
        }
        
    })
    
}

// END get total SPEED leaders from fb





