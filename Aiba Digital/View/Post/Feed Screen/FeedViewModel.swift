//
//  FeedViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/22.
//

import Foundation

class PostSectionViewModel {
    let ID: String
    var header: PostHeaderViewModel?
    var media: PostMediaViewModel?
    var text: PostTextViewModel?
    var action: PostActionViewModel?
    let post: Post
    
    init(post: Post){
        self.post = post
        self.ID = post.id!
        header = PostHeaderViewModel(post: post)
        media = PostMediaViewModel(post: post)
        text = PostTextViewModel(post: post)
        action = PostActionViewModel(post: post)
    }
    
    deinit {
        print("PostSectionViewModel deinit")
    }
   
}

class FeedViewModel: Hashable, Identifiable {
    
    static func == (lhs: FeedViewModel, rhs: FeedViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
