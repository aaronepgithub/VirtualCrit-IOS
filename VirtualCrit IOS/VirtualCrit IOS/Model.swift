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

    static var totalTravelDistance                 : Double?
    static var travelDistance                      : Double?
    static var wheelCircumference                  : Double?
}


struct Settings {
    static var riderName = "Tim"
    static var wheelSize_mm = "25"
    static var maxHeartrate = "185"
}


struct Totals {
    static var distanceTotal: Double = 0
    static var wheelEventTimeDiffTotal: Double = 0
    static var wheelRevolutionDiffTotal: Double = 0
    static var crankRevolutionDiffTotal: Double = 0
    static var crankEventTimeDiffTotal: Double = 0
    
    static var globalArrHRTotalAvg = [Int]()
    
    static var distance: Double = 0
    static var avg_speed: Double = 0
    static var avg_cad: Double = 0
    static var avg_hr: Double = 0
    
    static var startTime : NSDate?
    
    static var currentTime : NSDate?
    static var durationTotal : TimeInterval?
}

struct Rounds {
    static var roundStartTime : NSDate?
    static var roundCurrentTimeElapsed : TimeInterval?
    static var roundsComplete : Int = 0

}


