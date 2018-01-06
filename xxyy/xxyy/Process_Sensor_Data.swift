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


var oldWheelRevolution: Double = 0
var oldWheelEventTime: Double = 0
var rt_WheelRevs: Double = 0
var rt_WheelTime: Double = 0



func processWheelData(withData data :Data) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    var wheelRevolution = Double(UInt32(CFSwapInt32LittleToHost(UInt32(value[1]))))
    var wheelEventTime = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))

    if (oldWheelRevolution == 0) {
        oldWheelRevolution = wheelRevolution;
        oldWheelEventTime = wheelEventTime;
        print("First Read")
    } else {  //test for NOT first time reading
        
        var a: Double = 0;var b: Double = 0;
        a = wheelRevolution - oldWheelRevolution
        b = wheelEventTime - oldWheelEventTime
        if a < 0 {a = (wheelRevolution + 255) - oldWheelRevolution}
        if b < 0 {b = (wheelEventTime + 65025) - oldWheelEventTime}

        if (a == 0 || a > 10) {
            wheelRevolution = oldWheelRevolution;
            wheelEventTime = oldWheelEventTime;
            rt.rt_speed = 0
            return
        }
        if (b < 750 && b > 0) {
            wheelRevolution = oldWheelRevolution;
            wheelEventTime = oldWheelEventTime;
            //print("return, b < 750 && b > 0")
            return;
        }
        
        //single read
        let wheelTimeSeconds = Double(b) / Double(1024)
        let wheelCircumferenceCM = Double(wheelCircumference / 10)
        let wheelRPM = Double(a) / (wheelTimeSeconds / 60)
        let cmPerMi = Double(0.00001 * 0.621371)
        let minsPerHour = 60.0
        rt.rt_speed =  wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour
        
    
    
        //srseconds += wheelTimeSeconds
        rt_WheelRevs += a
        rt_WheelTime += b
        totalWheelRevs += a
        rt.total_distance = totalWheelRevs * (wheelCircumference / 1000) * 0.000621371

        if rt.rt_speed > 0 {
            rt.total_moving_time_seconds += (Double(b) / Double(1024))
            rt.total_moving_time_string = createTimeString(seconds: Int(rt.total_moving_time_seconds))
        }
        
        NotificationCenter.default.post(name: Notification.Name("speed"), object: nil)
        
        oldWheelRevolution = wheelRevolution
        oldWheelEventTime = wheelEventTime
    }

}

var rt_crank_revs: Double = 0
var rt_crank_time: Double = 0
var oldCrankRevolution: Double = 0
var oldCrankEventTime: Double = 0

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    var crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    var crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
    //test for first time reading
        if (oldCrankRevolution == 0) {
            oldCrankRevolution = crankRevolution
            oldCrankEventTime = crankEventTime
            print("First Read CAD")

        } else {
                var a: Double = 0;var b: Double = 0;
                a = crankRevolution - oldCrankRevolution
                b = (crankEventTime - oldCrankEventTime)
                
                if a < 0 {a = (crankRevolution + 255) - oldCrankRevolution}
                if b < 0 {b = (crankEventTime + 65025) - oldCrankEventTime}
                
                if (a == 0 || a > 5) {
                    crankRevolution = oldCrankRevolution
                    crankEventTime = oldCrankEventTime
                    //print("return, a == 0, should display 0 CAD")
                    rt.rt_cadence = 0
                    return
                }
            if (b < 750 && b > 0) {
                crankRevolution = oldCrankRevolution
                crankEventTime = oldCrankEventTime
                return
            }
            let crankTimeSeconds = Double(b) / Double(1024)
            rt.rt_cadence = Double(a) / (crankTimeSeconds / 60)
            rt_crank_revs += a
            rt_crank_time += b  //still in 1/1024 of a sec
            totalCrankRevs += a
            
            NotificationCenter.default.post(name: Notification.Name("cadence"), object: nil)
            
            oldCrankRevolution = crankRevolution
            oldCrankEventTime = crankEventTime
            }
    }

