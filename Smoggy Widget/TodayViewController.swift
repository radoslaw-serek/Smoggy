//
//  TodayViewController.swift
//  Smoggy Widget
//
//  Created by Radosław Serek on 04.07.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    private var smogData: SmogData? {
        didSet {
            if smogData == nil {
                presentNoDataAlert("No data to present\nPlease run Smoggy app first")
            }
            caqiLabel.isHidden = false
            pm10Label.isHidden = false
            tempLabel.isHidden = false
            configureSmogDataLabelsColor()
            configureSmogDataLabels()
        }
    }
    private let dataService = DataService()
    
    @IBOutlet weak var caqiLabel: UILabel!
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        smogData = dataService.getSmogDataFromPersistence()
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
        caqiLabel.textColor = labelColors.smogLabelColor
        pm10Label.textColor = labelColors.smogLabelColor
        tempLabel.textColor = labelColors.tempLabelColor
    }
    
    private func configureSmogDataLabels() {
        if smogData != nil {
            caqiLabel.text = "CAQI:\n"+String(Int((smogData?.currentMeasurements.airQualityIndex.rounded())!))
            pm10Label.text = "PM10:\n"+String(Int((smogData?.currentMeasurements.pm10.rounded())!))
            tempLabel.text = "Temp:\n"+String(Int((smogData?.currentMeasurements.temperature.rounded())!))+"℃"
        } else {
            caqiLabel.text = "CAQI:\n?"
            pm10Label.text = "PM10:\n?"
            tempLabel.text = "Temp:\n?"
        }
    }
    
    private func presentNoDataAlert(_ description: String) {
        caqiLabel.isHidden = true
        pm10Label.isHidden = true
        tempLabel.isHidden = true
 
        let newView = UIView()
        newView.backgroundColor = UIColor.gray
        view.addSubview(newView)
        
        newView.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = newView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = newView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        let widthConstraint = newView.widthAnchor.constraint(equalToConstant: view.frame.size.width)
        let heightConstraint = newView.heightAnchor.constraint(equalToConstant: view.frame.size.height)
        view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])

        let alertLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: view.frame.size))
        alertLabel.text = description
        alertLabel.textAlignment = .center
        alertLabel.numberOfLines = 0
        alertLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        alertLabel.adjustsFontSizeToFitWidth = true
        alertLabel.textColor = UIColor.black
        newView.addSubview(alertLabel)
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
