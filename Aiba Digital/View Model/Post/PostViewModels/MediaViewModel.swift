//
//  MediaViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/26.
//

import Foundation

class MediaViewModel {
    
    var contentPixelWidth: Int {
        fatalError("this should be overriden")
    }
    
    var contentPixelHeight: Int {
        fatalError("this should be overriden")
    }
    
}

extension MediaViewModel: Hashable, Identifiable {
    
    static func == (lhs: MediaViewModel, rhs: MediaViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
