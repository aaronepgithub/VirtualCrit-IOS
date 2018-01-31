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
//            let txt = "MID-ROUND UPDATE\n"
//            str += txt
            if let n1 = userInfo[AnyHashable("color")] {
                //print(String(describing: userInfo[AnyHashable("n1")]!))
                //btHR.text = "\(hrv as! String)"  //HR
                print(n1)
                colorToUse = UIColor.blue
            }
            if let nt = userInfo[AnyHashable("title")] {
                let txt = "\(nt as! String)\n"
                str += txt
            }
            
            if let n2 = userInfo[AnyHashable("hr")] {
                //print(String(describing: userInfo[AnyHashable("n2")]!))
                //print(n2)
                let txt = "\(n2 as! String)  BPM \n"
                str += txt
                
            }
            if let n3 = userInfo[AnyHashable("speed")] {
                //print(String(describing: userInfo[AnyHashable("n3")]!))
                //print(n2)
                let txt = "\(n3 as! String)  MPH \n"
                str += txt
            }
            if let n4 = userInfo[AnyHashable("cadence")] {
                //print(String(describing: userInfo[AnyHashable("n3")]!))
                //print(n4)
                let txt = "\(n4 as! String)  RPM \n"
                str += txt
            }
            if let n5 = userInfo[AnyHashable("geospeed")] {
                let txt = "\(n5 as! String)  MPH (GPS) \n"
                str += txt
            }
            
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
        nextPt.touchUpInside = nil
        nextPt.pointColor = .black
        nextPt.lineColor = .black
        nextPt.fill = true
        self.timeline.points.insert(nextPt, at: 0)
        //udString += "\(ti)\n\(titleString)\n"
        //        if gpsEnabled == true {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
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
        //udString += "\(ti)\n\(titleString)\n"
        //        if gpsEnabled == true {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
    }
    
    
//    let newDesc = "New Description"
//    let newPoint =  ISPoint(title: "\(Date())", description: newDesc, pointColor: UIColor.black, lineColor: UIColor.black, touchUpInside: newTouchAction, fill: true)
//
//    self.timeline.points.insert(newPoint, at: 0)
    
    func blueTouch(point:ISPoint) {
    
        if la != 0 {
            //let myLnk = "http://maps.apple.com/?ll=\(la),\(lo)\n"
            
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
        print("newBluePoint")
        let ti = getFormattedTime()
        let nextPt = ISPoint(title: titleString)
        nextPt.description = ti
        nextPt.touchUpInside = nil
        nextPt.pointColor = .blue
        nextPt.lineColor = .blue
        nextPt.fill = false
        nextPt.touchUpInside = blueTouch
        self.timeline.points.insert(nextPt, at: 0)
        //self.timeline.points.append(nextPt)
        udString += "\(ti)\n\(titleString)\n"
                if la != 0 {
                    udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
                }
        
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
        udString += "\(ti)\n\(titleString)\n"
        //        if gpsEnabled == true {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
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
        //udString += "\(ti)\n\(titleString)\n"
        //        if gpsEnabled == true {
        //            udString += "http://maps.apple.com/?ll=\(la),\(lo)\n"
        //        }
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
            
            ISPoint(title: "ACTIVITY TIMELINE HAS STARTED\nSELECT AN ACTIVITY, SET YOUR NOTIFICATION RULES AND BEGIN.", description: "\(st)", touchUpInside: touchAction)
        ]
        
        timeline.contentInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0)
        timeline.points = myPoints
        
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateTL(not:)), name: Notification.Name("tlUpdate"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
