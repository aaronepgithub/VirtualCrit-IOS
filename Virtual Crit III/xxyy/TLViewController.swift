//
//  TLViewController.swift
//  xxyy
//
//  Created by aaronep on 1/16/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class TLViewController: UIViewController {

//    https://github.com/instant-solutions/ISTimeline
    
    @IBOutlet weak var timeline: ISTimeline!
    @IBAction func Dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
    @objc func updateT() {
        if rt.rt_hr > 0 && hrHasVal == 0 {
            newHRpoint(titleString: "HEARTRATE IS NOW BEING CAPTURED")
            hrHasVal = 1
        }
        
        if (rt.int_elapsed_time % 30) == 0 {
            new30point(titleString: "30s \n \(stringer0(myIn: rt.rt_hr)) BPM     \(stringer0(myIn: rt.rt_cadence)) RPM      \(stringer1(myIn: rt.rt_speed)) MPH ")
        }
        
        if (rt.int_elapsed_time % 300) == 0 {
            newHRpoint(titleString: "5 MINUTES COMPLETED")
            
            var s = round.speeds.count
            var a = 0
            if s == 0 {return}
            
            let text1 = "SPD   CAD   HRT"
            var text2 = ""
            
            while s > 0 && a < 10 {
                text2 += "\(stringer2(myIn: round.speeds[s-1])) "
                text2 += "\(stringer1(myIn: round.cadences[s-1])) "
                text2 += "\(stringer1(myIn: round.heartrates[s-1])) "
                text2 += "\n"
                s = s - 1
                a = a + 1
                //print(text2)
            }
            
            //lbl_1.text = "\(text1) \n\(text2)"
            new30point(titleString: "\(text1) \n\(text2)")
            
            
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


