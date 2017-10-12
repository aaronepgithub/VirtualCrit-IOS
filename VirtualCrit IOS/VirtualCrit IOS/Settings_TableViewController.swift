//
//  Settings_TableViewController.swift
//  VirtualCrit IOS
//
//  Created by aaronep on 10/11/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

var firstTimeVistToSettingsTable: Bool = true

class Settings_TableViewController: UITableViewController {

    @IBAction func textField(_ sender: AnyObject) {
        self.view.endEditing(true);
        //print(outlet_riderName.text ?? "Tim")
        let x = outlet_riderName.text ?? "Tim"
        //print(x)
        Settings.riderName = x
        print("settings rider \(Settings.riderName)")
        
    }
    
    @IBAction func textField_Distance(_ sender: AnyObject) {
        self.view.endEditing(true);
        
        let x = outlet_distance.text ?? "5"
        Pacer.target_distance = Double(x) ?? 5.0
        print("pacer avg. dst \(x)")
        
    }
    
    @IBAction func textField_Speed(_ sender: AnyObject) {
        self.view.endEditing(true);
        
        let x = outlet_speed.text ?? "15"
        Pacer.target_avg_speed = Double(x) ?? 15.0
        print("pacer avg. spd \(x)")

        
    }
    
    
    @IBOutlet weak var outlet_riderName: UITextField!
    @IBOutlet weak var outlet_distance: UITextField!
    @IBOutlet weak var outlet_speed: UITextField!
    
    
    @IBOutlet weak var lbl_distance: UILabel!
    @IBOutlet weak var lbl_speed: UILabel!
    
    @IBOutlet weak var lbl_tireSize: UILabel!
    @IBOutlet weak var slider_tireSize: UISlider!
    @IBAction func action_tireSize(_ sender: UISlider) {
        var y = 2115
        var z = 25
        let x = Int(slider_tireSize.value)
        
        switch x {
        case 1: y = 2096; z = 23 //23
        case 2: y = 2115; z = 25 //25
        case 3: y = 2136; z = 28 //28
        case 4: y = 2146; z = 30 //30
        case 5: y = 2155; z = 32 //32
        case 6: y = 2220; z = 40 //32
        default: y = 2115; z = 25
        }
        
        lbl_tireSize.text = "Tire Size: 700X\(z)"
        Device.wheelCircumference = Double(y)
        //print(x,y,z)
    }
    
    @IBOutlet weak var lbl_maxHR: UILabel!
    @IBOutlet weak var slider_maxHR: UISlider!
    @IBAction func action_maxHR(_ sender: UISlider) {
        var y = 185
        let x = Int(slider_maxHR.value)
        
        switch x {
        case 1: y = 180
        case 2: y = 185
        case 3: y = 190
        case 4: y = 200
        case 5: y = 205
        case 6: y = 210
        default: y = 185
        }
        
        lbl_maxHR.text = "MAX HR: \(y) BPM"
        Device.maxHR = Double(y)
        //print(x,y,z)
    }
    
    
    
    @IBOutlet weak var switch_audio: UISwitch!
    @IBAction func action_audio(_ sender: UISwitch) {
        //var x = true
        let x = switch_audio.isOn
        //print(x)
        Settings.enableAudio = x
    }
    
    
    

    
    
    
    @IBAction func btn_lapReset(_ sender: UIButton) {
        
        Lap_PublicVars.startTime = NSDate()
        Lap_PublicVars.crank_revs = 0
        Lap_PublicVars.wheel_revs = 0
        Lap_PublicVars.distance = 0
        Lap_PublicVars.arr_heartrate = []
        
        Device.idle_time = 0
        Device.total_ble_seconds = 0
        
    }
    
    
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

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

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

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
