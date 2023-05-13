//
//  PostHeaderCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

protocol HasMediaProvider{
    var mediaProvider: MediaProviding { get }
}

class PostHeaderViewModel{
    
    struct Input {
        let shouldPinToTop: AnySubscriber<Bool,Never>
    }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    typealias Dependencies = HasPostManager
    private let dependencies: Dependencies
    private let post: Post
    private var subscriptions = Set<AnyCancellable>()
    
    init(post: Post, dependencies: Dependencies){
        self.post = post
        self.dependencies = dependencies
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
        
    }

}

extension PostHeaderViewModel: Hashable, Identifiable {
    static func == (lhs: PostHeaderViewModel, rhs: PostHeaderViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
