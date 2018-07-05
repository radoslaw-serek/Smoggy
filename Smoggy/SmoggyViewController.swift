//
//  ViewController.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit

class SmoggyViewController: UIViewController {

    let dataService = DataService()
    public var smogData: SmogData? {
        didSet {
            getDataActivityIndicatorView.stopAnimating()
            configureSmogDataLabelsColor()
            configureSmogDataLabels()
        }
    }
    
    
    @IBOutlet weak var airQualityIndexLabel: UILabel!
    @IBOutlet weak var pm1Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var getDataActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getDataActivityIndicatorView.startAnimating()
        dataService.getLocationThenFetchData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addressTextField.delegate = self
        dataService.delegate = self
        configureSmogDataLabelsColor()
        addressLabel.isHidden = true
    }
    
    private func configureSmogDataLabelsColor() {
        
        var smogLabelColor = UIColor.black
        var tempLabelColor = UIColor.black
        if let pm10Data = smogData?.currentMeasurements.pm10 {
            switch pm10Data {
            case 0..<100: smogLabelColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            case 100..<200: smogLabelColor = UIColor.yellow
            case 200..<300: smogLabelColor = UIColor.orange
            case 300...1000: smogLabelColor = UIColor.red
            default: smogLabelColor = UIColor.black
            }
        }
        if let tempData = smogData?.currentMeasurements.temperature {
            switch tempData {
            case -273..<0: tempLabelColor = UIColor.blue
            case 0...273: tempLabelColor = UIColor.red
            default: tempLabelColor = UIColor.black
            }
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
    
    private func configureSmogDataLabels() {
        if smogData != nil {
            airQualityIndexLabel.text = "CAQI: \n"+String(Int((smogData?.currentMeasurements.airQualityIndex.rounded())!))
            pm1Label.text = "PM1: \n"+String(Int((smogData?.currentMeasurements.pm1.rounded())!))
            pm25Label.text = "PM2.5: \n"+String(Int((smogData?.currentMeasurements.pm25.rounded())!))
            pm10Label.text = "PM10: \n"+String(Int((smogData?.currentMeasurements.pm10.rounded())!))
            temperatureLabel.text = "Temp: \n"+String(Int((smogData?.currentMeasurements.temperature.rounded())!))+"℃"
            pressureLabel.text = "Pressure: \n"+String(Int((smogData?.currentMeasurements.pressure.rounded())!/100))+"hPa"
            humidityLabel.text = "Humidity: \n"+String(Int((smogData?.currentMeasurements.humidity.rounded())!))+"%"
        } else {
            airQualityIndexLabel.text = "CAQI: \n?"
            pm1Label.text = "PM1: \n?"
            pm25Label.text = "PM2.5: \n?"
            pm10Label.text = "PM10: \n?"
            temperatureLabel.text = "Temp: \n?"
            pressureLabel.text = "Pressure: \n?"
            humidityLabel.text = "Humidity: \n?"
        }
    }

    
    private func handleError(_ description: String) {
        addressLabel.isHidden = true
        smogData = nil
        getDataActivityIndicatorView.stopAnimating()
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SmoggyViewController: DataServiceDelegate {
    func dataService(_ dataService: DataService, didFetchData smogData: SmogData) {
        self.smogData = smogData
    }
    
    func dataService(_ dataService: DataService, didFailWithErrorDuringDataDownload: Bool) {
        if didFailWithErrorDuringDataDownload {
            handleError("Could not retrieve data for given location\nPlease try again")
        }
    }
    
    func dataService(_ dataService: DataService, didFailWithErrorDuringAddressGeocoding: Bool) {
        if didFailWithErrorDuringAddressGeocoding {
            handleError("Could not retrieve location from given address\nPlease try again")
        }
    }
    
    func dataService(_ dataService: DataService, didFailWithErrorDuringLocationAuthorizationRetrieval: Bool) {
        if didFailWithErrorDuringLocationAuthorizationRetrieval {
            handleError("Authorization failed\nPlease specify desired location for smog data")
        }
    }
}

extension SmoggyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressLabel.text = "Address: "+textField.text!
        addressLabel.isHidden = false
        if let address = textField.text {
            getDataActivityIndicatorView.startAnimating()
            dataService.getLocationThenFetchData(locationFrom: address)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addressLabel.isHidden = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
