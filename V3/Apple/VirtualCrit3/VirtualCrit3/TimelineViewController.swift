//
//  TimelineViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 3/1/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit
import MapKit

//var udString: String = "\n\nSESSION TIMELINE \n"
//var udArray = [String]()

func getFormattedTime() -> String {
    let currentDateTime = Date()
    let formatter = DateFormatter()
    formatter.timeStyle = .medium
    formatter.dateStyle = .none
    return formatter.string(from: currentDateTime)
}


class TimelineViewController: UIViewController {

    //https://github.com/instant-solutions/ISTimeline
    
    
    @IBOutlet weak var timeline: ISTimeline!
    
    
//    func getFormattedTime() -> String {
//        let currentDateTime = Date()
//        let formatter = DateFormatter()
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .none
//        return formatter.string(from: currentDateTime)
//    }
    
    var colorToUse: UIColor = UIColor.red
    
    
    func newBluePoint(titleString: String) {
        //print("newBluePoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.pointColor = colorToUse
        nextPt.lineColor = colorToUse
        nextPt.fill = true
        //nextPt.touchUpInside = blueTouch
        self.timeline.points.insert(nextPt, at: 0)
        //        udString += "\(ti)\n\(titleString)\n"
        //        if la != 0 {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
        colorToUse = UIColor.blue
        
    }
    
    
    
    
    func newPoint(titleString: String) {
        //print("newPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        //nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    
    func newBlack(titleString: String) {
        //print("newBlack")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        //nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    func newGreenPoint(titleString: String) {
        //print("newGreenPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        //nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .green
        nextPt.lineColor = .green
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)

    }
    func newRedPoint(titleString: String) {
        //print("newRedPoint")
        //let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        //nextPt.description = ti
        //nextPt.touchUpInside = blueTouch
        nextPt.pointColor = colorToUse
        nextPt.lineColor = colorToUse
        nextPt.fill = false
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        stopTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        startTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        timerInterval()
    }
    
    var timer = Timer()
    func startTimer() {
        print("TL Timer Started")
        timer = Timer.scheduledTimer(timeInterval: 3,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
        
    }
    
    @objc func timerInterval() {
    
        let count: Int = valueTimelineString.count
        if (count > 0) {
            for s in valueTimelineString {
                print(s)
                if s.starts(with: "Round") {colorToUse = UIColor.blue}
                if s.starts(with: "Fastest Round") {colorToUse = UIColor.blue}
                if s.starts(with: "CHECKPOINT") {colorToUse = UIColor.green}
                if s.starts(with: "RACE STARTED") {colorToUse = UIColor.black}
                if s.starts(with: "VIRTUAL CRIT IS STARTING") {colorToUse = UIColor.purple}
                newRedPoint(titleString: s)
            }
            valueTimelineString.removeAll()
        }
    }
    
    func stopTimer() {
        //print("Timer Stopped")
        print("TL Timer Stopped")
        timer.invalidate()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerInterval()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
