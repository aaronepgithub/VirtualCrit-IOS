//
//  Viewer_VC.swift
//  iVirtualCrit
//
//  Created by aaronep on 1/30/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class Viewer_VC: UIViewController {
    
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var footer: UILabel!
    
    @IBOutlet weak var lab1: UILabel!
    @IBOutlet weak var lab2: UILabel!
    @IBOutlet weak var lab3: UILabel!
    
    @IBOutlet weak var dat1: UILabel!
    @IBOutlet weak var dat2: UILabel!
    @IBOutlet weak var dat3: UILabel!
    
    
    
    
    
    
    @objc func updateDisplay() {
        //print("...")
//        print("arr send  \(arrSend[0])")
//        dump(arrSend)
//        print("\n")
        header.text = "\(arrSend[0])"
        footer.text = "\(arrSend[7])"
        dat1.text = "\(arrSend[1])"
        dat2.text = "\(arrSend[2])"
        dat3.text = "\(arrSend[3])"
        lab1.text = "\(arrSend[4])"
        lab2.text = "\(arrSend[5])"
        lab3.text = "\(arrSend[6])"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var i: Int = 0
        while i < 8 {
            arrSend.append("0")
            i += 1
        }
        header.text = "\(arrSend[0])"
        footer.text = "\(arrSend[7])"
        dat1.text = "\(arrSend[1])"
        dat2.text = "\(arrSend[2])"
        dat3.text = "\(arrSend[3])"
        lab1.text = "\(arrSend[4])"
        lab2.text = "\(arrSend[5])"
        lab3.text = "\(arrSend[6])"
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDisplay), name: Notification.Name("viewUpdate"), object: nil)

        

        
    }
    override func viewDidAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        
        var i: Int = 0
        while i < 8 {
            arrSend.append("0")
            i += 1
        }
        header.text = "\(arrSend[0])"
        footer.text = "\(arrSend[7])"
        dat1.text = "\(arrSend[1])"
        dat2.text = "\(arrSend[2])"
        dat3.text = "\(arrSend[3])"
        lab1.text = "\(arrSend[4])"
        lab2.text = "\(arrSend[5])"
        lab3.text = "\(arrSend[6])"
        
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