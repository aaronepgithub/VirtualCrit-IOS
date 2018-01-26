//
//  TLViewController.swift
//  xxyy
//
//  Created by aaronep on 1/16/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit
import AudioToolbox


class TLViewController: UIViewController {
    
    //    https://github.com/instant-solutions/ISTimeline
    
    @IBOutlet weak var timeline: ISTimeline!
    
    
    func newPoint(titleString: String) {
        print("newPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    
    func newBlack(titleString: String) {
        print("newBlack")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    func newBluePoint(titleString: String) {
        print("newBluePoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .blue
        nextPt.lineColor = .blue
        nextPt.fill = false
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    func newGreenPoint(titleString: String) {
        print("newGreenPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .green
        nextPt.lineColor = .green
        nextPt.fill = false
        self.timeline.points.insert(nextPt, at: 0)
    }
    func newRedPoint(titleString: String) {
        print("newRedPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .red
        nextPt.lineColor = .red
        nextPt.fill = false
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    
    var hrHasVal = 0
    
    @objc func updateR() {
        
        
        
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            if round.speeds.count > 0  {
                //arrResults = []
                var s = round.speeds.count
                var a = 0
                if s == 0 {
                    return
                    
                } else {
                    //arrResults.append("ROUNDS COMPLETED")
                    let text1 = "ROUND COMPLETE (LAST 5)\n"
                    var text2 = ""
                    while s > 0 && a < 5 {
                        text2 += "ROUND#  \(s-1) \n"
                        text2 += " \(stringer2(myIn: round.speeds[s-1])) MPH (SPD)  \n"
                        text2 += " \(stringer1(myIn: round.cadences[s-1])) RPM (CAD)  \n"
                        text2 += " \(stringer1(myIn: round.heartrates[s-1])) BPM (HR) \n"
                        text2 += " \(stringer1(myIn: round.geoSpeeds[s-1])) MPH (GPS SPD) \n"
                        text2 += "\n"
                        
                        //arrResults.append("\(s-1):  \(stringer2(myIn: round.speeds[s-1])) MPH  \(stringer1(myIn: round.cadences[s-1])) RPM  \(stringer1(myIn: round.heartrates[s-1])) BPM  \(stringer1(myIn: round.geoSpeeds[s-1]))  GPS SPD")
                        s = s - 1
                        a = a + 1
                        

                    }
                    self.self.newBluePoint(titleString: "\(text1) \n\(text2)")
                }
            }
            if gpsEnabled == true && round.geoSpeeds.count > 0 {
                var s = round.geoSpeeds.count
                var a = 0
                if s == 0 {
                    return
                } else {
                    let text1 = "ROUND SPEEDS/PACE (GEO)"
                    var text2 = ""
                    while s > 0 && a < 50 {
                        text2 += "\(stringer2(myIn: round.geoSpeeds[s-1]))  \(calcMinPerMile(mph: round.geoSpeeds[s-1])) "
                        text2 += "\n"
                        s = s - 1
                        a = a + 1
                    }
                    self.self.newBluePoint(titleString: "\(text1) \n\(text2)")
                }
            }
        }
        
        let when2 = DispatchTime.now() + 15
        DispatchQueue.main.asyncAfter(deadline: when2){
            if maxString != "" {
                self.newRedPoint(titleString: maxString)
            }
        }
        
        
    }
    
    var maxHR = 100.0
    var maxCAD = 80.0
    var maxSPD = 15.0
    
    
    @objc func updateT() {
        
        if rt.rt_hr > maxHR {
            maxHR = rt.rt_hr
            newPoint(titleString: "NEW MAX HEARTRATE:  \(stringer1(myIn: maxHR))")
        }
        if rt.rt_cadence > maxCAD {
            maxCAD = rt.rt_cadence
            newPoint(titleString: "NEW MAX CADENCE:  \(stringer1(myIn: maxCAD))")
        }
        if rt.rt_speed > maxSPD {
            maxSPD = rt.rt_speed
            newPoint(titleString: "NEW MAX SPD:  \(stringer2(myIn: maxSPD))")
        }
        if geo.speed > maxSPD {
            maxSPD = geo.speed
            newPoint(titleString: "NEW MAX SPD:  \(stringer2(myIn: maxSPD))")
        }
        
        if rt.rt_hr > 0 && hrHasVal == 0 {
            newPoint(titleString: "HEARTRATE IS NOW BEING CAPTURED")
            hrHasVal = 1
        }
        
        let x = 100
        
        if ((rt.int_elapsed_time % x) == 0)  {
            
            if gpsEnabled == true  && rt.int_elapsed_time > 5 && geo.avgSpeed > 0 && geo.avgSpeed.isNaN == false && geo.avgSpeed.isFinite == true {
                
                var tx = ""
                tx =  "\(rt.int_elapsed_time) SEC UPDATE \n RT GPS:  \(stringer1(myIn:  geo.speed)) MPH  \(geo.pace) PACE \n"
                tx += " RND GPS:  \(stringer1(myIn:  round.geoSpeed)) MPH  \(calcMinPerMile(mph: round.geoSpeed)) PACE \n"
                tx += " TOTAL GPS:  \(stringer2(myIn: geo.total_distance)) MILES  \(stringer1(myIn:  geo.avgSpeed)) AVG MPH \n \(geo.avgPace) MIN PER MILE"
                
                newBlack(titleString: tx)
            }
            
            if rt.rt_hr > 0 || rt.rt_speed > 0 || rt.rt_cadence > 0 {
                
                newBluePoint(titleString: "\(x)s \n \(stringer0(myIn: rt.rt_hr)) BPM     \(stringer0(myIn: rt.rt_cadence)) RPM      \(stringer1(myIn: rt.rt_speed)) RT MPH ")
            }
        }
//        if (rt.int_elapsed_time % 300) == 0 {
//        }
    }
    
    
    @objc func updateNM() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if rt.total_distance > 0 && geo.total_distance > 0 {
            newGreenPoint(titleString: "ANOTHER MILE COMPLETED \n TOTAL DISTANCE:  \(stringer0(myIn: rt.total_distance)) MILES \n \(geo.total_distance) GPS MILES \n \(previousMileSpeed)")
        } else {
            if rt.total_distance > 0 {
                newGreenPoint(titleString: "ANOTHER MILE COMPLETED \n TOTAL DISTANCE:  \(stringer0(myIn: rt.total_distance)) MILES \n \(previousMileSpeed)")
            }
            if geo.total_distance > 0 {
                newGreenPoint(titleString: "ANOTHER MILE COMPLETED \n TOTAL DISTANCE:  \(stringer0(myIn: geo.total_distance)) MILES \n \(previousMileSpeed)")
            }
        }

        
    }
    
    func getFormattedTime() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: currentDateTime)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let st = getFormattedTime()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateT), name: Notification.Name("update"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateR), name: Notification.Name("newRound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNM), name: Notification.Name("newMile"), object: nil)
        
        let black = UIColor.black
        let green = UIColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
        let red = UIColor.init(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        
        func newTouchAction(point:ISPoint) {
            print("again, \(ISPoint.self)")
            
            let nextPt = ISPoint(title: "Next Pt Title")
            nextPt.description = "Really long text, Really long text, Really long text, Really long text, Really long text, Really long text"
            nextPt.touchUpInside = nil
            nextPt.pointColor = red
            nextPt.lineColor = red
            nextPt.fill = true
            self.timeline.points.insert(nextPt, at: 0)
            
            
        }
        
        let touchAction = { (point:ISPoint) in
            print("point \(point.title)")
            
            let newDesc = "New Description"
            let newPoint =  ISPoint(title: "\(Date())", description: newDesc, pointColor: black, lineColor: black, touchUpInside: newTouchAction, fill: true)
            
            self.timeline.points.insert(newPoint, at: 0)
        }
        
        let myPoints = [
            
            ISPoint(title: "ACTIVITY TIMELINE HAS STARTED\nSELECT AN ACTIVITY, SET YOUR NOTIFICATION RULES AND BEGIN.", description: "\(st)", touchUpInside: touchAction)
        ]
        
        timeline.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        timeline.points = myPoints
    }
    
    
    
    
    
}


