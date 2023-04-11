//
//  PostActionCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

class PostActionViewModel{
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
    typealias Dependencies = HasPostManager 
    private var dependencies: Dependencies!
    
    init(){
      //  self.dependencies = dependencies
        configureInput()
        configureOutput()
    }
    
    private func configureInput(){
        
    }
    
    private func configureOutput(){
        
    }

}

extension PostActionViewModel: Hashable, Identifiable{
    static func == (lhs: PostActionViewModel, rhs: PostActionViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

