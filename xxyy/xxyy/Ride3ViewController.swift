//
//  Ride3ViewController.swift
//  xxyy
//
//  Created by aaronep on 1/3/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class Ride3ViewController: UIViewController {
    
    @objc func switchToDataTabCont(){
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "ID1")
        
        self.tabBarController?.selectedIndex = 2;
        
//        self.tabBarController?.present(newViewController, animated: true, completion: nil)
//        self.performSegue(withIdentifier: "SEG3", sender: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            print(currentPoint.x)
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(switchToDataTabCont), userInfo: nil, repeats: false)
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
