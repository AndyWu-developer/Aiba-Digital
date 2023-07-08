//
//  Post.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation
import FirebaseFirestoreSwift //for @DocumentID property wrapper
import Combine

// if you dont want to add required, add final to the class you defined
final class Post: Codable {
    
    @DocumentID var id: String?
    let user: String
    var timestamp: Date
    var text: String?
    var media: [MediaAsset]
    var productURL: URL?
    
    @Published var likedUsers: [String]
    @Published var replyCount: Int
    
    enum CodingKeys: String, CodingKey{
        case id
        case user
        case timestamp
        case media
        case text
        case likeCount
        case replyCount
        case likedUsers
        case productURL
    }
    
    init(userID: String, media: [MediaAsset], text: String, productURL: URL? = nil){
        self.user = userID
        self.text = text
        self.media = media
        self.productURL = productURL
        timestamp = Date()
        replyCount = 0
        likedUsers = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // _id is a property wrapper
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        user = try container.decode(String.self, forKey: .user)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        text = try? container.decode(String.self, forKey: .text)
        media = try container.decode([MediaAsset].self, forKey: .media)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
        productURL = try? container.decode(URL.self, forKey: .productURL)
        likedUsers = try container.decode([String].self, forKey: .likedUsers)
    }
  
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(media, forKey: .media)
        try container.encode(text, forKey: .text)
        try container.encode(replyCount, forKey: .replyCount)
        try container.encode(productURL, forKey: .productURL)
        try container.encode(likedUsers, forKey: .likedUsers)
    }
}





