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
var tempArrHR1 = [String]()
var tempArrSPD1 = [String]()
var tempArrScore1 = [String]()
var ctrArray = [Int]()


class ThirdViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
 
    
    var titleArray1 = ["1", "2", "3", "4", "5", "2", "3", "4", "5"]
    var subtitleArray1 = ["1", "2", "3", "4", "5", "2", "3", "4", "5"]
    
    func getRoundData() {
    
        //print("httpGet Started")
        let todosEndpoint: String = "https://virtualcrit-47b94.firebaseio.com/rounds/" + Settings.dateToday + ".json"
        let url = NSURL(string: todosEndpoint)
        
        //print(1)
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                //print(2)
                //print(jsonObj as Any)
                
                for (key, _) in jsonObj! {
                    //print(3)
                    
                    if let nestedDictionary = jsonObj?[key] as? [String: Any] {
                        //print(4)
                        for(key, _) in nestedDictionary {
                            //print(5)
                            
                            if key == "fb_RND" {
                                let a = nestedDictionary["fb_RND"] as! Double
                                let b = nestedDictionary["fb_timName"] as! String!
                                let c = nestedDictionary["fb_SPD"] as! Double!
                                
                                score_string_array.append(String(describing: a) + " %MAX  " + "\n" + String(describing: b!) + " | " + String(describing: c!) + " MPH")
                            }
                            
                            if key == "fb_SPD" {
                                let d = nestedDictionary["fb_SPD"] as! Double
                                let e = nestedDictionary["fb_timName"] as! String!
                                let f = nestedDictionary["fb_RND"] as! Double!
                                
                                speed_string_array.append(String(describing: d) + " MPH  " + "\n" + String(describing: e!) + " | " + String(describing: f!) + " %MAX")
                            }
                            
                        }
                    }
                }
                //at the end
                
                
                //now sort the string array
                score_string_array.sort { $0 > $1 }
                print("Sorted score array")
                print(score_string_array)
                
                speed_string_array.sort { $0.compare($1, options: .numeric) == .orderedDescending }
                print("Sorted speed array")
                print(speed_string_array)
                
                
                
            }
        }).resume()
        //print(8)
        
    }
    
    @IBAction func btn_totalScore(_ sender: UIButton) {
        
        //get & parse total score data
        
    }
    
    @IBAction func btn_totalSpeed(_ sender: UIButton) {
        
        //get & parse total score data
    }
    
    //use sorted speed array
    @IBAction func btn_roundAllSpeed(_ sender: UIButton) {
        
        if ConnectionCheck.isConnectedToNetwork() {
            getRoundData()
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){
                
                tempArrHR1 = []
                tempArrSPD1 = []
                tempArrScore1 = []
                ctrArray = []
                
                tempArrHR1 = speed_string_array
                tempArrSPD1 = speed_string_array
                tempArrScore1 = speed_string_array
                
                ctrArray = Array(1...tempArrHR1.count)
                self.myTableView.reloadData()
                score_string_array = []
                speed_string_array = []
            }
        }
    }
    

    //use sorted score array
    @IBAction func btn_roundAll(_ sender: UIButton) {
        
        if ConnectionCheck.isConnectedToNetwork() {
            getRoundData()
            let when = DispatchTime.now() + 3
            DispatchQueue.main.asyncAfter(deadline: when){

                tempArrHR1 = []
                tempArrSPD1 = []
                tempArrScore1 = []
                ctrArray = []
                tempArrHR1 = score_string_array
                tempArrSPD1 = score_string_array
                tempArrScore1 = score_string_array
                
                ctrArray = Array(1...tempArrHR1.count)
                self.myTableView.reloadData()
                score_string_array = []
                speed_string_array = []
            }
        
        }
        
    }
    
    @IBAction func btn_SpeedMeReload(_ sender: UIButton) {
        
        print(tempArrSPD)
        
        if tempArrSPD.count > 0 {
            
            tempArrHR1 = []
            tempArrSPD1 = []
            tempArrScore1 = []
            ctrArray = []
            
            tempArrHR1 = tempArrHR
            tempArrSPD1 = tempArrSPD
            tempArrScore1 = tempArrSPD
            ctrArray = Array(1...tempArrSPD.count)
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
            
            tempArrHR1 = tempArrHR
            tempArrSPD1 = tempArrSPD
            tempArrScore1 = tempArrScore
            ctrArray = Array(1...tempArrHR.count)
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
//                    return titleArray1.count
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
