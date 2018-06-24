//
//  DataAndLocationService.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation
import CoreLocation


protocol DataServiceDelegate {
    func dataService(_ dataService: DataAndLocationService, didFetchData smogData: Smog)
    func dataService(_ dataService: DataAndLocationService, didFailWithError error: Error)
}

class DataAndLocationService: NSObject {
    
    private let rootURL = "https://airapi.airly.eu"
    private let apiKey = "xyLjMQ6mafMM8IaxR22Zl4fvaQ2JoYS0"
    private let acceptHeader = "application/json"
    private var endpoint = "/v1/mapPoint/measurements?" //Get air quality index and historical data for any point on a map
    private let dataPersistence = FilePersistence()
    var delegate: DataServiceDelegate?
    private var locationManager = CLLocationManager()
    
//    private let locationService = LocationService()
    private var location = CLLocation() {
        didSet {
            fetchData()
        }
    }
    
    private var locationCoordinateString: String {
        return "latitude="+String(location.coordinate.latitude)+"&longitude="+String(location.coordinate.longitude)
    }
    private var finalUrl: String {
        return rootURL+endpoint+locationCoordinateString
    }

    private func convertDataToJson(data: Data) {
        let decoder = JSONDecoder()
        if let smogData = try? decoder.decode(Smog.self, from: data) {
            dataPersistence.storeData(smogData: smogData)
            DispatchQueue.main.async {
                self.delegate?.dataService(self, didFetchData: smogData)
            }
            print("Smog data stored in file")
        }
    }
    
    func getLocationThenFetchData() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse, CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    private func fetchData() {
        let url = URL(string: finalUrl)
        var request = URLRequest(url: url!)
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue(acceptHeader, forHTTPHeaderField: "Content-Type")
        request.addValue(acceptHeader, forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                if let smogData = self?.dataPersistence.getData(){
                    DispatchQueue.main.async {
                        self?.delegate?.dataService(self!, didFetchData: smogData)
                    }
                    print(error.localizedDescription)
                } else {
                    self?.delegate?.dataService(self!, didFailWithError: error)
                    print(error.localizedDescription)
                }
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let smogData = self?.dataPersistence.getData() {
                    DispatchQueue.main.async {
                        self?.delegate?.dataService(self!, didFetchData: smogData)
                    }
                }
                print(response?.description ?? "Server error")
                return
            }
            if let data = data {
                self?.convertDataToJson(data: data)
            }
        }
        task.resume()
    }
}

extension DataAndLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations[0]
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

