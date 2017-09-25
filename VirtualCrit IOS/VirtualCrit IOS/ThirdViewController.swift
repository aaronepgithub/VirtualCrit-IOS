//
//  ThirdViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 7/6/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

var score_string_array = [String]()
var speed_string_array = [String]()

var score_string_array_total = [String]()
var speed_string_array_total = [String]()

var tempArrHR1 = [String]()
var tempArrSPD1 = [String]()
var tempArrScore1 = [String]()
var ctrArray = [Int]()


class ThirdViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
 
    
    var titleArray1 = ["1", "2", "3", "4", "5", "2", "3", "4", "5"]
    var subtitleArray1 = ["1", "2", "3", "4", "5", "2", "3", "4", "5"]
    
    
    @IBAction func btn_totalScore(_ sender: UIButton) {
        
        //get & parse total score data
        //if ConnectionCheck.isConnectedToNetwork() {
        
            //getFBTotals()
        
            //let when = DispatchTime.now() + 1
            //DispatchQueue.main.asyncAfter(deadline: when){
                
        tempArrHR1 = []
        tempArrSPD1 = []
        tempArrScore1 = []
        ctrArray = []
        tempArrHR1 = Array(score_string_array_total.prefix(50))
        tempArrSPD1 = Array(score_string_array_total.prefix(50))
        tempArrScore1 = Array(score_string_array_total.prefix(50))
        
        let x = NSDate()
        let y = x.timeIntervalSince(PublicVars.startTime! as Date!)
        let yy = Double(y)
        
        if  yy > 45 {
            ctrArray = Array(1...tempArrHR1.count)
            self.myTableView.reloadData()
            //score_string_array_total = []
            //speed_string_array_total = []

        }
            //}
            
        //}
        
    }
    
    @IBAction func btn_totalSpeed(_ sender: UIButton) {
        
        //get & parse total speed data
        //if ConnectionCheck.isConnectedToNetwork() {
            
            //getFBTotalsSpeed()
            
            //let when = DispatchTime.now() + 1
            //DispatchQueue.main.asyncAfter(deadline: when){
                
        tempArrHR1 = []
        tempArrSPD1 = []
        tempArrScore1 = []
        ctrArray = []
        tempArrHR1 = Array(speed_string_array_total.prefix(50))
        tempArrSPD1 = Array(speed_string_array_total.prefix(50))
        tempArrScore1 = Array(speed_string_array_total.prefix(50))
        
        let x = NSDate()
        let y = x.timeIntervalSince(PublicVars.startTime! as Date!)
        let yy = Double(y)
        if  yy > 45 {
            ctrArray = Array(1...tempArrHR1.count)
            self.myTableView.reloadData()
            //score_string_array_total = []
            //speed_string_array_total = []
        }
                

            //}
            
        //}
    }
    
    //use sorted speed array
    @IBAction func btn_roundAllSpeed(_ sender: UIButton) {
        
        //if ConnectionCheck.isConnectedToNetwork() {
            
            //getFirebaseSpeed()
            
            //let when = DispatchTime.now() + 1
            //DispatchQueue.main.asyncAfter(deadline: when){
                
                tempArrHR1 = []
                tempArrSPD1 = []
                tempArrScore1 = []
                ctrArray = []
                
                tempArrHR1 = Array(speed_string_array.prefix(50))
                tempArrSPD1 = Array(speed_string_array.prefix(50))
                tempArrScore1 = Array(speed_string_array.prefix(50))
                
                if tempArrHR1.count == 0 {return}
                
                ctrArray = Array(1...tempArrHR1.count)
                self.myTableView.reloadData()
            //}
        //}
    }
    

    //use sorted score array
    @IBAction func btn_roundAll(_ sender: UIButton) {
        
        //if ConnectionCheck.isConnectedToNetwork() {
            
            //getFirebase()
            
            //let when = DispatchTime.now() + 1
            //DispatchQueue.main.asyncAfter(deadline: when){

                tempArrHR1 = []
                tempArrSPD1 = []
                tempArrScore1 = []
                ctrArray = []
                tempArrHR1 = Array(score_string_array.prefix(50))
                tempArrSPD1 = Array(score_string_array.prefix(50))
                tempArrScore1 = Array(score_string_array.prefix(50))
                
                if tempArrHR1.count == 0 {return}
                
                ctrArray = Array(1...tempArrHR1.count)
                self.myTableView.reloadData()
            //}
        
        //}
        
    }
    
    @IBAction func btn_SpeedMeReload(_ sender: UIButton) {
        
        print(tempArrSPD)
        
        if tempArrSPD.count > 0 {
            
            tempArrHR1 = []
            tempArrSPD1 = []
            tempArrScore1 = []
            ctrArray = []
            
            tempArrHR1 = Array(tempArrHR.prefix(50))
            tempArrSPD1 = Array(tempArrSPD.prefix(50))
            tempArrScore1 = Array(tempArrSPD.prefix(50))
            
            if tempArrHR1.count == 0 {return}
            
            ctrArray = Array(1...tempArrSPD1.count)
            myTableView.reloadData()
            
        }
        
    }
    @IBAction func btn_RoundMeReload(_ sender: UIButton) {
        
        print(tempArrHR)
        
        if tempArrHR.count > 0 {
            
            tempArrHR1 = []
            tempArrSPD1 = []
            tempArrScore1 = []
            ctrArray = []
            
            tempArrHR1 = Array(tempArrHR.prefix(50))
            tempArrSPD1 = Array(tempArrSPD.prefix(50))
            tempArrScore1 = Array(tempArrScore.prefix(50))
            
            
            if tempArrHR1.count == 0 {return}
            
            ctrArray = Array(1...tempArrHR1.count)
            myTableView.reloadData()
            
        } 
    }

    @IBOutlet weak var myTableView: UITableView!
    
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
        return tempArrHR1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "id_historyTable") as! TableViewCell1

//        cell.cellTitle1.text = titleArray1[indexPath.row]
//        cell.cellSubTitle1.text = subtitleArray1[indexPath.row]
        
                cell.cellTitle1.text = tempArrScore1[indexPath.row]
                cell.cellSubTitle1.text = String(ctrArray[indexPath.row])
        
        return cell
    }
    
}
