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
    
    @objc func update1() {
        
        var s = round.speeds.count
        var a = 0
        if s == 0 {return}
        
        let text1 = "SPD   CAD   HRT"
        var text2 = ""
        
        while s > 0 && a < 5 {
            text2 += "\(stringer1(myIn: round.speeds[s-1])) "
            text2 += "\(stringer1(myIn: round.cadences[s-1])) "
            text2 += "\(stringer1(myIn: round.heartrates[s-1])) "
            text2 += "\n"
            s = s - 1
            a = a + 1
            //print(text2)
        }
        
        lbl_1.text = "\(text1) \n\(text2)"




        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(update1), name: Notification.Name("update"), object: nil)

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
