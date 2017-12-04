//
//  Process_Sensor_Data.swift
//  xxyy
//
//  Created by aaronep on 11/23/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation

var oldWheelRevolution: Double?
var oldWheelEventTime: Double = 0
var total_ble_seconds: Double = 0
var raw_wheel_revs: Double = 0
var raw_wheel_time: Double = 0





var raw_wheel_revs_for_avg: Double = 0  //used for ble avg. speed for session
var raw_wheel_time_for_avg: Double = 0  //moving avg. speed (not actual avg. speed)
var raw_distance_for_avg: Double?
var raw_speed_for_avg: Double?

var arrWheelRevs = [Double]()
var arrWheelTimes = [Double]()
var arrSpeed: Double = 0
var arrDistanceTotal: Double = 0
var arrDurationTotal: Double = 0
var arrDurationTotalString: String = "00:00:00"
var arrAverageMovingSpeed: Double = 0


func calc_based_on_array_values() {
    
    let last3wheelrevs = arrWheelRevs.suffix(3)
    let sum_last3wheelrevs = last3wheelrevs.reduce(0, +)
    
    let last3wheeltimes = arrWheelTimes.suffix(3)
    let sum_last3wheeltimes = last3wheeltimes.reduce(0, +)
    //print(sum_last3wheelrevs, sum_last3wheeltimes)
    
    let last3distance = sum_last3wheelrevs * (wheelCircumference / 1000) * 0.000621371
    let last3time = sum_last3wheeltimes / 1024
    let last3mph = last3distance / (last3time / 60 / 60)
    
    if last3mph.isNaN == false {
        //print("last3mph:  \(last3mph)")
        arrSpeed = last3mph
    } else {
        arrSpeed = 0
    }

    
    let totaldistance = arrWheelRevs.reduce(0, +) * (wheelCircumference / 1000) * 0.000621371
    if totaldistance.isNaN == false {
        //print("totaldistance:  \(totaldistance)")
        arrDistanceTotal = totaldistance
    }

    let totalduration = (arrWheelTimes.reduce(0, +) / 1024)
    print("Total Duration \(totalduration)")
    if totalduration.isNaN == false {
        arrDurationTotal = totalduration
        arrDurationTotalString = createTimeString(seconds: Int(arrDurationTotal))
        print("arrDurationString \(arrDurationTotalString)")
    }
    
    let avgmovingspeed = totaldistance / ((arrWheelTimes.reduce(0, +) / 1024) / 60 / 60)
    if avgmovingspeed.isNaN == false {
        //print("avg moving speed:  \(avgmovingspeed)")
        arrAverageMovingSpeed = avgmovingspeed
    }
    
}


func get_quick_avg_speed() {
    let distance = quick_avg.wheel_rev_count * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
    
    quick_avg.speed = distance / ((quick_avg.wheel_event_time / 1024) / 60 / 60)
    
    if quick_avg.speed.isNaN == true {
        quick_avg.speed = 0
    }

    quick_avg.wheel_event_time = 0
    quick_avg.wheel_rev_count = 0
}

func get_quick_avg_cadence() {
    quick_avg.cadence = quick_avg.crank_rev_count / (quick_avg.crank_event_time / 1024) * 60
    if quick_avg.cadence.isNaN == true {quick_avg.cadence = 0}

    quick_avg.crank_rev_count = 0
    quick_avg.crank_event_time = 0
}

func processWheelData(withData data :Data) {
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    let wheelRevolution = Double(UInt32(CFSwapInt32LittleToHost(UInt32(value[1]))))
    let wheelEventTime = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))
    
    var a: Double = 0;var b: Double = 0; var c: Double = 0;
    
    if oldWheelRevolution != nil {  //test for NOT first time reading
        a = wheelRevolution - oldWheelRevolution!
        b = wheelEventTime - oldWheelEventTime
        
        if a < 0 {
            a = (wheelRevolution + 255) - oldWheelRevolution!
        }
        
        if b < 0 {
            b = (wheelEventTime + 65535) - oldWheelEventTime
        }
        
        c = b/1024
        
        total_ble_seconds += c //actual time calculated by adding all wheel event times, even when wheel revs are 0
        raw_wheel_revs += a
        raw_wheel_revs_for_avg += a
        
        quick_avg.wheel_rev_count += a
        quick_avg.wheel_event_time += b
        quick_avg.lap_time += c   //converted to seconds
        
        if a > 0 {
            raw_wheel_time += b // still in 1/1024 second - moving speed
            raw_wheel_time_for_avg += b
        }


        let distance_raw = raw_wheel_revs * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
        //let speed_raw = distance_raw / ((raw_wheel_time / 1024) / 60 / 60) //miles per hour - avg moving speed

        raw_distance_for_avg = raw_wheel_revs_for_avg * (wheelCircumference / 1000) * 0.000621371  //raw total distance, in miles
        
        if let rd = raw_distance_for_avg {
            if rd.isNaN == false {
                    raw_speed_for_avg = rd / ((raw_wheel_time_for_avg / 1024) / 60 / 60) //miles per hour - avg moving speed
            }
        }

        rt.total_distance = distance_raw
        
        let rtDistance = a * (wheelCircumference / 1000) * 0.000621371
        let rtSpeed = rtDistance / ((b / 1024) / 60 / 60)
        
        if rtSpeed.isNaN == true {
            //print(0)
            rt.rt_speed = 0
        } else {
            //print(rtSpeed)
            rt.rt_speed = rtSpeed
        }
        rt.total_time = total_ble_seconds
        
        
        arrWheelRevs.append(a)
        arrWheelTimes.append(b)
        
//        if arrWheelRevs.count > 2 {
//            calc_based_on_array_values()
//        }

        
    }
    oldWheelRevolution = Double(wheelRevolution)
    oldWheelEventTime = Double(wheelEventTime)
}

var raw_crank_revs: Double = 0
var raw_crank_time: Double = 0
var oldCrankRevolution: Double = 0
var oldCrankEventTime: Double = 0

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) {
    
    var crankEventTime      : Double = 0
    var crankRevolution     : Double = 0
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
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
            raw_crank_revs += a
            raw_crank_time += b  //still in 1/1024 of a sec
            

            
            let rtc = a / (b / 1024) * 60
            if rtc.isNaN {
                //print(0)
                rt.rt_cadence = 0
            } else {
                //print(rtc)
                rt.rt_cadence = rtc
            }
            
            quick_avg.crank_rev_count += a
            quick_avg.crank_event_time += b
            
            //NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
            
        }
    }
    oldCrankRevolution = crankRevolution
    oldCrankEventTime = crankEventTime
}
