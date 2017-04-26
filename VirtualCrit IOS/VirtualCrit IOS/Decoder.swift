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




//var zeroTesterSpeed          : Double = 0
//
//func processWheelData(withData data :Data) -> Double {
////func processWheelData(withData data :Data) {
//    var wheelRevolution8     :UInt8  = 0
//    var wheelRevolution      :Double  = 0
//    var wheelEventTime      :Double = 0
//    var wheelRevolutionDiff :Double = 0
//    var wheelEventTimeDiff  :Double = 0
//    var travelDistance      :Double = 0
//    var travelSpeed         :Double = 0
//    
//    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
//    
//    wheelRevolution8 = UInt8(Double(CFSwapInt32LittleToHost(UInt32(value[1]))))
//    wheelEventTime  = Double((UInt16(value[6]) * 0xFF) + UInt16(value[5]))
//    wheelRevolution = Double(wheelRevolution8)
//    
////    print(" \nCurrent wheel Rev:  \(wheelRevolution)")
////    print("Current wheel Time:  \(wheelEventTime)")
////    
////    print("Old wheel Rev:  \(Device.oldWheelRevolution)")
////    print("Old wheel Time:  \(Device.oldWheelEventTime) \n")
//    
//    if Device.oldWheelRevolution > 0 {  //test for first time reading
//        if Device.oldWheelRevolution == wheelRevolution && Device.oldWheelEventTime == wheelEventTime { //test for 0 speed
//            print("Current Speed is 0")
//            travelSpeed = 0
//        } else {
//            
//            if Device.oldWheelRevolution > wheelRevolution || Device.oldWheelEventTime > wheelEventTime { //ignore readings when counter resets
//                print("reset counter, ignore")
//            } else {
//                wheelRevolutionDiff = wheelRevolution - Device.oldWheelRevolution
//                wheelEventTimeDiff = (((wheelEventTime - Device.oldWheelEventTime) / 1024)) //seconds
//                
//                
//                travelDistance = wheelRevolutionDiff * Device.wheelCircumference! / 1000 * 0.000621371  //segment, in miles
//                Totals.distanceTotal = Totals.distanceTotal + travelDistance
//                
//                travelSpeed = travelDistance / (wheelEventTimeDiff / 60 / 60) //miles/hour
//
//                print("travelSpeed:  \(travelSpeed)")
//                //print("Totals.distanceTotal:  \(Totals.distanceTotal)")
//                
//            }
//            
//        }
//    }
//    
//    Device.oldWheelRevolution = Double(wheelRevolution)
//    Device.oldWheelEventTime = Double(wheelEventTime)
//    
//    if travelSpeed == 0 && zeroTesterSpeed == 0 {
//        zeroTesterSpeed += 1
//        return 999
//    } else {
//        zeroTesterSpeed = 0
//        Device.currentSpeed = travelSpeed
//        return travelSpeed
//    }
//    
//
//
//    
//}
//    
//
//var zeroTester          : Double = 0
//
//func processCrankData(withData data : Data, andCrankRevolutionIndex index : Int) -> Double {
//    
//    var crankEventTime      : Double = 0
//    var crankRevolutionDiff : Double = 0
//    var crankEventTimeDiff  : Double = 0
//    var crankRevolution     : Double = 0
//    var travelCadence       : Double = 0
//
//    
//    let value = UnsafeMutablePointer<UInt8>(mutating: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count))
//    
//    crankRevolution = Double(CFSwapInt16LittleToHost(UInt16(value[index])))
//    crankEventTime  = Double((UInt16(value[index+3]) * 0xFF) + UInt16(value[index+2]))+1.0
//    
////    print(" \n Current Crank Rev:  \(crankRevolution)")
////    print("Current Crank Time:  \(crankEventTime)")
////
////    print("Old Crank Rev:  \(Device.oldCrankRevolution)")
////    print("Old Crank Time:  \(Device.oldCrankEventTime) \n")
//
//    
//    if Device.oldCrankRevolution > 0 {  //test for first time reading
//        if Device.oldCrankRevolution == crankRevolution && Device.oldCrankEventTime == crankEventTime { //test for 0 cadence
//            //print("Current Cadence is 0")
//            travelCadence = 0
//        } else {
//            
//            if Device.oldCrankRevolution > crankRevolution || Device.oldCrankEventTime > crankEventTime { //ignore readings when counter resets
//                //print("reset counter, ignore")
//            } else {
//                crankRevolutionDiff = crankRevolution - Device.oldCrankRevolution
//                crankEventTimeDiff = (((crankEventTime - Device.oldCrankEventTime) / 1024))
//                travelCadence = crankRevolutionDiff/crankEventTimeDiff*60
//                //print("travelCadence:  \(travelCadence)")
//
//            }
//            
//        }
//    }
//    
//
//    Device.oldCrankRevolution = crankRevolution
//    Device.oldCrankEventTime = crankEventTime
//
//    if travelCadence == 0 && zeroTester == 0 {
//        zeroTester += 1
//        return 999
//    } else {
//        zeroTester = 0
//        Device.currentCadence = travelCadence
//        return travelCadence
//    }
//    
//
//}
//




