//
//  PostActionCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

class PostActionViewModel: FeedViewModel{
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!

    private var subscriptions = Set<AnyCancellable>()
   // typealias Dependencies = HasPostManager 
   // private var dependencies: Dependencies!
    
    private let post: Post
    
    init(post: Post){
        self.post = post
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
