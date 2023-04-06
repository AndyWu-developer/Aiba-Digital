//
//  CountryCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/6.
//

import Foundation

class CountryCellViewModel{
    
    let flag: String
    let labelText: String
    
    var isSelected: Bool {
        country.name == UserDefaults.standard.string(forKey: UserDefaults.Keys.countryName)
    }
    
    private let country: Country
    
    init(country: Country){
        self.country = country
        flag = country.flag
        labelText = "\(country.name) (\(country.code))"
    }
}
