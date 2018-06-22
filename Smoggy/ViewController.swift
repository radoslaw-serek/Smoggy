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
    var smogData = Smog() {
        didSet {
            smogPM10Label.text = String(smogData.airQualityIndex)
        }
    }
    
    @IBOutlet weak var smogPM10Label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataService.delegate = self
    }


    
    private func handleError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension ViewController: DataServiceDelegate {
    func dataService(_ dataService: DataService, didFetchData smogData: Smog) {
        self.smogData = smogData
    }
    
    func dataService(_ dataService: DataService, didFailWithError error: Error) {
        handleError(error)
    }
    
    
}

