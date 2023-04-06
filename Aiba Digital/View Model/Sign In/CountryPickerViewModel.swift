//
//  CountryPickerViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/6.
//

import Foundation
import Combine

class CountryPickerViewModel {
    
    struct Input {
        let selectedNumber: AnySubscriber<Int,Never>
    }
    
    struct Output {
        let countryCellViewModels: [CountryCellViewModel]
        let selectedRow: Int
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var countries = [Country]()
    private var subscriptions = Set<AnyCancellable>()
    
    private var selectedRow: Int {
        let countryName = UserDefaults.standard.string(forKey: UserDefaults.Keys.countryName)
        return countries.firstIndex { $0.name == countryName } ?? 0
    }
    
    init() {
        parseData()
        configureInput()
        configureOutput()
    }

    func parseData(){
        var countries = [Country]()
        let s = try! String(contentsOfFile: Bundle.main.path(forResource: "Country Code", ofType: "txt")!)
        s.split(separator: "\n").forEach{
            let info = $0.split(separator: "/").map{String($0)}
            let country = Country(name: info[0], code: info[1], flag: info[2])
            countries.append(country)
        }
        self.countries = countries
    }
    
    
    func configureInput(){
        
        let countryIndexSubject = PassthroughSubject<Int,Never>()
     
        countryIndexSubject
            .map{ [unowned self] index in
                countries[index]
            }.sink{ country in
                UserDefaults.standard.set(country.name,forKey: UserDefaults.Keys.countryName)
                UserDefaults.standard.set(country.code,forKey: UserDefaults.Keys.countryCode)
            }.store(in: &subscriptions)
       
        input = Input(selectedNumber: countryIndexSubject.eraseToAnySubscriber())
    }
    
    func configureOutput(){
        let viewModels = countries.map(CountryCellViewModel.init)
        output = Output(countryCellViewModels: viewModels, selectedRow: selectedRow)
    }
}
