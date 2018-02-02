//
//  Results_VC.swift
//  iVirtualCrit
//
//  Created by aaronep on 1/31/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import UIKit

class Results_VC: UITableViewController {

    @IBOutlet var outResults: UITableView!
    
    func disMe() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if arrResults.count == 0 {
            let when = DispatchTime.now() + 10
            DispatchQueue.main.asyncAfter(deadline: when){
                self.disMe()
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ID1", for: indexPath)
        
        cell.textLabel?.text = "\(arrResults[indexPath.row])"
        cell.detailTextLabel?.text = "\(arrResultsDetails[indexPath.row])"
        
        
        return cell
        
        
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    

}
