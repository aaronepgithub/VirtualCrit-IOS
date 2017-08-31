//
//  ForthViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 7/22/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

struct Pacer {
    static var target_distance: Double = 5  //5 miles
    static var target_duration: Double = 20  //20 min
    static var target_avg_speed: Double = 15 // 60 / 15 mph =  4 min per mile

    static var status: String = "On Pace"
}

class ForthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
