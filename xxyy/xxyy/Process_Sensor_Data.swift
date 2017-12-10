//
//  Process_Sensor_Data.swift
//  xxyy
//
//  Created by aaronep on 11/23/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation




//var raw_wheel_revs: Double = 0
//var raw_wheel_time: Double = 0
//
//var raw_wheel_revs_for_avg: Double = 0  //used for ble avg. speed for session
//var raw_wheel_time_for_avg: Double = 0  //moving avg. speed (not actual avg. speed)
//var raw_distance_for_avg: Double?
//var raw_speed_for_avg: Double?
//
//var arrWheelRevs = [Double]()
//var arrWheelTimes = [Double]()
//var arrSpeed: Double = 0
//var arrDistanceTotal: Double = 0
//var arrDurationTotal: Double = 0
//var arrDurationTotalString: String = "00:00:00"
//var arrAverageMovingSpeed: Double = 0
//var numofvaluesforarraycalc: Int = 5
//
//
//func calc_based_on_array_values() {
//
//    let lastxwheelrevs = arrWheelRevs.suffix(numofvaluesforarraycalc)
//    let sum_lastxwheelrevs = lastxwheelrevs.reduce(0, +)
//
//    let lastxwheeltimes = arrWheelTimes.suffix(numofvaluesforarraycalc)
//    let sum_lastxwheeltimes = lastxwheeltimes.reduce(0, +)
//
//    let lastxdistance = sum_lastxwheelrevs * (wheelCircumference / 1000) * 0.000621371
//    let lastxtime = sum_lastxwheeltimes / 1024
//    let lastxmph = lastxdistance / (lastxtime / 60 / 60)
//
//
//    if lastxmph.isNaN == false || lastxmph.isInfinite == false {
//        if sum_lastxwheelrevs > 0 {  //only pass a zero if all 0's in the arr
//            arrSpeed = lastxmph
//        } else {
//            arrSpeed = 0.0
//        }
//    }
//
//
//    let totaldistance = arrWheelRevs.reduce(0, +) * (wheelCircumference / 1000) * 0.000621371
//    if totaldistance.isNaN == false || totaldistance.isInfinite == false {
//        //print("totaldistance:  \(totaldistance)")
//        arrDistanceTotal = totaldistance
//    }
//    let totalduration = (arrWheelTimes.reduce(0, +) / 1024)
//    //print("Total Duration \(totalduration)")
//    if totalduration.isNaN == false || totalduration.isInfinite == false {
//        arrDurationTotal = totalduration
//        arrDurationTotalString = createTimeString(seconds: Int(arrDurationTotal))
//        //print("arrDurationString \(arrDurationTotalString)")
//    }
//
//    let avgmovingspeed = totaldistance / ((arrWheelTimes.reduce(0, +) / 1024) / 60 / 60)
//    if avgmovingspeed.isNaN == false {
//        //print("avg moving speed:  \(avgmovingspeed)")
//        arrAverageMovingSpeed = avgmovingspeed
//    }
//
//}


//func get_quick_avg_speed() {
//    let distance = quick_avg.wheel_rev_count * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
//
//    quick_avg.speed = distance / ((quick_avg.wheel_event_time / 1024) / 60 / 60)
//
//    if quick_avg.speed.isNaN == true {
//        quick_avg.speed = 0
//    }
//
//    quick_avg.wheel_event_time = 0
//    quick_avg.wheel_rev_count = 0
//
//}

//func get_quick_avg_cadence() {
//    quick_avg.cadence = quick_avg.crank_rev_count / (quick_avg.crank_event_time / 1024) * 60
//    if quick_avg.cadence.isNaN == true || quick_avg.cadence.isInfinite == true {
//        quick_avg.cadence = 0
//    }
//
//    quick_avg.crank_rev_count = 0
//    quick_avg.crank_event_time = 0
//}

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

    //rt.rt_cadence = rtc
    
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
        
        //for velo
        if b < 950 {
            wheelRevolution = oldWheelRevolution
        } else {
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
                }
                
                rt_WheelRevs += a
                rt_WheelTime += b
                rt.total_moving_time_seconds += (b / 1024)
                rt.total_moving_time_string = createTimeString(seconds: Int(rt.total_moving_time_seconds))
                totalWheelRevs += a
                arr_srs.append(single_read_speed)
            }
        }
    }
    oldWheelRevolution = wheelRevolution
    oldWheelEventTime = wheelEventTime
}
            
//        } else {
//            //logic here to not change old wheel unless time val is higher
//            single_read_speed = 0
//        }

//        if b <= 2000 {
//            rt_WheelRevs += a
//            rt_WheelTime += b
//            rt.total_moving_time_seconds += (b / 1024)
//            rt.total_moving_time_string = createTimeString(seconds: Int(rt.total_moving_time_seconds))
//            totalWheelRevs += a
//        }
        
//        if a == 0 {
//            wheelRevolution = 0
//        }
//    }
//
//    oldWheelRevolution = wheelRevolution
//    oldWheelEventTime = wheelEventTime
//}

var rt_crank_revs: Double = 0
var rt_crank_time: Double = 0
var oldCrankRevolution: Double = 0
var oldCrankEventTime: Double = 0

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    var crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    let crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
    if oldCrankRevolution > 0 {  //test for first time reading
        
        //test velo speed fix
        var a = crankRevolution - oldCrankRevolution
        var b = (crankEventTime - oldCrankEventTime)
        
        if a < 0 {a = (crankRevolution + 255) - oldCrankRevolution}
        if b < 0 {b = (crankEventTime + 65025) - oldCrankEventTime}
        
        //single read
        let crankTimeSeconds = Double(b) / 1024
        if crankTimeSeconds > 0 {
            single_read_cad = Double(a) / (crankTimeSeconds / 60)
        } else {
            single_read_cad = 0
        }
        arr_src.append(single_read_cad)
        //print("cad:  \(single_read_cad), \(rt.rt_cadence), \(single_read_cad - rt.rt_cadence)")
        //end single read
        
        if a < 5 { //filter out bad readings
            rt_crank_revs += a
            rt_crank_time += b  //still in 1/1024 of a sec
            
            totalCrankRevs += a
        }
        if b <= 3000 {crankRevolution = 0}
    }
    oldCrankRevolution = crankRevolution
    oldCrankEventTime = crankEventTime
}

