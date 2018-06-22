//
//  Location.swift
//  Smoggy
//
//  Created by Radosław Serek on 22.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

struct Location {
    
    
    let point = Point(latitude: 50.079923, longtitude: 20.004323)
//    let rect = Rect(southwestLat: 50.078731, southwestLong: 20.002725, northeastLat: 50.079998, northeastLong: 20.006943)
    
    struct Point {
        let latitude: Double
        let longtitude: Double
    }
    
//    struct Rect {
//        let southwestLat: Double
//        let southwestLong: Double
//        let northeastLat: Double
//        let northeastLong: Double
//    }
}
