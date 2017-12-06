//
//  Model.swift
//  xxyy
//
//  Created by aaronep on 11/23/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation

func createTimeString(seconds: Int)->String
{
    let h:Int = seconds / 3600
    let m:Int = (seconds/60) % 60
    let s:Int = seconds % 60
    let a = String(format: "%u:%02u:%02u", h,m,s)
    return a
}

func stringer0(myIn: Double) -> String {
    if myIn.isInfinite == true {
        return "0"
    } else {
        let myOut = String(format:"%.0f", myIn)
        return myOut
    }

}

func stringer1(myIn: Double) -> String {
    if myIn.isInfinite == true {
        return "0"
    } else {
        let myOut = String(format:"%.1f", myIn)
        return myOut
    }
}

func stringer2(myIn: Double) -> String {
    if myIn.isInfinite == true {
        return "0"
    } else {
        let myOut = String(format:"%.2f", myIn)
        return myOut
    }
}


var wheelCircumference: Double = 2105
var seconds_for_quick_avg: Int = 2

struct rt {
    static var rt_speed: Double = 0
    static var rt_cadence: Double = 0
    static var rt_hr: Double = 0
    static var total_distance: Double = 0
    static var total_time: Double = 0
    static var string_elapsed_time: String = "00:00:00"
    static var int_elapsed_time: Int = 0
}

struct quick_avg {
    static var speed: Double = 0
    static var cadence: Double = 0
    static var wheel_rev_count: Double = 0
    static var wheel_event_time: Double = 0
    static var crank_rev_count: Double = 0
    static var crank_event_time: Double = 0
    static var lap_time: Double = 0 //seconds
    
}
