//
//  PostTextViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

class PostTextViewModel{
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
    typealias Dependencies = HasPostManager
    private var dependencies: Dependencies!
    
    private let post: Post
    
    init(post: Post, dependencies :Dependencies){
        self.post = post
       // self.dependencies = dependencies
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
        
    }
}

extension PostTextViewModel: Hashable, Identifiable{
    static func == (lhs: PostTextViewModel, rhs: PostTextViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

