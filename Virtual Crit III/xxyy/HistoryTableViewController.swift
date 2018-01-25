//
//  HistoryTableViewController.swift
//  xxyy
//
//  Created by aaronep on 1/25/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    @IBOutlet weak var lbl_SPD: UILabel!
    @IBOutlet weak var lbl_GEO: UILabel!
    
    @IBAction func btn_Dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func update1() {
        //print("update")
        if round.speeds.count > 0  {
            var s = round.speeds.count
            var a = 0
            if s == 0 {
                return
                
            } else {
                let text1 = "ROUND COMPLETE \n  SPD   CAD   HRT  GEO  SPD \n "
                var text2 = ""
                while s > 0 && a < 50 {
                    text2 += " \(stringer2(myIn: round.speeds[s-1]))  "
                    text2 += " \(stringer1(myIn: round.cadences[s-1]))  "
                    text2 +=  "\(stringer1(myIn: round.heartrates[s-1]))  "
                    text2 +=  "\(stringer1(myIn: round.geoSpeeds[s-1]))  "
                    text2 += "\n"
                    s = s - 1
                    a = a + 1
                }
                //self.self.new30point(titleString: "\(text1) \n\(text2)")
                self.lbl_SPD.text = "\(text1) \n\(text2)"
                
            }
        }
        if gpsEnabled == true && round.geoSpeeds.count > 0 {
            var s = round.geoSpeeds.count
            var a = 0
            if s == 0 {
                return
            } else {
                let text1 = "ROUND SPEEDS/PACE (GEO) \n"
                var text2 = ""
                while s > 0 && a < 50 {
                    text2 += "\(stringer2(myIn: round.geoSpeeds[s-1]))  \(calcMinPerMile(mph: round.geoSpeeds[s-1])) "
                    text2 += "\n"
                    s = s - 1
                    a = a + 1
                }
                //self.self.new30point(titleString: "\(text1) \n\(text2)")
                self.lbl_GEO.text = "\(text1) \n\(text2)"
            }
        }
    
    }
    @objc func updateR() {
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when){
            if round.speeds.count > 0  {
                var s = round.speeds.count
                var a = 0
                if s == 0 {
                    return
                    
                } else {
                    let text1 = "ROUND COMPLETE \n  SPD   CAD   HRT  GEO  SPD \n "
                    var text2 = ""
                    while s > 0 && a < 50 {
                        text2 += " \(stringer2(myIn: round.speeds[s-1]))  "
                        text2 += " \(stringer1(myIn: round.cadences[s-1]))  "
                        text2 +=  "\(stringer1(myIn: round.heartrates[s-1]))  "
                        text2 +=  "\(stringer1(myIn: round.geoSpeeds[s-1]))  "
                        text2 += "\n"
                        s = s - 1
                        a = a + 1
                    }
                    //self.self.new30point(titleString: "\(text1) \n\(text2)")
                    self.lbl_SPD.text = "\(text1) \n\(text2)"
                    
                }
            }
            if gpsEnabled == true && round.geoSpeeds.count > 0 {
                var s = round.geoSpeeds.count
                var a = 0
                if s == 0 {
                    return
                } else {
                    let text1 = "ROUND SPEEDS/PACE (GEO) \n"
                    var text2 = ""
                    while s > 0 && a < 50 {
                        text2 += "\(stringer2(myIn: round.geoSpeeds[s-1]))  \(calcMinPerMile(mph: round.geoSpeeds[s-1])) "
                        text2 += "\n"
                        s = s - 1
                        a = a + 1
                    }
                    //self.self.new30point(titleString: "\(text1) \n\(text2)")
                    self.lbl_GEO.text = "\(text1) \n\(text2)"
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateR), name: Notification.Name("newRound"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(update1), name: Notification.Name("update"), object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
