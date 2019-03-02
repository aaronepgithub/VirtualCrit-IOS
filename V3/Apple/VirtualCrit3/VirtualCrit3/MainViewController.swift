//
//  MainViewController.swift
//  VirtualCrit3
//
//  Created by Aaron Epstein on 2/24/19.
//  Copyright © 2019 Aaron Epstein. All rights reserved.
//

import UIKit

import Mapbox

class MainViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet weak var mapViewMessageBar: UILabel!
    
    //var mapView: MGLMapView!
    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //mapView = MGLMapView(frame: view.bounds)
        //mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //view.addSubview(mapView)
        
        // Set the map view's delegate
        mapView.delegate = self
        
        // Allow the map to display the user's location
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
