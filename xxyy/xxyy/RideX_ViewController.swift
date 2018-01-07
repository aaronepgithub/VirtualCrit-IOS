//
//  RideX_ViewController.swift
//  xxyy
//
//  Created by aaronep on 1/7/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class RideX_ViewController: UIViewController {

    var swiperCounter: Int = 0
    
    //SAME HEADER ALWAYS
    //SAME FOOTER ALWAYS
    
    //DISPLAY ARR
    //DISPLAY[0] TIME OF DAY
    //1 MOVING TIME
    //2 ACTUAL TIME
    
    
    @objc func update1() {
        //TIME
    }
    @objc func update2() {
        //HR
    }
    @objc func update3() {
        //SPD
    }
    @objc func update4() {
        //CAD
    }
    
    @objc func switchToDataTabCont(){
        //self.tabBarController?.selectedIndex = 2;
    }
    
    @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 2:
            print("Case 2 - LEFT")
        case 1:
            print("Case 1 - RIGHT")
        case 4:
            print("Case 4 UP")
        default:
            print("default Gesture - not up, left, or right")
            break
        }
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
