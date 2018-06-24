//
//  ViewController.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    let dataAndLocationService = DataAndLocationService()
    var smogData = Smog() {
        didSet {
            airQualityIndexLabel.text = "CAQI: \n"+String(Int(smogData.currentMeasurements.airQualityIndex.rounded()))
            pm1Label.text = "PM1: \n"+String(Int(smogData.currentMeasurements.pm1.rounded()))
            pm25Label.text = "PM2.5: \n"+String(Int(smogData.currentMeasurements.pm25.rounded()))
            pm10Label.text = "PM10: \n"+String(Int(smogData.currentMeasurements.pm10.rounded()))
            temperatureLabel.text = "Temp: \n"+String(Int(smogData.currentMeasurements.temperature.rounded()))+"℃"
            pressureLabel.text = "Pressure: \n"+String(Int(smogData.currentMeasurements.pressure.rounded()/100))+"hPa"
            humidityLabel.text = "Humidity: \n"+String(Int(smogData.currentMeasurements.humidity.rounded()))+"%"
        }
    }
    
    private func configureLabelsColor() {
        
        var smogLabelColor = UIColor()
        var tempLabelColor = UIColor()
        switch smogData.currentMeasurements.pm10 {
        case 0..<100: smogLabelColor = UIColor.green
        case 100..<200: smogLabelColor = UIColor.yellow
        case 200..<300: smogLabelColor = UIColor.orange
        case 300...1000: smogLabelColor = UIColor.red
        default: smogLabelColor = UIColor.black
        }
        
        switch smogData.currentMeasurements.temperature {
        case -273..<0: tempLabelColor = UIColor.blue
        case 0...273: tempLabelColor = UIColor.red
        default: tempLabelColor = UIColor.black
        }

        setLabelsColor(with: (smogLabelColor,tempLabelColor))
    }
    
    private func setLabelsColor(with labelColors: (smogLabelColor: UIColor,tempLabelColor: UIColor)) {
        airQualityIndexLabel.textColor = labelColors.smogLabelColor
        pm1Label.textColor = labelColors.smogLabelColor
        pm10Label.textColor = labelColors.smogLabelColor
        pm25Label.textColor = labelColors.smogLabelColor
        temperatureLabel.textColor = labelColors.tempLabelColor
    }
    
    @IBOutlet weak var airQualityIndexLabel: UILabel!
    @IBOutlet weak var pm1Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataAndLocationService.getLocationThenFetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataAndLocationService.delegate = self
        configureLabelsColor()
    }
    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: DataServiceDelegate {
    func dataService(_ dataService: DataAndLocationService, didFetchData smogData: Smog) {
        self.smogData = smogData
    }
    
    func dataService(_ dataService: DataAndLocationService, didFailWithError error: Error) {
        handleError(error)
    }
}
