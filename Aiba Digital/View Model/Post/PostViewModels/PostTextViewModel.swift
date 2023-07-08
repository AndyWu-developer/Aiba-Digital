//
//  PostTextViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

class PostTextViewModel: FeedViewModel{
    
    struct Input { }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
   // typealias Dependencies = HasPostManager
   // private var dependencies: Dependencies!
    var isTextExpanded = false
    private let post: Post
    let postText: String?
    init(post: Post){
        self.post = post
        postText = post.text
       // self.dependencies = dependencies
        super.init()
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
        
    }
}
