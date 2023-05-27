//
//  PostActionCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

class FeedActionViewModel: FeedViewModel{
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    private(set) var postID: String
    private var subscriptions = Set<AnyCancellable>()
    typealias Dependencies = HasPostManager 
   // private var dependencies: Dependencies!
    
    private let post: Post
    
    init(post: Post){
        self.post = post
        postID = UUID().uuidString
      //  self.dependencies = dependencies
        super.init()
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
        
    }

}
