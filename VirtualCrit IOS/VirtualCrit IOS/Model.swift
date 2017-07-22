//
//  Model.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation


func getRoundDataGlobal() {
    
    //print("httpGet Started")
    let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/" + Settings.dateToday + ".json"
    let url = NSURL(string: todosEndpoint)
    
    //print(1)
    URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
        
        if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
            
            if jsonObj == nil {
                return
            }
            
            for (key, _) in jsonObj! {
                
                if let nestedDictionary = jsonObj?[key] as? [String: Any] {
                    for(key, _) in nestedDictionary {
                        
                        if key == "fb_RND" {
                            let a = nestedDictionary["fb_RND"] as! Double
                            let b = nestedDictionary["fb_timName"] as! String!
                            let c = nestedDictionary["fb_SPD"] as! Double!
                            
                            score_string_array.append(String(describing: a) + " %MAX  " + String(describing: b!) + " | " + String(describing: c!) + " MPH")
                        }
                        
                        if key == "fb_SPD" {
                            let d = nestedDictionary["fb_SPD"] as! Double
                            let e = nestedDictionary["fb_timName"] as! String!
                            let f = nestedDictionary["fb_RND"] as! Double!
                            
                            speed_string_array.append(String(describing: d) + " MPH  " + String(describing: e!) + " | " + String(describing: f!) + " %MAX")
                        }
                    }
                }
            }
            //at the end
            score_string_array.sort { $0 > $1 }
            speed_string_array.sort { $0.compare($1, options: .numeric) == .orderedDescending }
            
            let stringOfWords = score_string_array[0]
            let stringOfWordsArray = stringOfWords.components(separatedBy: " ")
            //                print(stringOfWordsArray[0])
            //                print(stringOfWordsArray[3])
            //Rounds.roundLeaderName = stringOfWordsArray[0]
            //Rounds.roundLeaderScore = stringOfWordsArray[3]
            Leaderboard.scoreLeaderScore = stringOfWordsArray[0]
            Leaderboard.scoreLeaderName = stringOfWordsArray[3]
            
            let stringOfWords2 = speed_string_array[0]
            let stringOfWordsArray2 = stringOfWords2.components(separatedBy: " ")
            //                print(stringOfWordsArray2[0])
            //                print(stringOfWordsArray2[3])
            Leaderboard.speedLeaderScore = stringOfWordsArray2[0]
            Leaderboard.speedLeaderName = stringOfWordsArray2[3]
            
            //self.alert(message: "\(Leaderboard.scoreLeaderName) , \(Leaderboard.scoreLeaderScore) , \(Leaderboard.speedLeaderName) , \(Leaderboard.speedLeaderScore)  ", title: "Leaders")
            
            Leaderboard.roundLeadersString = "\(Leaderboard.scoreLeaderName),\(Leaderboard.scoreLeaderScore),\(Leaderboard.speedLeaderName),\(Leaderboard.speedLeaderScore)"
            print(Leaderboard.roundLeadersString)
            
            
        }
    }).resume()
}


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


