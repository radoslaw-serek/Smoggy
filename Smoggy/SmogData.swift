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
        let airQualityIndex: Double
        let pm1: Double
        let pm10: Double
        let pm25: Double
        let pressure: Double
        let humidity: Double
        let temperature: Double
        let pollutionLevel: Double
    }
}
