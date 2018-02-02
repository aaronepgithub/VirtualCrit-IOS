//
//  FireModel.swift
//  iVirtualCrit
//
//  Created by aaronep on 2/2/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import Foundation

class FireModel {
    
    var name: String?
    var roundHR: Double?
    var totalHR: Double?
    var roundSpeed: Double?
    var totalSpeed: Double?
    
    init(name: String?, roundHR: Double?, totalHR: Double?, roundSpeed: Double?, totalSpeed: Double?){
        self.name = name
        self.roundHR = roundHR
        self.totalHR = totalHR
        self.roundSpeed = roundSpeed
        self.totalSpeed = totalSpeed
    }
    
}

