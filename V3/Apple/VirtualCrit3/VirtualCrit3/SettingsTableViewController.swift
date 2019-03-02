//
//  SettingsTableViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 3/1/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath)  indexPath selected")
        
        switch indexPath.row {
        case 1:
            print("case 1")
            
        case 2:
            print("case 2")
            
        default:
            print("default")
         
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
            

}
