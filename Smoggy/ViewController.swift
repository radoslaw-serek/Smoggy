//
//  ViewController.swift
//  Smoggy
//
//  Created by Radosław Serek on 20.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    let dataService = DataService()
    var smogData: SmogData? {
        didSet {
            configureLabelsColor()
            airQualityIndexLabel.text = "CAQI: \n"+String(Int((smogData?.currentMeasurements.airQualityIndex.rounded())!))
            pm1Label.text = "PM1: \n"+String(Int((smogData?.currentMeasurements.pm1.rounded())!))
            pm25Label.text = "PM2.5: \n"+String(Int((smogData?.currentMeasurements.pm25.rounded())!))
            pm10Label.text = "PM10: \n"+String(Int((smogData?.currentMeasurements.pm10.rounded())!))
            temperatureLabel.text = "Temp: \n"+String(Int((smogData?.currentMeasurements.temperature.rounded())!))+"℃"
            pressureLabel.text = "Pressure: \n"+String(Int((smogData?.currentMeasurements.pressure.rounded())!/100))+"hPa"
            humidityLabel.text = "Humidity: \n"+String(Int((smogData?.currentMeasurements.humidity.rounded())!))+"%"
            getDataActivityIndicatorView.stopAnimating()
        }
    }
    
    private func configureLabelsColor() {
        
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
        configureLabelsColor()
        addressLabel.isHidden = true
    }
    
    private func handleError(_ description: String) {
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: DataServiceDelegate {
    func dataService(_ dataService: DataService, didFetchData smogData: SmogData) {
        self.smogData = smogData
    }
    
    func dataService(_ dataService: DataService, didFailWithErrorDuringDataDownload error: Error) {
        handleError(error.localizedDescription)
    }
    
    func dataService(_ dataService: DataService, didFailWithErrorDuringAddressGeocoding error: Error) {
        addressLabel.text = "Could not retrieve location from given address, please try again"
        addressLabel.isHidden = false
        handleError("Could not retrieve location from given address")
        getDataActivityIndicatorView.stopAnimating()
    }
    
    func dataService(_ dataService: DataService, didFailWithErrorDuringLocationAuthorizationRetrieval failed: Bool) {
        if failed {
            addressLabel.text = "Authorization failed.\nPlease specify desired location for smog data"
            let alert = UIAlertController(title: "Error", message: "Authorization failed \n Please specify desired location for smog data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            addressLabel.isHidden = false
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressLabel.text = "Address: "+textField.text!
        addressLabel.isHidden = false
        if let address = textField.text {
            getDataActivityIndicatorView.startAnimating()
            dataService.getLocationThenFetchData(locationFrom: address)
        }
        textField.resignFirstResponder()
        getDataActivityIndicatorView.stopAnimating()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addressLabel.isHidden = true
    }
}
