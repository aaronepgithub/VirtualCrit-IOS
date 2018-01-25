//
//  TLViewController.swift
//  xxyy
//
//  Created by aaronep on 1/16/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

var arrResults = [String]()
class TLViewController: UIViewController {
    
    //    https://github.com/instant-solutions/ISTimeline
    
    @IBOutlet weak var timeline: ISTimeline!
    
    
    func newHRpoint(titleString: String) {
        print("newHRpoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    
    func new30pointBlack(titleString: String) {
        print("newHRpoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    func new30point(titleString: String) {
        print("newHRpoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .blue
        nextPt.lineColor = .blue
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
                    let text1 = "ROUND COMPLETE \n  SPD   CAD   HRT  GEO SPD "
                    var text2 = ""
                    while s > 0 && a < 50 {
                        text2 += " \(stringer2(myIn: round.speeds[s-1]))  "
                        text2 += " \(stringer1(myIn: round.cadences[s-1]))  "
                        text2 +=  "\(stringer1(myIn: round.heartrates[s-1]))  "
                        text2 +=  "\(stringer1(myIn: round.geoSpeeds[s-1]))  "
                        text2 += "\n"
                        
                        //arrResults.append("\(s-1):  \(stringer2(myIn: round.speeds[s-1])) MPH  \(stringer1(myIn: round.cadences[s-1])) RPM  \(stringer1(myIn: round.heartrates[s-1])) BPM  \(stringer1(myIn: round.geoSpeeds[s-1]))  GPS SPD")
                        s = s - 1
                        a = a + 1
                        

                    }
                    self.self.new30point(titleString: "\(text1) \n\(text2)")
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
                    self.self.new30point(titleString: "\(text1) \n\(text2)")
                }
            }
        }
    }
    
    @objc func updateT() {
        if rt.rt_hr > 0 && hrHasVal == 0 {
            newHRpoint(titleString: "HEARTRATE IS NOW BEING CAPTURED")
            hrHasVal = 1
        }
        
        let x = 100
        
        if ((rt.int_elapsed_time % x) == 0)  {
            
            if gpsEnabled == true  && rt.int_elapsed_time > 5 && geo.avgSpeed > 0 && geo.avgSpeed.isNaN == false && geo.avgSpeed.isFinite == true {
                
                var tx = ""
                tx =  "\(rt.int_elapsed_time) SEC UPDATE \n RT GPS:  \(stringer1(myIn:  geo.speed)) MPH  \(geo.pace) PACE \n"
                tx += " RND GPS:  \(stringer1(myIn:  round.geoSpeed)) MPH  \(calcMinPerMile(mph: round.geoSpeed)) PACE \n"
                tx += " TOTAL GPS:  \(stringer2(myIn: geo.total_distance)) MILES  \(stringer1(myIn:  geo.avgSpeed)) AVG MPH \n \(geo.avgPace) MIN PER MILE"
                
                new30pointBlack(titleString: tx)
            }
            
            if rt.rt_hr > 0 || rt.rt_speed > 0 || rt.rt_cadence > 0 {
                
                new30point(titleString: "\(x)s \n \(stringer0(myIn: rt.rt_hr)) BPM     \(stringer0(myIn: rt.rt_cadence)) RPM      \(stringer1(myIn: rt.rt_speed)) RT MPH ")
            }
        }
//        if (rt.int_elapsed_time % 300) == 0 {
//        }
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


