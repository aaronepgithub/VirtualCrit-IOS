//
//  Ride3ViewController.swift
//  xxyy
//
//  Created by aaronep on 1/3/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class Ride3ViewController: UIViewController {
    
    @IBOutlet weak var lbl_Speed: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    
    @objc func switchToDataTabCont(){
        self.tabBarController?.selectedIndex = 1;
    }
    
    
    var currentTitle: Int = 1
    func changeTitle() {
        let x = currentTitle
    
        if (x == 1) {
            lbl_Title.text = "CADENCE"
            currentTitle = 2
        }
        if (x == 2) {
            lbl_Title.text = "HEARTRATE"
            currentTitle = 3
        }
        if (x == 3) {
            lbl_Title.text = "SPEED"
            currentTitle = 1
        }
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
            changeTitle()
            
        default:
            print("default Gesture - not up, left, or right")
            break
        }
    }
    
    @objc func update1() {
        //update
    }
    @objc func update2() {
        //update
    }
    @objc func update3() {
        //update
    }
    @objc func update4() {
        //update
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
