//
//  Process_Sensor_Data.swift
//  xxyy
//
//  Created by aaronep on 11/23/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation

var totalWheelRevs: Double = 0
var totalCrankRevs: Double = 0

func get_rt_speed_and_distance() -> Double {
    let distance = rt_WheelRevs * (wheelCircumference / 1000) * 0.000621371
    let time = Double(rt_WheelTime) / Double(1024)
    let wheelCircumferenceCM = wheelCircumference / 10
    //let speed = distance / (time / 60 / 60)
    
//    let wheelTimeSeconds = Double(wheelTimeDelta) / Double(wheelTimeResolution)
//    if wheelTimeSeconds > 0 {
//        let wheelRPM = Double(wheelRevsDelta) / (wheelTimeSeconds / 60)
//        let cmPerKm = 0.00001
//        let minsPerHour = 60.0
//        return wheelRPM * wheelCircumferenceCM * cmPerKm * minsPerHour
    if time > 0 {
        let wheelRPM = Double(rt_WheelRevs) / (time / 60)
        let cmPerMile = 0.621371 * 0.00001
        let minsPerHour = 60.0
        let speed =  wheelRPM * wheelCircumferenceCM * cmPerMile * minsPerHour
            
        rt.total_distance += distance
        rt.rt_speed = speed
    } else {
        rt.rt_speed = 0
    }
    
    if rtTimer_Interval == 1.0 {
        rt.rt_speed = single_read_speed
    }

    rt_WheelRevs = 0
    rt_WheelTime = 0
    
    return rt.rt_speed
}

func get_rt_cadence() -> Double {
    //let rtc = rt_crank_revs / (rt_crank_time / 1024) * 60
    
    let crankTimeSeconds = Double(rt_crank_time) / Double(1024)
    if crankTimeSeconds > 0 {
        rt.rt_cadence =  Double(rt_crank_revs) / (crankTimeSeconds / 60)
    } else {
        rt.rt_cadence = 0
    }

    if rtTimer_Interval == 1.0 {
        rt.rt_cadence = single_read_cad
    }
    rt_crank_revs = 0
    rt_crank_time = 0
    
    return rt.rt_cadence
}

var oldWheelRevolution: Double = 0
var oldWheelEventTime: Double = 0
var rt_WheelRevs: Double = 0
var rt_WheelTime: Double = 0

var single_read_speed: Double = 0
var single_read_cad: Double = 0
var arr_srs = [Double]()
var arr_src = [Double]()
var srseconds: Double = 0

func processWheelData(withData data :Data) {
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    var wheelRevolution = Double(UInt32(CFSwapInt32LittleToHost(UInt32(value[1]))))
    let wheelEventTime = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))

    if oldWheelRevolution > 0 {  //test for NOT first time reading
        
        var a: Double = 0;var b: Double = 0;
        
        a = wheelRevolution - oldWheelRevolution
        b = wheelEventTime - oldWheelEventTime
        
        if a < 0 {a = (wheelRevolution + 255) - oldWheelRevolution}
        if b < 0 {b = (wheelEventTime + 65025) - oldWheelEventTime}
        

            //single read
            let wheelTimeSeconds = Double(b) / Double(1024)
            if wheelTimeSeconds > 0 {
                let wheelCircumferenceCM = Double(wheelCircumference / 10)
                let wheelRPM = Double(a) / (wheelTimeSeconds / 60)
                let cmPerMi = Double(0.00001 * 0.621371)
                let minsPerHour = 60.0
                single_read_speed =  wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour
                
                
                
                if single_read_speed > 0 {
                    srseconds += wheelTimeSeconds
                    rt_WheelRevs += a
                    rt_WheelTime += b
                    rt.total_moving_time_seconds += (Double(b) / Double(1024))
                    rt.total_moving_time_string = createTimeString(seconds: Int(rt.total_moving_time_seconds))
                    totalWheelRevs += a
                }
            }  else {
                single_read_speed = 0
            }
        print("srs:  \(single_read_speed)")
        
    }
    oldWheelRevolution = wheelRevolution
    oldWheelEventTime = wheelEventTime
}

var rt_crank_revs: Double = 0
var rt_crank_time: Double = 0
var oldCrankRevolution: Double = 0
var oldCrankEventTime: Double = 0

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    var crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    let crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
    if oldCrankRevolution > 0 {  //test for first time reading
        
        
        var a = crankRevolution - oldCrankRevolution
        var b = (crankEventTime - oldCrankEventTime)
        
        if a < 0 {a = (crankRevolution + 255) - oldCrankRevolution}
        if b < 0 {b = (crankEventTime + 65025) - oldCrankEventTime}
        
            //single read
            let crankTimeSeconds = Double(b) / 1024
            if crankTimeSeconds > 0 {
                single_read_cad = Double(a) / (crankTimeSeconds / 60)
                
                
                
                
                if a < 10 { //filter out bad readings
                    rt_crank_revs += a
                    rt_crank_time += b  //still in 1/1024 of a sec
                    totalCrankRevs += a
                }
            } else {
                single_read_cad = 0
            }
        
        print("src:  \(single_read_cad)")
    }
    oldCrankRevolution = crankRevolution
    oldCrankEventTime = crankEventTime
}

