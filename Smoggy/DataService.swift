//
//  DataAndLocationService.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation
import CoreLocation


protocol DataServiceDelegate: class {
    func dataService(_ dataService: DataService, didFetchData smogData: SmogData)
    func dataService(_ dataService: DataService, didFailWithErrorDuringDataDownload error: Error)
    func dataService(_ dataService: DataService, didFailWithErrorDuringAddressGeocoding error: Error)
    func dataService(_ dataService: DataService, didFailWithErrorDuringLocationAuthorizationRetrieval failed: Bool)
}

class DataService: NSObject {
    
    private let rootURL = "https://airapi.airly.eu"
    private let apiKey = "xyLjMQ6mafMM8IaxR22Zl4fvaQ2JoYS0"
    private let acceptHeader = "application/json"
    private let endpoint = "/v1/mapPoint/measurements?" //Get air quality index and historical data for any point on a map
    private let dataPersistence = FilePersistence()
    weak var delegate: DataServiceDelegate?
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
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
        if let smogData = try? decoder.decode(SmogData.self, from: data) {
            dataPersistence.storeData(smogData: smogData)
            DispatchQueue.main.async {
                self.delegate?.dataService(self, didFetchData: smogData)
            }
        }
    }
    
    func getLocationThenFetchData(locationFrom address: String) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                self.delegate?.dataService(self, didFailWithErrorDuringAddressGeocoding: error)
            }
            if let location = placemarks?.first?.location {
                self.location = location
            }
        }
    }
    
    func getLocationThenFetchData() {
        if let data = dataPersistence.getData() {
            self.delegate?.dataService(self, didFetchData: data)
        }
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .denied {
            self.delegate?.dataService(self, didFailWithErrorDuringLocationAuthorizationRetrieval: true)
        }
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
        let task = session.dataTask(with: request) { [unowned self] (data, response, error) in
            if let error = error {
                if let smogData = self.dataPersistence.getData(){
                    DispatchQueue.main.async {
                        self.delegate?.dataService(self, didFetchData: smogData)
                    }
                } else {
                    self.delegate?.dataService(self, didFailWithErrorDuringDataDownload: error)
                    print(error.localizedDescription)
                }
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let smogData = self.dataPersistence.getData() {
                    DispatchQueue.main.async {
                        self.delegate?.dataService(self, didFetchData: smogData)
                    }
                }
                return
            }
            if let data = data {
                self.convertDataToJson(data: data)
            }
        }
        task.resume()
    }
}

extension DataService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.location = locations[0]
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.dataService(self, didFailWithErrorDuringAddressGeocoding: error)
    }
    
    
}

