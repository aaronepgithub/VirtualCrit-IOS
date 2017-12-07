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

func get_rt_speed_and_distance() -> Double {
    let distance = rt_WheelRevs * (wheelCircumference / 1000) * 0.000621371
    let time = rt_WheelTime / 1024
    let speed = distance / (time / 60 / 60)
    
    rt.total_distance += distance
    rt.rt_speed = speed
    
    rt_WheelRevs = 0
    rt_WheelTime = 0
    
    return rt.rt_speed
}

func get_rt_cadence() -> Double {
    let rtc = rt_crank_revs / (rt_crank_time / 1024) * 60
    if rtc.isNaN == true || rtc.isInfinite == true {
        rt.rt_cadence = 0
    } else {
        rt.rt_cadence = rtc
    }
    
    rt_crank_revs = 0
    rt_crank_time = 0
    
    return rt.rt_cadence
}

var oldWheelRevolution: Double = 0
var oldWheelEventTime: Double = 0
var rt_WheelRevs: Double = 0
var rt_WheelTime: Double = 0

func processWheelData(withData data :Data) {
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    var wheelRevolution = Double(UInt32(CFSwapInt32LittleToHost(UInt32(value[1]))))
    let wheelEventTime = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))

    var a: Double = 0;var b: Double = 0;
    
    if oldWheelRevolution > 0 {  //test for NOT first time reading
        a = wheelRevolution - oldWheelRevolution
        b = wheelEventTime - oldWheelEventTime
        
        if a < 0 {a = (wheelRevolution + 255) - oldWheelRevolution}
        if b < 0 {b = (wheelEventTime + 65535) - oldWheelEventTime}
        
        if b <= 3000 {
            print(a,b)
            rt_WheelRevs += a
            rt_WheelTime += b
            rt.total_moving_time_seconds += rt_WheelTime / 1024
            rt.total_moving_time_string = createTimeString(seconds: Int(rt.total_moving_time_seconds))
        }
        
        if a == 0 {
            wheelRevolution = 0
        }
        //used to ensure moving time is accurate
    }
    
    oldWheelRevolution = Double(wheelRevolution)
    oldWheelEventTime = Double(wheelEventTime)
}

var rt_crank_revs: Double = 0
var rt_crank_time: Double = 0
var oldCrankRevolution: Double = 0
var oldCrankEventTime: Double = 0

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    let crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    let crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
    if oldCrankRevolution > 0 {  //test for first time reading
        
        var a = crankRevolution - oldCrankRevolution
        var b = (crankEventTime - oldCrankEventTime)
        
        if a < 0 {
            a = (crankRevolution + 255) - oldCrankRevolution
        }
        
        if b < 0 {
            b = (crankEventTime + 65535) - oldCrankEventTime
        }
        
        if a < 5 { //filter out bad readings
            rt_crank_revs += a
            rt_crank_time += b  //still in 1/1024 of a sec
//            let rtc = a / (b / 1024) * 60
//            if rtc.isNaN == true || rtc.isInfinite == true {
//                //print(0)
//                rt.rt_cadence = 0
//            } else {
//                //print(rtc)
//                rt.rt_cadence = rtc
//            }
        }
    }
    oldCrankRevolution = crankRevolution
    oldCrankEventTime = crankEventTime
}
        
        
//        if b < 4000 {
//            arrWheelRevs.append(a)
//            arrWheelTimes.append(b)
//            //attempt accurate moving time
//        }
        
        //print(a,b)

        
//        raw_wheel_revs += a
//        raw_wheel_revs_for_avg += a
        
//        quick_avg.wheel_rev_count += a
//        quick_avg.wheel_event_time += b
        //add to arr every sec or .5 sec, 0 if nothing
        //append until x entries, after x, remove first
        //each sec, calc speed
        
//        let quickdistance = quick_avg.wheel_rev_count * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
//        let quickspeed = quickdistance / ((quick_avg.wheel_event_time / 1024) / 60 / 60) //miles per hour - avg moving speed
//        print(stringer1(myIn: quickspeed))

        
//        quick_avg.lap_time += c   //converted to seconds
        
//        if a > 0 {
//            raw_wheel_time += b // still in 1/1024 second - moving speed
//            raw_wheel_time_for_avg += b
//        }


        //let distance_raw = raw_wheel_revs * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
        //let speed_raw = distance_raw / ((raw_wheel_time / 1024) / 60 / 60) //miles per hour - avg moving speed

        //raw_distance_for_avg = raw_wheel_revs_for_avg * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
        
//        if let rd = raw_distance_for_avg {
//            if rd.isNaN == false {
//                    raw_speed_for_avg = rd / ((raw_wheel_time_for_avg / 1024) / 60 / 60) //miles per hour - avg moving speed
//            }
//        }

        //rt.total_distance = distance_raw
        
//        let rtDistance = a * (wheelCircumference / 1000) * 0.000621371
//        let rtSpeed = rtDistance / ((b / 1024) / 60 / 60)
        
//        if rtSpeed.isNaN == true {
//            //print(0)
//            rt.rt_speed = 0
//        } else {
//            //print(rtSpeed)
//            rt.rt_speed = rtSpeed
//        }
//        rt.total_time = total_ble_seconds
        


//var raw_crank_revs: Double = 0
//var raw_crank_time: Double = 0
//var oldCrankRevolution: Double = 0
//var oldCrankEventTime: Double = 0
//
//func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
//
//    var crankEventTime      : Double = 0
//    var crankRevolution     : Double = 0
//
//    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
//
//    crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
//    crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
//
//    if oldCrankRevolution > 0 {  //test for first time reading
//
//        var a = crankRevolution - oldCrankRevolution
//        var b = (crankEventTime - oldCrankEventTime)
//
//        if a < 0 {
//            a = (crankRevolution + 255) - oldCrankRevolution
//        }
//
//        if b < 0 {
//            b = (crankEventTime + 65535) - oldCrankEventTime
//        }
//
//
//        if a < 5 { //filter out bad readings
//            raw_crank_revs += a
//            raw_crank_time += b  //still in 1/1024 of a sec
//
//
//
//            let rtc = a / (b / 1024) * 60
//            if rtc.isNaN {
//                //print(0)
//                rt.rt_cadence = 0
//            } else {
//                //print(rtc)
//                rt.rt_cadence = rtc
//            }
//
//            //quick_avg.crank_rev_count += a
//            //quick_avg.crank_event_time += b
//
//            //NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
//
//        }
//    }
//    oldCrankRevolution = crankRevolution
//    oldCrankEventTime = crankEventTime
//}

