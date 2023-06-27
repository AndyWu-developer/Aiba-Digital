//
//  User.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/27.
//

import Foundation
import FirebaseFirestoreSwift

struct AibaUser: Codable {
    @DocumentID var id: String?
    let fullName: String
    let userName: String
    let email: String
    let phoneNumber: String
    let profileImageURL: String
}
