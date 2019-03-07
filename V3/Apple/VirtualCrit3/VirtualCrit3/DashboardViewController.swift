//
//  DashboardViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 3/1/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit

extension UIView {
    func rotate(degrees: CGFloat) {
        rotate(radians: CGFloat.pi * degrees / 180.0)
    }
    
    func rotate(radians: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}


class DashboardViewController: UIViewController {
    
    @IBOutlet weak var labelMPH: UILabel!
    @IBOutlet weak var labelPACE: UILabel!
    @IBOutlet weak var labelMILES: UILabel!
    
    
    @IBOutlet weak var valuePACE: UILabel!
    @IBOutlet weak var valueMPH: UILabel!
    @IBOutlet weak var valueMILES: UILabel!
    
    @IBOutlet weak var topLeft: UILabel!
    @IBOutlet weak var topRight: UILabel!
    @IBOutlet weak var bottomLeft: UILabel!
    @IBOutlet weak var bottomRight: UILabel!
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")
        } else {
            print("Portrait")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        //print("DASH timer stopped")
        stopTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        timerInterval()
        startTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        labelMPH.rotate(degrees: 90)
        labelPACE.rotate(degrees: 90)
        labelMILES.rotate(degrees: 90)
        
        timerInterval()
        //startTimer()
    }
    
    
    var timer = Timer()
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2,target: self,selector: #selector(timerInterval),userInfo: nil,repeats: true)
        print("DASH Timer Started")
    }
    
    @objc func timerInterval() {
        
        valuePACE.text = displayStrings.pace
        valueMPH.text = displayStrings.speed
        valueMILES.text = displayStrings.distance
        topLeft.text = displayStrings.time
        bottomLeft.text = "\(displayStrings.avgSpeed) MPH "
        
        
        if (bpmEnabled) {
            topRight.text = "\(bpmValue) BPM"
            bottomRight.text = "\(bpmAverage) BPM"
        } else {
//            topRight.text = "\(displayStrings.distance) MI"
            topRight.text = "\(getFormattedTime())"
            bottomRight.text = "\(displayStrings.avgPace) PACE"
        }
    }
    
    func stopTimer() {
        print("DASH Timer Stopped")
        timer.invalidate()
    }
    

}
