//
//  Persistence.swift
//  Smoggy
//
//  Created by Radosław Serek on 22.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

class FilePersistence {

    private let fileUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.sharingSmogDataWithExtension")?.appendingPathComponent("SmogData.json")
    
    func getData() -> SmogData? {
        let decoder = JSONDecoder()
        if let url = fileUrl, let data = try? Data.init(contentsOf: url), let smogData = try? decoder.decode(SmogData.self, from: data) {
            return smogData
        } else {
            return nil
        }
    }
    
    func storeData(smogData: SmogData) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(smogData), let url = fileUrl {
            do {
                try data.write(to: url)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}

