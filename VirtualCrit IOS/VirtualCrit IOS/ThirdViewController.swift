//
//  ThirdViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 7/6/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    

    
    var titleArray1 = ["1", "2", "3", "4", "5", "2", "3", "4", "5"]
    var subtitleArray1 = ["1", "2", "3", "4", "5", "2", "3", "4", "5"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//                    return titleArray1.count
        return tempArrHR.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_historyTable") as! TableViewCell1
        
        
        //        cell.cellTitle.text = tempArrHR[indexPath.row]
//        cell.cellTitle.text = tempArrScore[indexPath.row]
//        cell.cellSubTitle.text = tempArrSPD[indexPath.row]

//        cell.cellTitle1.text = titleArray1[indexPath.row]
//        cell.cellSubTitle1.text = subtitleArray1[indexPath.row]
        
                cell.cellTitle1.text = tempArrScore[indexPath.row]
                cell.cellSubTitle1.text = tempArrSPD[indexPath.row]

        
        
        return cell
    }

}
