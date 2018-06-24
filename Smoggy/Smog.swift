//
//  Smog.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

struct Smog: Codable {
    
    var currentMeasurements = CurrentMeasurements()
    
    struct CurrentMeasurements: Codable {
        var airQualityIndex: Double = 0
        var pm1: Double = 0
        var pm10: Double = 0
        var pm25: Double = 0
        var pressure: Double = 0
        var humidity: Double = 0
        var temperature: Double = 0
        var pollutionLevel: Double = 0
    }
}
