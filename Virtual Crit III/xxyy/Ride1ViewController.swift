//
//  FirstViewController.swift
//  xxyy
//
//  Created by aaronep on 10/25/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    

//    @IBOutlet weak var constraint_topInfoBar: NSLayoutConstraint!
//    
//    @IBOutlet weak var constraint_stactViewMain: NSLayoutConstraint!
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let currentPoint = touch.location(in: view)
//            print(currentPoint.x)
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let currentPoint = touch.location(in: view)
//            print(currentPoint.x)
//        }
//    }
    
    @objc func switchToDataTabCont(){
        
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ID3")
        
        self.tabBarController?.selectedIndex = 2;
        
        //self.tabBarController?.present(newViewController, animated: true, completion: nil)

        //this is modal
        //self.present(newViewController, animated: true, completion: nil)
        
        //performSegue(withIdentifier: "SEG1", sender: nil)
        //self.performSegue(withIdentifier: "SEG1", sender: nil)
    }
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 2:
            print("Case 2")
            switchToDataTabCont()
        case 1:
            print("Case 1")
            switchToDataTabCont()
        case 4:
            print("Case 4 UP")
            //changeTitle()
            
        default:
            print("default Gesture - not up, left, or right")
            break
        }
    }
    
    //touch anywhere to present the other view controller
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let currentPoint = touch.location(in: view)
//            print(currentPoint.x)
//            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
//        }
//    }

    
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_Speed: UILabel!
    @IBOutlet weak var lbl_Cadence: UILabel!
    @IBOutlet weak var lbl_HR: UILabel!
    @IBOutlet weak var lbl_Distance: UILabel!
    
    @IBOutlet weak var lbl_Top_Info_Bar: UILabel!
    
    @IBOutlet weak var lbl_hrLabel: UILabel!
    @IBOutlet weak var lbl_cadLabel: UILabel!
    
    
    
    
    @objc func update1() {
        lbl_Time.text = rt.string_elapsed_time  //NS Date Time since launch
        lbl_Distance.text = "\(stringer2(myIn: rt.total_distance)) MILES"
        
        let mvspd = rt.total_distance / (rt.total_moving_time_seconds / 60 / 60)
        lbl_Top_Info_Bar.text = "AVG \(stringer1(myIn: mvspd))  \(rt.total_moving_time_string) MOV"
    }
    
    @objc func update2() {
        lbl_HR.text = "\(stringer0(myIn: rt.rt_hr))"
        let percentofmax = stringer0(myIn: Double((Double(rt.rt_hr) / Double(settings_MAXHR)) * Double(100)))
        lbl_hrLabel.text = "HR: \(percentofmax)%"
        lbl_cadLabel.text = "CAD"
    }
    @objc func update3() {
        lbl_Speed.text = "\(stringer1(myIn: rt.rt_speed))"
    }
    @objc func update4() {
        lbl_Cadence.text = "\(stringer0(myIn: rt.rt_cadence))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe)
        
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(upSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)

        NotificationCenter.default.addObserver(self, selector: #selector(update1), name: Notification.Name("update"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update2), name: Notification.Name("heartrate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update3), name: Notification.Name("speed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update4), name: Notification.Name("cadence"), object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

