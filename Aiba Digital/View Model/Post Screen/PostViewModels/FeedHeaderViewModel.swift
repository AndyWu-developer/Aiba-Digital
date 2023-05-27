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

class FeedHeaderViewModel: FeedViewModel{
    
    struct Input {
        let shouldPinToTop: AnySubscriber<Bool,Never>
    }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
  //  typealias Dependencies = HasPostManager
   // private let dependencies: Dependencies
    private let post: Post
    private var subscriptions = Set<AnyCancellable>()
    
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

