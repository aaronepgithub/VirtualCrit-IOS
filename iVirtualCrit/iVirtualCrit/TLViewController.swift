//
//  TLViewController.swift
//  iVirtualCrit
//
//  Created by aaronep on 1/30/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit
import MapKit

var udString: String = "History \n"
var udArray = [String]()

class TLViewController: UIViewController {
    
     //    https://github.com/instant-solutions/ISTimeline
    

    @IBOutlet weak var timeline: ISTimeline!
    
    
    func getFormattedTime() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: currentDateTime)
    }
    
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
            
            if let n2 = userInfo[AnyHashable("hr")] {
                let txt = "\(n2 as! String)  BPM \n"
                if n2 as! String != "0.0" {str += txt}
            }
            if let n7 = userInfo[AnyHashable("score")] {
                let txt = "\(n7 as! String)  %MAX \n"
                if n7 as! String != "0.0" {str += txt;str += "\n";}
                
            }
            
            
            
            if let n3 = userInfo[AnyHashable("speed")] {
                let txt = "\(n3 as! String)  MPH \n"
                if n3 as! String != "0.00" {str += txt}
            }
            if let n5 = userInfo[AnyHashable("geospeed")] {
                let txt = "\(n5 as! String)  MPH (GPS)\n"
                if n5 as! String != "0.00" {str += txt}
            }
            if let n6 = userInfo[AnyHashable("pace")] {
                let txt = "\(n6 as! String) MIN/MILE \n"
                if n6 as! String != "00:00" {str += txt;str += "\n";}
            }
            
            
            
            if let n4 = userInfo[AnyHashable("cadence")] {
                let txt = "\(n4 as! String)  RPM \n"
                if n4 as! String != "0.0" {str += txt;str += "\n";}
            }
            
            //MID ROUND DAILY UPDATE
            if let n10 = userInfo[AnyHashable("totaltime")] {
                let txt = "\(n10 as! String) TOTAL\n"
                str += txt
                str += "\n"
            }
            if let n11 = userInfo[AnyHashable("btmovingtime")] {
                let txt = "\(n11 as! String) MOVING\n"
                if n11 as! String != " " {str += txt}
                
            }
            if let n12 = userInfo[AnyHashable("gpsmovingtime")] {
                let txt = "\(n12 as! String) MOVING(G)\n"
                if n12 as! String != " " {str += txt;str += "\n";}
            }
            
            if let n13 = userInfo[AnyHashable("avgspeed")] {
                let txt = "\(n13 as! String)  AVG SPD\n"
                if n13 as! String != " " {str += txt}
            }
            if let n14 = userInfo[AnyHashable("avgspeedgeo")] {
                let txt = "\(n14 as! String)  AVG SPD(G)\n"
                if n14 as! String != " " {str += txt}
            }
            // END MID ROUND DAILY UPDATE
            
            
            
            if let n9 = userInfo[AnyHashable("btdistance")] {
                let txt = "\(n9 as! String)  MILES\n"
                if n9 as! String != "0.00" {str += txt}
            }
            if let n8 = userInfo[AnyHashable("geodistance")] {
                let txt = "\(n8 as! String)  MILES(G) \n"
                if n8 as! String != "0.00" {str += txt}
            }


            str += "\n"
            
            self.newBluePoint(titleString: "\(str)")
            let ti = getFormattedTime()
            udString += "\(ti)\n\(str)\n"
                    if la != 0 {
                        udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
                    }
            
        }
        
    }
    
    
    
    
    func newPoint(titleString: String) {
        print("newPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
        udString += "\(ti)\n\(titleString)\n"
        if la != 0 {
            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        }
    }
    
    
    func newBlack(titleString: String) {
        print("newBlack")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
        udString += "\(ti)\n\(titleString)\n"
        if la != 0 {
            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        }
    }

    
    func blueTouch(point:ISPoint) {
    
        if la != 0 {
            let latitude: CLLocationDegrees = la//37.2
            let longitude: CLLocationDegrees = lo //22.9
            
            let regionDistance:CLLocationDistance = 10000
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = point.description
            mapItem.openInMaps(launchOptions: options)
            
        }
        
    }
    
    
    func newBluePoint(titleString: String) {
        //print("newBluePoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
//        nextPt.pointColor = .blue
//        nextPt.lineColor = .blue
        nextPt.pointColor = colorToUse
        nextPt.lineColor = colorToUse
        nextPt.fill = true
        nextPt.touchUpInside = blueTouch
        self.timeline.points.insert(nextPt, at: 0)
        udString += "\(ti)\n\(titleString)\n"
                if la != 0 {
                    udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
                }
        colorToUse = UIColor.blue
        
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
        udString += "\(ti)\n\(titleString)\n"
        if la != 0 {
            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        }
    }
    func newRedPoint(titleString: String) {
        //print("newRedPoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = blueTouch
        nextPt.pointColor = .red
        nextPt.lineColor = .red
        nextPt.fill = false
        self.timeline.points.insert(nextPt, at: 0)
        udString += "\(ti)\n\(titleString)\n"
        if la != 0 {
            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        }
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("TL will Disappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("TL will Appear")
        NotificationCenter.default.addObserver(self, selector: #selector(updateTL(not:)), name: Notification.Name("tlUpdate"), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        func newTouchAction(point:ISPoint) {
            print("again, \(ISPoint.self)")
            
            let nextPt = ISPoint(title: "Next Pt Title")
            nextPt.description = "Really long text, Really long text, Really long text, Really long text, Really long text, Really long text"
            nextPt.touchUpInside = nil
            nextPt.pointColor = UIColor.red
            nextPt.lineColor = UIColor.red
            nextPt.fill = true
            self.timeline.points.insert(nextPt, at: 0)
            
            
        }
        
        let touchAction = { (point:ISPoint) in
            print("point \(point.title)")
            
            let newDesc = "New Description"
            let newPoint =  ISPoint(title: "\(Date())", description: newDesc, pointColor: UIColor.black, lineColor: UIColor.black, touchUpInside: newTouchAction, fill: true)
            
            self.timeline.points.insert(newPoint, at: 0)
        }
        
        
         let st = getFormattedTime()
        let myPoints = [
            
            ISPoint(title: "ACTIVITY TIMELINE HAS STARTED\nSELECT AN ACTIVITY,\nSET YOUR NOTIFICATION RULES,\nAND BEGIN.\n", description: "\(st)", touchUpInside: touchAction)
        ]
        
        timeline.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        timeline.points = myPoints
        
//        NotificationCenter.default.addObserver(self, selector: #selector(updateTL(not:)), name: Notification.Name("tlUpdate"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
