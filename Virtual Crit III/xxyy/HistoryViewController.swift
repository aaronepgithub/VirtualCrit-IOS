//
//  HistoryViewController.swift
//  xxyy
//
//  Created by aaronep on 1/4/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var lbl_1: UILabel!

    
    @IBAction func act_Dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let s = round.speeds.count
        
//        let s2 = stringer1(myIn: round.speeds.last!)
//        let s3 = stringer1(myIn: round.speeds[s-2])
//        let s4 = stringer1(myIn: round.speeds[s-3])
//
//        let c2 = stringer1(myIn: round.cadences.last!)
//        let c3 = stringer1(myIn: round.cadences[s-2])
//        let c4 = stringer1(myIn: round.cadences[s-3])
//
//        let h2 = stringer1(myIn: round.heartrates.last!)
//        let h3 = stringer1(myIn: round.heartrates[s-2])
//        let h4 = stringer1(myIn: round.heartrates[s-3])
       
//        let s2 = 11.12
//        let s3 = 11.12
//        let s4 = 11.12
//
//        let c2 = 11.1
//        let c3 = 11.1
//        let c4 = 11.1
//
//        let h2 = 111.1
//        let h3 = 111.1
//        let h4 = 111.1
        
//        let text1 = "SPD   CAD   HRT"
        
        
//        let text2 = " \(s2) \(c2) \(h2)"
//        let text3 = " \(s3) \(c3) \(h3)"
//        let text4 = " \(s4) \(c4) \(h4)"
        
        
//        lbl_1.text = "\(text1) \n\(text2) \n\(text3) \n\(text4) "
        
//ADD REFRESH ON NOTIFY
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
