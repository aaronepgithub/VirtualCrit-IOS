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
    
    var colorToUse: UIColor = UIColor.blue
    
    @objc func updateTL(not: Notification) {
        var str = ""
        
        if let userInfo = not.userInfo {
            if let n1 = userInfo[AnyHashable("color")] {
                colorToUse = UIColor.blue
                if n1 as! String == "red" {colorToUse = UIColor.red}
                if n1 as! String == "black" {colorToUse = UIColor.black}
                if n1 as! String == "green" {colorToUse = UIColor.green}
                if n1 as! String == "yellow" {colorToUse = UIColor.yellow}
            }
            
            if let nt = userInfo[AnyHashable("title")] {
                let txt = "\(nt as! String)\n"
                str += txt
            }
            str += "\n"
            self.newBluePoint(titleString: "\(str)")
            //            let ti = getFormattedTime()
            //            udString += "\(ti)\n\(str)\n"
            //            if la != 0 {
            //                udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
            //            }
        }
    }
    
    func newBluePoint(titleString: String) {
        //print("newBluePoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.pointColor = colorToUse
        nextPt.lineColor = colorToUse
        nextPt.fill = true
        nextPt.touchUpInside = blueTouch
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
        nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
        //        udString += "\(ti)\n\(titleString)\n"
        //        if la != 0 {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
    }
    
    
    func newBlack(titleString: String) {
        //print("newBlack")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
        //        udString += "\(ti)\n\(titleString)\n"
        //        if la != 0 {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
    }
    
    
    
    
    
    
    func newGreenPoint(titleString: String) {
        //print("newGreenPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = blueTouch
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
        nextPt.pointColor = .red
        nextPt.lineColor = .red
        nextPt.fill = false
        self.timeline.points.insert(nextPt, at: 0)
    }
    
    func blueTouch(point:ISPoint) {
        print("blueTouch")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("TL will Disappear")
        stopTimer()
        //NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("TL will Appear")
        startTimer()
        //        NotificationCenter.default.addObserver(self, selector: #selector(updateTL(not:)), name: Notification.Name("tlUpdate"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("TL did Appear")
        timerInterval()
    }
    
    var timer = Timer()
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
        print("Timer Started")
    }
    
    @objc func timerInterval() {
    
        let count: Int = valueTimelineString.count
        if (count > 0) {
            for s in valueTimelineString {
                print(s)
                newRedPoint(titleString: s)
            }
            valueTimelineString.removeAll()
        }
    }
    
    func stopTimer() {
        print("Timer Stopped")
        timer.invalidate()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(updateTL(not:)), name: Notification.Name("tlUpdate"), object: nil)
        
        //func newTouchAction(point:ISPoint) {
        //print("again, \(ISPoint.self)")
        //            let nextPt = ISPoint(title: "Next Pt Title")
        //            nextPt.description = "Really long text, Really long text, Really long text, Really long text, Really long text, Really long text"
        //            nextPt.touchUpInside = nil
        //            nextPt.pointColor = UIColor.red
        //            nextPt.lineColor = UIColor.red
        //            nextPt.fill = true
        //            self.timeline.points.insert(nextPt, at: 0)
        //}
        
        //let touchAction = { (point:ISPoint) in
        //            print("point \(point.title)")
        //            let newDesc = "New Description"
        //            let newPoint =  ISPoint(title: "\(Date())", description: newDesc, pointColor: UIColor.black, lineColor: UIColor.black, touchUpInside: newTouchAction, fill: true)
        //            self.timeline.points.insert(newPoint, at: 0)
        //}
        
        
//        let st = getFormattedTime()
//        let myPoints = [
//            ISPoint(title: "VIRTUAL CRIT HAS STARTED\n", description: "\(st)", touchUpInside: nil)
//        ]
//        timeline.contentInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
//        timeline.points = myPoints

        
        //startTimer()
        timerInterval()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
