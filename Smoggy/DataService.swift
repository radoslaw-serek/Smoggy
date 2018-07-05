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
    func dataService(_ dataService: DataService, didFailWithErrorDuringDataDownload: Bool)
    func dataService(_ dataService: DataService, didFailWithErrorDuringAddressGeocoding: Bool)
    func dataService(_ dataService: DataService, didFailWithErrorDuringLocationAuthorizationRetrieval: Bool)
}

class DataService: NSObject {
    
    private let apiKey = "xyLjMQ6mafMM8IaxR22Zl4fvaQ2JoYS0"
    private let acceptHeader = "application/json"
    private let dataPersistence = FilePersistence()
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var location = CLLocation() {
        didSet {
            if location == oldValue, let data = dataPersistence.getData() {
                delegate?.dataService(self, didFetchData: data)
            } else {
                fetchData()
            }
        }
    }
    weak var delegate: DataServiceDelegate?
    
    private func composeUrlForLocation() -> URL? {
        let rootURL = "https://airapi.airly.eu"
        let endpoint = "/v1/mapPoint/measurements?" //Get air quality index and historical data for any point on a map
        let locationString = "latitude="+String(location.coordinate.latitude)+"&longitude="+String(location.coordinate.longitude)
        return URL(string: rootURL+endpoint+locationString)
    }

    private func convertDataToJson(data: Data) {
        let decoder = JSONDecoder()
        if let smogData = try? decoder.decode(SmogData.self, from: data) {
            dataPersistence.storeData(smogData: smogData)
            DispatchQueue.main.async {
                self.delegate?.dataService(self, didFetchData: smogData)
            }
        } else {
            DispatchQueue.main.async {
                self.delegate?.dataService(self, didFailWithErrorDuringDataDownload: true)
            }
        }
    }
    
    public func getSmogDataFromPersistence() -> SmogData? {
        return dataPersistence.getData()
    }
    
    func getLocationThenFetchData(locationFrom address: String) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                self.delegate?.dataService(self, didFailWithErrorDuringAddressGeocoding: true)
            }
            guard let location = placemarks?.first?.location else {
                self.delegate?.dataService(self, didFailWithErrorDuringAddressGeocoding: true)
                return
            }
            self.location = location
        }
    }
    
    func getLocationThenFetchData() {
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
        guard let url = composeUrlForLocation() else {return}
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue(acceptHeader, forHTTPHeaderField: "Content-Type")
        request.addValue(acceptHeader, forHTTPHeaderField: "Accept")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [unowned self] (data, response, error) in
            if error != nil {
                if let smogData = self.dataPersistence.getData(){
                    DispatchQueue.main.async {
                        self.delegate?.dataService(self, didFetchData: smogData)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.dataService(self, didFailWithErrorDuringDataDownload: true)
                    }
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
        self.delegate?.dataService(self, didFailWithErrorDuringAddressGeocoding: true)
    }
    
    
}

