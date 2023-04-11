//
//  Post.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation

struct Post {
    let postID: String = UUID().uuidString
    let userName: String = "Little Johnny"
    let isPinned: Bool = false
    var mediaURLs: [String] = [".mp4"]
    var text: String = "I'm Little Johnny"
    
}

struct PostHeaderData {
    let postID: String
    let userName: String
    let isPinned: Bool
}

struct PostMediaData {
    let postID: String
    let mediaURLs: [String]
    let fileExtensions: [String]
}

struct PostTextData {
    let postID: String
    let text: String
}

struct PostActionData: Hashable {
    let postID: String
}



