//
//  Decoder.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 4/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import Foundation

func decodeHRValue(withData data: Data) -> Int {
    let count = data.count / MemoryLayout<UInt8>.size
    var array = [UInt8](repeating: 0, count: count)
    (data as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
    var bpmValue : Int = 0;
    if ((array[0] & 0x01) == 0) {
        bpmValue = Int(array[1])
    } else {
        //Convert Endianess from Little to Big
        bpmValue = Int(UInt16(array[2] * 0xFF) + UInt16(array[1]))
    }
    
    
    Totals.globalArrHRTotalAvg.append(Int(bpmValue))
    return bpmValue
}

func decodeCSC(withData data : Data) -> Double {
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
//    var wheelRevDiff :Double = 0
//    var crankRevDiff :Double = 0
    var returnedCadence : Double = 0
    let flag = value[0]
    

    
    
    if flag & Device.WHEEL_REVOLUTION_FLAG == 1 {
//        wheelRevDiff = processWheelData(withData: data)
            processWheelData(withData: data)
        if flag & 0x02 == 2 {
            returnedCadence = processCrankData(withData: data, andCrankRevolutionIndex: 7)
        }
    } else {
        if flag & Device.CRANK_REVOLUTION_FLAG == 2 {
            returnedCadence = processCrankData(withData: data, andCrankRevolutionIndex: 1)
        }
    }
    
//    print("\n")
//    print(wheelRevDiff)
//    print(crankRevDiff)
//    print("\n")
    
    return returnedCadence
}


//func processWheelData(withData data :Data) -> Double {
func processWheelData(withData data :Data) {
    var wheelRevolution     :UInt8  = 0
    var wheelEventTime      :Double = 0
    var wheelRevolutionDiff :Double = 0
    var wheelEventTimeDiff  :Double = 0
    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    wheelRevolution = UInt8(Double(CFSwapInt32LittleToHost(UInt32(value[1]))))
    wheelEventTime  = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))
    
    // 1st
    if Device.oldWheelRevolution != 0 {
        wheelRevolutionDiff = Double(wheelRevolution) - Double(Device.oldWheelRevolution)
        //                print("wheelRevolutionDiff Orig:  \(wheelRevolutionDiff)")
        
        if wheelRevolutionDiff < 0 {
            wheelRevolutionDiff = wheelRevolutionDiff + 65535
            //                    print("wheelRevolutionDiff Upd:  \(wheelRevolutionDiff)")
        }
        
        if wheelRevolutionDiff >= 0 {
            
//            Device.travelDistance = Device.travelDistance! + ((wheelRevolutionDiff * Device.wheelCircumference!)/1000.0)  //segment
//            Device.totalTravelDistance = (Double(wheelRevolution) * Double(Device.wheelCircumference!)) / 1000.0  //total
            
            Totals.wheelRevolutionDiffTotal = Totals.wheelRevolutionDiffTotal + wheelRevolutionDiff
            Totals.distanceTotal = (Totals.wheelRevolutionDiffTotal * Device.wheelCircumference! / 1000 * 0.000621371) // convert meters to miles
            
        }
        
        
    }
    
    // 2nd
    if Device.oldWheelEventTime != 0 {
        wheelEventTimeDiff = wheelEventTime - Device.oldWheelEventTime
        
        if wheelEventTimeDiff < 0 {
            wheelEventTimeDiff = wheelEventTimeDiff + 255
        }
        if wheelEventTimeDiff > 0 {
            wheelEventTimeDiff = wheelEventTimeDiff / 1024.0  //convert to sec
            
            Totals.wheelEventTimeDiffTotal = Totals.wheelEventTimeDiffTotal + wheelEventTimeDiff
        }
        
    }
    
    // 3rd
    if wheelEventTimeDiff > 0 && wheelEventTimeDiff < 10 {
        
        if Totals.wheelRevolutionDiffTotal > 1 {
            Totals.avg_speed =  (Totals.wheelRevolutionDiffTotal * Device.wheelCircumference! / 1000 * 0.000621371) / (Totals.wheelEventTimeDiffTotal / 60 / 60)
            print("Avg Speed:  /(Totals.avg_speed)")

        }

    }
    
    // 4th
    if wheelRevolutionDiff == 0 && wheelEventTimeDiff == 0 {

    }

    
    Device.oldWheelRevolution = Double(wheelRevolution)
    Device.oldWheelEventTime = Double(wheelEventTime)

    //return wheelRevolutionDiff
}

var zeroTester          : Double = 0

