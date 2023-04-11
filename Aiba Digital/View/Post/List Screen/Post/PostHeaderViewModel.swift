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
    
    private var subscriptions = Set<AnyCancellable>()
    typealias Dependencies = HasPostManager
    private var dependencies: Dependencies!
    
    init(){
        //self.dependencies = dependencies
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
