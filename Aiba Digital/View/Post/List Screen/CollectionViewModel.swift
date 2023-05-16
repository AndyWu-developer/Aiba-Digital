//
//  CollectionViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/8.
//

import Foundation
import Combine

class CollectionViewModel{
    
    struct Input {
        
    }
    
    struct Output {
        let sectionViewModels: AnyPublisher<[[AnyHashable]],Never>
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
  
    private var subscriptions = Set<AnyCancellable>()
    
    init(){
        configureInput()
        configureOutput()
    }
    
    let posts = [Post(),Post()]
    
    private func configureInput(){
      
        
    }
    
    private func configureOutput(){
       let p = Just(posts)
            .map{ $0.map(createViewModels) }
            
            
        output = Output(sectionViewModels: p.eraseToAnyPublisher())
    }
    
    private func createViewModels(with post: Post) -> [AnyHashable] {
        var viewModels = [AnyHashable]()
        
//        let postHeaderViewModel = PostHeaderViewModel(post: <#T##Post#>, dependencies: <#T##PostHeaderViewModel.Dependencies#>)
//        let postMediaViewModel = PostMediaViewModel()
//        let postTextViewModel = PostTextViewModel()
//        let postActionViewModel = PostActionViewModel()
//
        return viewModels
    }
    
    
    
    
    
}