func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) -> Double {
    
    var crankEventTime      : Double = 0
    var crankRevolutionDiff : Double = 0
    var crankEventTimeDiff  : Double = 0
    var crankRevolution     : Double = 0
    var travelCadence       : Double = 0

    
    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
    
    crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
    crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
    
    print(" \n Current Crank Rev:  \(crankRevolution)")
    print("Current Crank Time:  \(crankEventTime)")

    print("Old Crank Rev:  \(Device.oldCrankRevolution)")
    print("Old Crank Time:  \(Device.oldCrankEventTime) \n")

    
    if Device.oldCrankRevolution > 0 {  //test for first time reading
        if Device.oldCrankRevolution == crankRevolution && Device.oldCrankEventTime == crankEventTime { //test for 0 cadence
            print("Current Cadence is 0")
            travelCadence = 0
        } else {
            
            if Device.oldCrankRevolution > crankRevolution || Device.oldCrankEventTime > crankEventTime { //ignore readings when counter resets
                print("reset counter, ignore")
            } else {
                crankRevolutionDiff = crankRevolution - Device.oldCrankRevolution
                crankEventTimeDiff = (((crankEventTime - Device.oldCrankEventTime) / 1024))
                travelCadence = crankRevolutionDiff/crankEventTimeDiff*60
                print("travelCadence:  \(travelCadence)")

            }
            
        }
    }
    

    Device.oldCrankRevolution = crankRevolution
    Device.oldCrankEventTime = crankEventTime
    
    if travelCadence > 0 {
        Device.oldTravelCadence = travelCadence
    }

    if travelCadence == 0 && zeroTester == 0 {
        zeroTester += 1
        return 999
    } else {
        zeroTester = 0
        return travelCadence
    }
    
    
    

    
    
    
    // 1st
//    if Device.oldCrankEventTime != 0 {
//        crankEventTimeDiff = crankEventTime - Device.oldCrankEventTime
//        
//        if crankEventTimeDiff < 0 {
//            crankEventTimeDiff = crankEventTimeDiff + 255
//        }
//        
//        if crankEventTimeDiff >= 0 {
//            crankEventTimeDiff = crankEventTimeDiff / 1024.0
//        }
//    }
    
    // 2nd
//    if Device.oldCrankRevolution != 0 {
//        crankRevolutionDiff = Double(crankRevolution - Device.oldCrankRevolution)
//        
//        if crankRevolutionDiff < 0 {
//            crankRevolutionDiff = crankRevolutionDiff + 255
//        }
//        
//        if crankRevolutionDiff >= 0 {
//            //crankRevolutionDiff5 = crankRevolutionDiff5 + crankRevolutionDiff
//            Totals.crankRevolutionDiffTotal = Totals.crankRevolutionDiffTotal + crankRevolutionDiff
//        }
//    }
    
    // 3rd
//    if crankEventTimeDiff >= 0 && crankEventTimeDiff < 10 {
//        travelCadence = (Double(crankRevolutionDiff / crankEventTimeDiff) * Double(60))
//        
//        if travelCadence.isNaN || travelCadence.isInfinite {
//            //print("travelCad is NaN/Inf:  \(travelCadence)")
//        }
//        
//        if crankRevolutionDiff >= 0 {
//            //print("travelCadence:  \(travelCadence)")
//        }
//        
//        //crankEventTimeDiff5 = crankEventTimeDiff5 + crankEventTimeDiff
//        //cadRPM5 = Double(crankRevolutionDiff5 / timerDouble) * Double(60)  //Using Timer for Time
//        //cadRPM5 = Double(crankRevolutionDiff5 / crankEventTimeDiff5) * Double(60)
//        
//        Totals.crankEventTimeDiffTotal = Totals.crankEventTimeDiffTotal + crankEventTimeDiff
//        
//        
//        
//        if Totals.crankRevolutionDiffTotal > 1 {
//
//            Totals.avg_cad =  Double(Totals.crankRevolutionDiffTotal / Totals.crankEventTimeDiffTotal) * Double(60)
//            print("Avg Cadence:  \(Totals.avg_cad)")
//            
//            print("\n")
//            print("Crank Revs:  \(Totals.crankRevolutionDiffTotal)")
//            print("Crank Time:  \(Totals.crankEventTimeDiffTotal)")
//            print("\n")
//
//        }
//    }
    
    
    
    // 4th
//    if crankRevolutionDiff == 0 && crankEventTimeDiff == 0 {
//        travelCadence = 0
//    }
    
    

    
    
    // short arr
    //            GlobalVariables.globalArrRPMrevdiff.append(crankRevolutionDiff)
    // short arr, ms
    //            GlobalVariables.globalArrRPMtimediff.append(crankEventTimeDiff)
    
    //GlobalVariables.globalTotalCadence = round(cadRPMTotal * 10) / 10
    

}





