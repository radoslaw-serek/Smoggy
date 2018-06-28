//
//  Smog.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

struct SmogData: Codable {
    
    let currentMeasurements: CurrentMeasurements
    
    struct CurrentMeasurements: Codable {
        var airQualityIndex: Double
        var pm1: Double
        var pm10: Double
        var pm25: Double
        var pressure: Double
        var humidity: Double
        var temperature: Double
        var pollutionLevel: Double
    }
}
