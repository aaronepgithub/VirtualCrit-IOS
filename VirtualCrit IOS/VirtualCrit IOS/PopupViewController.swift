//
//  PopupViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 5/24/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    var titleArray = ["1", "2", "3", "4", "5"]
    var subtitleArray = ["1", "2", "3", "4", "5"]
    

    
    

    //@IBOutlet weak var reuseCell: UITableViewCell!
    
    @IBAction func Back(_ sender: UIButton) {
        //dismiss
        self.dismiss(animated: true)
        

        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
    return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//            return titleArray.count
        return tempArrHR.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuse_identifier") as! TableViewCell
        
        
//        cell.cellTitle.text = tempArrHR[indexPath.row]
        cell.cellTitle.text = tempArrScore[indexPath.row]
        cell.cellSubTitle.text = tempArrSPD[indexPath.row]
        

        
        return cell
    }
    



}
