//
//  UserDefaults Extension.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/8.
//

import Foundation

extension UserDefaults {
    
    enum Keys {
        static let countryName = "countryName"
        static let countryCode = "countryCode"
    }
    
    @objc dynamic var countryName: String? {
        return string(forKey: Keys.countryName)
    }
    
    @objc dynamic var countryCode: String? {
        return string(forKey: Keys.countryCode)
    }
}
