//
//  PostViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation
import AVFoundation
import Combine

protocol HasPostManager{
    var postManager: PostManaging { get }
}

class PostViewModel {
 
    struct Input {
        let userEnterScreen: AnySubscriber<Void,Never>
        let userLeaveScreen: AnySubscriber<Void,Never>
    }
    
    struct Output {
      
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    private let dependencies: HasPostManager
    private var subscriptions = Set<AnyCancellable>()
  
    init(dependencies: HasPostManager){
        self.dependencies = dependencies
        configureInputs()
        configureOutputs()
    }
  
    private func configureInputs(){
        let viewAppearSubject = PassthroughSubject<Void,Never>()
        let viewDisappearSubject = PassthroughSubject<Void,Never>()
        
        viewAppearSubject.sink { _ in
         
            let session = AVAudioSession.sharedInstance()
            try? session.setActive(false) //we first deactive our current session
            let options = session.categoryOptions.union(.duckOthers)
            try? session.setCategory(.playback, mode: session.mode,options: options)  //reconfigure
            try? session.setActive(true) // activate
        }.store(in: &subscriptions)
        
        viewDisappearSubject.sink { _ in
         
             let session = AVAudioSession.sharedInstance()
             try? session.setActive(false) //we first deactive our current session
             let options = session.categoryOptions.subtracting(.duckOthers)
             try? session.setCategory(session.category, mode: session.mode,options: options)  //reconfigure
             try? session.setActive(true) // activate
            // self.playFirstVisibleVideo(false)
        }.store(in: &subscriptions)
        
        input = Input(userEnterScreen: viewAppearSubject.eraseToAnySubscriber(),
                      userLeaveScreen: viewDisappearSubject.eraseToAnySubscriber())
    }
    
    private func configureOutputs(){
        
    }
    
    deinit{
        print("PostViewModel deinit")
    }
}
