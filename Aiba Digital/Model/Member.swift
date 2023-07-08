//
//  User.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/27.
//

import Foundation
import FirebaseFirestoreSwift
//Store the uid from Firebase Auth as the document ID :)
struct Member: Codable {
    
    let id: String
    var fullName: String?
    var displayName: String?
    var email: String?
    var phoneNumber: String?
    var photoURL: URL?
    var joinDate: Date
    
    var rank: Rank
    var identity: Identity
    var address: String?
    
    enum Rank: String, Codable {
        case silver
        case gold
        case platinum
        case diamond
    }
    
    enum Identity: String, Codable {
        case customer
        case staff
    }
    
    init(id: String, displayName: String? = nil, phoneNumber: String?, email: String?, photoURL: URL?){
        self.id = id
        self.displayName = displayName
        self.phoneNumber = phoneNumber
        self.email = email
        self.rank = .silver
        self.identity = .staff
        self.joinDate = Date()
    }
}




