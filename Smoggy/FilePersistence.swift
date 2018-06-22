//
//  Persistence.swift
//  Smoggy
//
//  Created by Radosław Serek on 22.06.2018.
//  Copyright © 2018 Radosław Serek. All rights reserved.
//

import Foundation

class FilePersistence {

    private let fileName = "SmogData.swift"
    
    private var fileUrl: URL? {
        let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dir?.appendingPathComponent(fileName)
    }
    
    func getData() -> Smog {
        let decoder = JSONDecoder()
        if let url = fileUrl, let data = try? Data.init(contentsOf: url), let smogData = try? decoder.decode(Smog.self, from: data) {
            return smogData
        } else {
            return Smog()
        }
    }
    
    func storeData(smogData: Smog) {
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
