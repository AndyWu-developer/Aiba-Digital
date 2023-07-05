//
//  PostHeaderCellViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/4/7.
//

import Foundation
import Combine

//protocol HasMediaProvider{
//    var mediaProvider: MediaProviding { get }
//}


class PostHeaderViewModel: FeedViewModel{
    
    deinit {
        print("PostHeaderViewModel")
    }
    struct Input {
        let delete: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let date: String
        let title: String
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    let post: Post
  //  typealias Dependencies = HasPostManager
   // private let dependencies: Dependencies
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
        let postDate : String = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "MM/dd HH:mm"
            return dateFormatter.string(from: post.timestamp)
        }()
        output = Output(date: postDate, title: "黃志銘-艾巴數位/瘋好殼" )
    }

}

