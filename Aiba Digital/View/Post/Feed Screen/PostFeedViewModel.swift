//
//  PostListViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/27.
//

import Foundation
import Combine

class PostFeedViewModel {
    
    struct Input {
        let createNewPost: AnySubscriber<Void,Never>
        // let delete: AnySubscriber<[MediaCellViewModel],Error>
        let loadMorePosts: AnySubscriber<Void,Never>
        // let loadLatestPosts: AnySubscriber<Void,Never>
    }
    
    struct Output {
        let postViewModels: AnyPublisher<[PostSectionViewModel],Never>
    }

    
    var didRequestCreateNewPost: (() -> Void)?
    var didSelectPost: ((Post, Int) -> Void)?
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var subscriptions = Set<AnyCancellable>()
    private let postManager: PostManaging = PostManager()
    let fetchNew = true
    
    private let createNewPostSubject = PassthroughSubject<Void,Never>()

    @Published private var postViewModels: [PostSectionViewModel] = []
    
    init(){
        let loadMoreSubject = PassthroughSubject<Void,Never>()
        
        loadMoreSubject
            .setFailureType(to: Error.self)
            .flatMap { [weak self] b -> AnyPublisher<[Post], Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.postManager.fetchMorePosts(limit: 5)
            }
            .map{ $0.map(PostSectionViewModel.init) }
            .sink(receiveCompletion: {_ in }) { sectionViewModels in
                self.postViewModels = sectionViewModels
            }.store(in: &subscriptions)
        
        Just(fetchNew)
            .setFailureType(to: Error.self)
            .flatMap { [weak self] b -> AnyPublisher<[Post], Error> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                return self.postManager.fetchLatestPosts(limit: 10)
            }
            .map{ $0.map(PostSectionViewModel.init) }
            .sink(receiveCompletion: {_ in }) { sectionViewModels in
                sectionViewModels.forEach {  $0.media?.delegate = self }
                self.postViewModels = sectionViewModels
            }.store(in: &subscriptions)
           
        
        createNewPostSubject
            .sink { [unowned self] in
                self.didRequestCreateNewPost?()
            }
            .store(in: &subscriptions)
        
        input = Input(createNewPost: createNewPostSubject.eraseToAnySubscriber(),
                      loadMorePosts: loadMoreSubject.eraseToAnySubscriber())
        output = Output(postViewModels: $postViewModels.eraseToAnyPublisher())
    }
    
    
}

extension PostFeedViewModel: PostMediaViewModelDelegate{
    
    func postMediaViewModel(_ postMediaViewModel: PostMediaViewModel, didSelectedItemAt index: Int) {
        print("seleted \(index)")
        if let post = postViewModels.first(where: { $0.media == postMediaViewModel})?.post{
            didSelectPost?(post,index)
        }else{
            print("cant find post")
        }
    
    }
}
