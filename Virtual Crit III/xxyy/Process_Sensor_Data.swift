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
            rt.rt_speed = 0
            rt_WheelTime += b
            return
        }
        if (b < 500 && a == 0) { //ignore velo quick reads
            print("velo check only (b < 500 && a == 0):  \(a), \(b)")
            veloSpeedCounter += 1
            if veloSpeedCounter > 2 {
                veloSpeedCounter = 0
                //print("spd, 0's in a row, set rt_spd to 0")
                rt.rt_speed = Double(0)
            }
            return;
        }
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
        rt.rt_speed =  Double(wheelRPM * wheelCircumferenceCM * cmPerMi * minsPerHour)

        rt_WheelRevs += a
        rt_WheelTime += b
        totalWheelRevs += a
        rt.total_distance = totalWheelRevs * (wheelCircumference / 1000) * 0.000621371

        if rt.rt_speed > 0 {
            rt.total_moving_time_seconds += (Double(b) / Double(1024))
            rt.total_moving_time_string = createTimeString(seconds: Int(rt.total_moving_time_seconds))
        }
        
        NotificationCenter.default.post(name: Notification.Name("speed"), object: nil)
        //print("rt.rt_speed, notify:  \(rt.rt_speed)")
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
                rt.rt_cadence = Double(0)
                rt_crank_time += b  //still in 1/1024 of a sec
                oldCrankRevolution = crankRevolution
                oldCrankEventTime = crankEventTime
                return
            }
            if (b < 500 && a == 0) {  //ignore velo quick reads
                //print("velo check only (b < 500 && a == 0):  \(a), \(b)")
                veloCadCounter += 1
                if veloCadCounter > 2 {
                    veloCadCounter = 0
                    //print("0's in a row, rt.rt_cad is set to 0")
                    rt.rt_cadence = Double(0)
                }
                return
            }
            if (a > 15 || b > 10000) {  //catch after breaks
                //print("After a break, too much time or too much crank revs (a > 15 || b > 10000):  \(a), \(b)")
                oldCrankRevolution = crankRevolution
                oldCrankEventTime = crankEventTime
                veloCadCounter = 0
                return
            }
            
            let crankTimeSeconds = Double(b) / Double(1024)
            rt.rt_cadence = Double(a) / Double(crankTimeSeconds / Double(60))
            rt_crank_revs += a
            rt_crank_time += b  //still in 1/1024 of a sec
            totalCrankRevs += a
            
            NotificationCenter.default.post(name: Notification.Name("cadence"), object: nil)
            //print("rt.rt_cadence - notify, revs, time:  \(rt.rt_cadence), \(a) \(b)");
            
            oldCrankRevolution = crankRevolution
            oldCrankEventTime = crankEventTime
            veloCadCounter = 0
        }
    }

