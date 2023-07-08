//
//  PostListViewModel.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/27.
//

import Foundation
import Combine

class PostFeedViewModel {
    
    typealias PostID = String
    
    struct Input {
        let loadLatestPosts: AnySubscriber<Void,Never>
        let loadMorePosts: AnySubscriber<Void,Never>
        let createPost: AnySubscriber<Void,Never>
        let deletePostID: AnySubscriber<PostID,Never>
    }
    
    struct Output {
        let latestPosts: AnyPublisher<Result<[PostSectionViewModel],Error>,Never>
        let oldPosts: AnyPublisher<Result<[PostSectionViewModel],Error>,Never>
    }

    var didRequestCreateNewPost: (() -> Void)?
    var didSelectPost: ((Post, Int) -> Void)?
    var didDeletePost: ((Post, Int) -> Void)?
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    private var posts: [Post] = []
    private var subscriptions = Set<AnyCancellable>()
    private let loadMoreSubject = PassthroughSubject<Void,Never>()
    private let loadLatestSubject = PassthroughSubject<Void,Never>()
    private let postManager: PostManaging
    private let numberOfLatestPostsToLoad = 5
    private let numberOfMorePostsToLoad = 10
    
    deinit{
        print("PostFeedViewModel deinit")
    }
    
    init(postManager: PostManaging = PostManager()){
        self.postManager = postManager
        configureInputs()
        configureOutputs()
    }
    
    private func configureInputs(){
        
        let createNewPostSubject = PassthroughSubject<Void, Never>()
        let deletePostSubject = PassthroughSubject<PostID, Never>()
        
        createNewPostSubject
            .sink { [unowned self] in
                didRequestCreateNewPost?()
            }
            .store(in: &subscriptions)
        
        deletePostSubject
            .sink{ [unowned self] postID in
                let post = posts.first{ $0.id == postID }!
                try! postManager.deletePost(post)
                posts.removeAll{$0.id == postID}
            }
            .store(in: &subscriptions)
        
        input = Input(loadLatestPosts: loadLatestSubject.eraseToAnySubscriber(),
                      loadMorePosts: loadMoreSubject.eraseToAnySubscriber(),
                      createPost: createNewPostSubject.eraseToAnySubscriber(),
                      deletePostID: deletePostSubject.eraseToAnySubscriber())
    }
    
    private func configureOutputs(){
        
        let latestViewModelPubisher = loadLatestSubject
            .map{ [unowned self] _ -> AnyPublisher<Result<[PostSectionViewModel],Error>, Never> in
                fetchLatestPosts(limit: numberOfLatestPostsToLoad)
                    .map{ [unowned self] posts in
                        self.posts = posts
                        let sectionModels = posts.map(PostSectionViewModel.init)
                        sectionModels.forEach{ [unowned self] in $0.media?.delegate = self }
                        return Result<[PostSectionViewModel],Error>.success(sectionModels)
                    }
                    .catch{ error in
                        let result = Result<[PostSectionViewModel], Error>.failure(error)
                        return Just(result)
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
        
        
        let moreViewModelPublisher = loadMoreSubject
            .map{ [unowned self] _ -> AnyPublisher<Result<[PostSectionViewModel],Error>, Never> in
                fetchMorePosts(limit: numberOfMorePostsToLoad)
                    .map{ [unowned self] posts in
                        self.posts += posts
                        let sectionModels = posts.map(PostSectionViewModel.init)
                        sectionModels.forEach{ [unowned self] in $0.media?.delegate = self }
                        return Result<[PostSectionViewModel],Error>.success(sectionModels)
                    }
                    .catch{ error in
                        let result = Result<[PostSectionViewModel], Error>.failure(error)
                        return Just(result)
                    }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
        
        output = Output(latestPosts: latestViewModelPubisher.eraseToAnyPublisher(),
                         oldPosts: moreViewModelPublisher.eraseToAnyPublisher())
    }
    
    
    private func fetchLatestPosts(limit: Int) -> AnyPublisher<[Post],Error> {
        Deferred{
            Future{ promise in
                Task{
                    do{
                        let posts = try await self.postManager.fetchPostsByTimeline(after: nil, limit: limit)
                        promise(.success(posts))
                    }catch{
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchMorePosts(limit: Int) -> AnyPublisher<[Post],Error> {
        Deferred{
            Future{ promise in
                Task{
                    do {
                        let posts = try await self.postManager.fetchPostsByTimeline(after: self.posts.last, limit: limit)
                        promise(.success(posts))
                    }catch{
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension PostFeedViewModel: PostMediaViewModelDelegate{
    
    func postMediaViewModel(_ postMediaViewModel: PostMediaViewModel, didSelectedItemAt index: Int) {
//        print("seleted \(index)")
//        if let post = postViewModels.first(where: { $0.media == postMediaViewModel})?.post{
//            didSelectPost?(post,index)
//        }else{
//            print("cant find post")
//        }
    }
}
