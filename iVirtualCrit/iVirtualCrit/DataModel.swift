//
//  DataModel.swift
//  iVirtualCrit
//
//  Created by aaronep on 1/28/18.
//  Copyright © 2018 aaronep. All rights reserved.
//

import Foundation

struct system {
    static var status: String = "STOPPED"
    static var startTime: Date?
    static var stopTime: Date?
    static var actualElapsedTime: Double?
}

struct geo {
    static var status: String = "ON"
    static var startTime: Date?
    static var elapsedTime: Double = 0
    static var distance: Double = 0
    static var speed: Double?
    static var pace: String = "0"
    static var direction: String = "X"
    static var avgSpeed: Double?
    static var avgPace: String = "0"
}

struct rounds {
    static var geoDistancesPerRound = [Double]()
    static var btDistancesPerRound = [Double]()
}
