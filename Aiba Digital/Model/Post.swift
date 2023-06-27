//
//  Post.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation
import Combine
import FirebaseFirestoreSwift //for @DocumentID property wrapper


// if you dont want to add required, add final to the class you defined
final class Post: Codable {
    
    @DocumentID var postID: String?
    let userID: String
    var timestamp: Date
    var media: [MediaAsset]
    var text: String
    
    @Published var likeCount: Int
    @Published var replyCount: Int
    
    enum CodingKeys: String, CodingKey{
        case postID
        case userID
        case timestamp
        case media
        case text
        case likeCount
        case replyCount
    }
    
    init(userID: String, media: [MediaAsset], text: String){
        self.userID = userID
        self.text = text
        self.media = media
        timestamp = Date()
        likeCount = 0
        replyCount = 0
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // _id is a property wrapper
        _postID = try container.decode(DocumentID<String>.self, forKey: .postID)
        userID = try container.decode(String.self, forKey: .userID)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        text = try container.decode(String.self, forKey: .text)
        media = try container.decode([MediaAsset].self, forKey: .media)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        replyCount = try container.decode(Int.self, forKey: .replyCount)
    }
  
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userID, forKey: .userID)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(media, forKey: .media)
        try container.encode(text, forKey: .text)
        try container.encode(likeCount, forKey: .likeCount)
        try container.encode(replyCount, forKey: .replyCount)
    }
}





