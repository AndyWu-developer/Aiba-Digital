//
//  Post.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation

class Post {
    let postID: String = UUID().uuidString
    let userName: String = "Little Johnny"
    let isPinned: Bool = false
    var mediaURLs: [String] = [".mp4"]
    var text: String = "I'm Little Johnny"
    
}



