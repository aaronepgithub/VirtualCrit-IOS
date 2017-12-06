//
//  Settings.swift
//  xxyy
//
//  Created by aaronep on 11/29/17.
//  Copyright © 2017 aaronep. All rights reserved.
//

import UIKit

class Settings: UITableViewController {
    
    @IBOutlet weak var lbl_AudioToggle: UILabel!
    @IBOutlet weak var lbl_TireSizeCell: UILabel!
    @IBOutlet weak var lbl_NameCell: UILabel!
    
    @IBOutlet weak var lbl_RT_Avg_Duration: UILabel!
    
    
    func callNameActionSheet() {
        let alert = UIAlertController(title: "Enter Name", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Name Input", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            
            print(textField.text as Any)
            if textField.text != nil {
                self.lbl_NameCell.text = textField.text?.uppercased()
            }
            
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
        
    }
    
    func callTireSizeActionSheet() {
            
            // 1
            let optionMenu = UIAlertController(title: nil, message: "Choose Tire Size", preferredStyle: .actionSheet)
        
        let Action700x25 = UIAlertAction(title: "700x25", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x25")
            wheelCircumference = 2105
            self.lbl_TireSizeCell.text = "700X25 TIRE SIZE"
        })
        
        let Action700x26 = UIAlertAction(title: "700x26", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x26")
            wheelCircumference = 2110
            self.lbl_TireSizeCell.text = "700X26 TIRE SIZE"
        })
        
        let Action700x28 = UIAlertAction(title: "700x28", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x28")
            wheelCircumference = 2130
            self.lbl_TireSizeCell.text = "700X28 TIRE SIZE"
        })
        
        let Action700x32 = UIAlertAction(title: "700x32", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Action700x32")
            wheelCircumference = 2155
            self.lbl_TireSizeCell.text = "700X32 TIRE SIZE"
        })
        
            //
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            
            
            // 4
            optionMenu.addAction(Action700x25)
            optionMenu.addAction(Action700x26)
            optionMenu.addAction(Action700x28)
            optionMenu.addAction(Action700x32)
            optionMenu.addAction(cancelAction)
            
            // 5
            self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var lbl_TireSize: UILabel!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Your action here
        
        print(indexPath)
        
        if indexPath.section == 0 && indexPath.row == 1 {
            print("Pressed Name Cell")
            callNameActionSheet()
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            print("Audio Cell")
            
            if lbl_AudioToggle.text == "AUDIO ON" {
                lbl_AudioToggle.text = "AUDIO OFF"
            } else {
                lbl_AudioToggle.text = "AUDIO ON"
            }

        }

        if indexPath.section == 1 && indexPath.row == 0 {
            print("pressed tire size cell")
            callTireSizeActionSheet()
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            print("duration cell")
            print("current seconds for quick avg: \(seconds_for_quick_avg)")
            
            let x = lbl_RT_Avg_Duration.text
            
            if x == "CALCULATION VALUES = 2" {
                lbl_RT_Avg_Duration.text = "CALCULATION VALUES = 1"
                seconds_for_quick_avg = 1
                numofvaluesforarraycalc = 1
            }
            
            if x == "CALCULATION VALUES = 5" {
                lbl_RT_Avg_Duration.text = "CALCULATION VALUES = 3"
                seconds_for_quick_avg = 3
                numofvaluesforarraycalc = 3
            }
            
            if x == "CALCULATION VALUES = 1" {
                lbl_RT_Avg_Duration.text = "CALCULATION VALUES = 5"
                seconds_for_quick_avg = 5
                numofvaluesforarraycalc = 5
            }
            
            if x == "CALCULATION VALUES = 3" {
                lbl_RT_Avg_Duration.text = "CALCULATION VALUES = 2"
                seconds_for_quick_avg = 2
                numofvaluesforarraycalc = 2
            }
            
            
            
            print("updated seconds for quick avg: \(seconds_for_quick_avg)")
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
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
