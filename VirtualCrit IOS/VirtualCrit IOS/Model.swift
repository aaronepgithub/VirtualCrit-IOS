//
//  Model.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation

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

}

struct AllRounds {

    static var arrHR = [Double]()
    static var arrSPD = [Double]()
    static var arrCAD = [Double]()
    

}


