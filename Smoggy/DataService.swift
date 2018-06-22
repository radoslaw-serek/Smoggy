//
//  DataService.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation


protocol DataServiceDelegate {
    func dataService(_ dataService: DataService, didFetchData smogData: Smog)
    func dataService(_ dataService: DataService, didFailWithError error: Error)
}
class DataService {
    
    private let rootURL = "https://airapi.airly.eu"
    private let apiKey = "xyLjMQ6mafMM8IaxR22Zl4fvaQ2JoYS0"
    private var endpoint = "/v1/mapPoint/measurements?" //Get air quality index and historical data for any point on a map
    private let acceptHeader = "application/json"
    private let dataPersistence = FilePersistence()
    var delegate: DataServiceDelegate?
    private var location = Location()
    private var locationPointString: String {
        return "latitude="+String(location.point.latitude)+"&longtitude="+String(location.point.longtitude)
    }
    private var finalUrl: String {
        return rootURL+endpoint+locationPointString
    }
    
//    private var locationRectString: String {
//        return "southwestLat="+String(location.rect.southwestLat)+"&southwestLong="+String(location.rect.southwestLong)+"&northeastLat="+String(location.rect.northeastLat)+"&northeastLong="+String(location.rect.northeastLong)
//    }
    

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
    
    private func fetchData() {
        let url = URL(string: finalUrl)
        var request = URLRequest(url: url!)
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
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


