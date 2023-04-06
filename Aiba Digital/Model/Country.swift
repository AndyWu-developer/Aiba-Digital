//
//  Country.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/6.
//

import Foundation

class Country : Hashable { //Row Item in each Section

    var name : String
    var code : String
    var flag : String
    //the follwing code is for using diffableDataSource
    let uid = UUID() //*
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.uid == rhs.uid
    }
    func hash(into hasher: inout Hasher){
        hasher.combine(uid)
    }
    
    init(name: String = "", code: String = "", flag: String = ""){
        self.name = name
        self.code = code
        self.flag = flag
    }
}
