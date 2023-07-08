//
//  Media.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/29.
//

import Foundation

struct MediaAsset: Codable {
    let type: MediaType
    let dimensions: MediaDimensions
    let url: URL
}

extension MediaAsset {
    
    enum MediaType: String, Codable {
        case photo
        case video
        case gif
    }
    
    struct MediaDimensions: Codable {
        let width: Int
        let height: Int
    }
    
}
