//
//  FeedViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/22.
//

import Foundation

class Feed {
    var ID: String = UUID().uuidString
    var header: FeedHeaderViewModel? = FeedHeaderViewModel(post: Post())
    var media: FeedMediaCellViewModel? = FeedMediaCellViewModel()
    var text: FeedTextViewModel? = FeedTextViewModel(post: Post())
    var action: FeedActionViewModel? = FeedActionViewModel(post: Post())
}

class FeedViewModel: Hashable, Identifiable {
    
    static func == (lhs: FeedViewModel, rhs: FeedViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
