//
//  Process_Sensor_Data.swift
//  iVirtualCrit
//
//  Created by aaronep on 1/29/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

var inRoundHR = [Int]()
var inRoundCadence = [Int]()
var inRoundBtDistance: Double = 0
var btDistanceForMileCalc:Double = 0
var btAverageSpeed: Double = 0


var roundHR: Double = 0
var roundSpeed: Double = 0
var roundCadence: Double = 0

var currentHR: Double = 0
var currentCadence: Double = 0
var currentSpeed: Double = 0
var currentScore: Double = 0


import Foundation



var total_distance: Double = 0
var speed: String = "0"
var cadence: String = "0"
var wheelCircumference: Double = 2105
var total_moving_time_seconds: Double = 0
var total_moving_time_string: String = ""


var totalWheelRevs: Double = 0
var totalCrankRevs: Double = 0


var oldWheelRevolution: Double = 999999
var oldWheelEventTime: Double = 0
var rt_WheelRevs: Double = 0
var rt_WheelTime: Double = 0
var veloSpeedCounter = 0;

func processWheelData(withData data :Data) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    let wheelRevolution = Double(UInt32(CFSwapInt32LittleToHost(UInt32(value[1]))))
    let wheelEventTime = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))
    
    if (oldWheelRevolution == 999999) {
        oldWheelRevolution = wheelRevolution;
        oldWheelEventTime = wheelEventTime;
        print("First Read SPD")
    } else {
        var a: Double = 0;var b: Double = 0;
        a = wheelRevolution - oldWheelRevolution
        b = wheelEventTime - oldWheelEventTime
        if a < 0 {a = (wheelRevolution + 255) - oldWheelRevolution}
        if b < 0 {b = (wheelEventTime + 65535) - oldWheelEventTime}
        
        if (a == 0 && b > 1500) {  //no wheel inc, but time did inc, this is 0
            //print("no wheel inc, but time did inc, this is 0")
            oldWheelRevolution = wheelRevolution
            oldWheelEventTime = wheelEventTime
            speed = stringer(dbl: 0, len: 1)
            rt_WheelTime += b
            return
        }
//        if (b < 500 && a == 0) { //ignore velo quick reads
//            //print("velo check only (b < 500 && a == 0):  \(a), \(b)")
//            veloSpeedCounter += 1
//            if veloSpeedCounter > 2 {
//                veloSpeedCounter = 0
//                //print("spd, 0's in a row, set rt_spd to 0")
//                speed = stringer(dbl: 0, len: 1)
//                NotificationCenter.default.post(name: NSNotification.Name("bleUpdate"), object: nil, userInfo: ["spd": speed])
//            }
//            return;
//        }
        if (a > 15 || b > 10000) {  //catch after breaks
            //print("After a break, too much time or too much wheel revs (a > 15 || b > 10000):  \(a), \(b)")
            oldWheelRevolution = wheelRevolution
            oldWheelEventTime = wheelEventTime
            veloSpeedCounter = 0
            return
        }
        
        
        let wheelTimeSeconds = Double(Double(b) / Double(1024))
        let wheelCircumferenceCM = Double(wheelCircumference / 10)
        let wheelRPM = Double(a) / Double(wheelTimeSeconds / 60)
        let cmPerMi = Double(0.00001 * 0.621371)
        let minsPerHour = 60.0
//        rt.rt_speed =  Double(wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour)
        speed =  stringer(dbl: Double(wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour), len: 1)
        
        
        rt_WheelRevs += a
        rt_WheelTime += b
        totalWheelRevs += a
        total_distance = totalWheelRevs * (wheelCircumference / 1000) * 0.000621371
        btDistanceForMileCalc = total_distance
        
        inRoundBtDistance += (a * (wheelCircumference / Double(1000.0)) * 0.000621371)
        
        
        if (Double(wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour)) > 0.0  {
            total_moving_time_seconds += (Double(b) / Double(1024))
            total_moving_time_string = createTimeString(seconds: Int(total_moving_time_seconds))
        }
        
        btAverageSpeed = total_distance / (total_moving_time_seconds / 60.0 / 60.0)
        
        NotificationCenter.default.post(name: NSNotification.Name("bleUpdate"), object: nil, userInfo: ["spd": speed, "dist": stringer(dbl: total_distance, len: 2), "mov": total_moving_time_string, "mov_avg": stringer(dbl: btAverageSpeed, len: 1) ])
        
        oldWheelRevolution = wheelRevolution
        oldWheelEventTime = wheelEventTime
        veloSpeedCounter = 0
    }
}



var rt_crank_revs: Double = 0
var rt_crank_time: Double = 0
var oldCrankRevolution: Double = 999999
var oldCrankEventTime: Double = 0
var veloCadCounter = 0;

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    let crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    let crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
    //test for first time reading
    if (oldCrankRevolution == 999999) {
        oldCrankRevolution = crankRevolution
        oldCrankEventTime = crankEventTime
        print("First Read CAD, \(oldCrankRevolution)")
    } else {
        var a: Double = 0;var b: Double = 0;
        a = crankRevolution - oldCrankRevolution
        b = (crankEventTime - oldCrankEventTime)
        
        if a < 0 {a = (crankRevolution + 255) - oldCrankRevolution}
        if b < 0 {b = (crankEventTime + 65535) - oldCrankEventTime}
        
        if (a == 0 && b > 1500) {  //no crank increase but time did, this is a zero cadence
            //print("(a == 0 && b > 1500), this should be a zero:  \(a), \(b)")
            //rt.rt_cadence = Double(0)
            rt_crank_time += b  //still in 1/1024 of a sec
            oldCrankRevolution = crankRevolution
            oldCrankEventTime = crankEventTime
            return
        }
//        if (b < 500 && a == 0) {  //ignore velo quick reads
//            //print("velo check only (b < 500 && a == 0):  \(a), \(b)")
//            veloCadCounter += 1
//            if veloCadCounter > 2 {
//                veloCadCounter = 0
//                //print("0's in a row, rt.rt_cad is set to 0")
//                //rt.rt_cadence = Double(0)
//                cadence = stringer(dbl: 0, len: 0)
//                NotificationCenter.default.post(name: NSNotification.Name("bleUpdate"), object: nil, userInfo: ["cad": cadence])
//            }
//            return
//        }
        if (a > 15 || b > 10000) {  //catch after breaks
            //print("After a break, too much time or too much crank revs (a > 15 || b > 10000):  \(a), \(b)")
            oldCrankRevolution = crankRevolution
            oldCrankEventTime = crankEventTime
            veloCadCounter = 0
            return
        }
        
        let crankTimeSeconds = Double(b) / Double(1024)
        //rt.rt_cadence = Double(a) / Double(crankTimeSeconds / Double(60))
        
        currentCadence = Double(a) / Double(crankTimeSeconds / Double(60))
        //string for cadence
        cadence = stringer(dbl: currentCadence, len: 0)
        NotificationCenter.default.post(name: NSNotification.Name("bleUpdate"), object: nil, userInfo: ["cad": cadence])
        
        inRoundCadence.append(Int(Double(a) / Double(crankTimeSeconds / Double(60))))
        roundCadence = inRoundCadence.average
        
        rt_crank_revs += a
        rt_crank_time += b  //still in 1/1024 of a sec
        totalCrankRevs += a
        
        //NotificationCenter.default.post(name: Notification.Name("cadence"), object: nil)
        //print("rt.rt_cadence - notify, revs, time:  \(rt.rt_cadence), \(a) \(b)");
        
        oldCrankRevolution = crankRevolution
        oldCrankEventTime = crankEventTime
        veloCadCounter = 0
    }
}
