//
//  PostManager.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import Combine
import FirebaseFirestoreSwift

protocol PostManaging {
    func fetchLatestPosts(limit: Int) -> AnyPublisher<[Post],Error>
    func fetchMorePosts(limit: Int) -> AnyPublisher<[Post],Error>
    func addNewPost(_ post: Post) throws
}


class PostManager: PostManaging {
    
    let db = Firestore.firestore()
    // MARK: - Firebase FireStore References
    lazy var postsCollRef = db.collection("posts")
    lazy var mediaCollRef = db.collection("media")

    // MARK: - Firebase Storage Reference
    let mediaStorageRef = Storage.storage().reference().child("media")
    
    lazy var currentQuery = db.collection("posts")
                        .order(by: "post", descending: false)
                        .limit(to: 10)
    var lastSnapshot : QueryDocumentSnapshot?
    
    
    //MARK: - Fetch Comment

    func fetchLatestPosts(limit: Int) -> AnyPublisher<[Post],Error> {
        Deferred {
            Future{ promise in
                self.postsCollRef.order(by: "timestamp",descending: true).limit(to: limit).getDocuments { querySnapshot, error in
                    if let error = error{
                        print(error)
                        promise(.failure(error))
                    }else{
                        self.lastSnapshot = querySnapshot!.documents.last
                        let posts = querySnapshot!.documents.compactMap{ queryDocumentSnapshot in
                            let result = Result{ try queryDocumentSnapshot.data(as: Post.self) }
                            switch result{
                            case .success(let post):
                                return post
                            case .failure(let error):
                                print(error)
                                return nil
                            }
                        }
                        promise(.success(posts))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchMorePosts(limit: Int) -> AnyPublisher<[Post],Error> {
       
        Deferred {
            Future{ promise in
                guard self.lastSnapshot != nil else {
                    // The collection is empty
                    print("collection empty")
                    promise(.success([]))
                    return
                }
               
                self.postsCollRef
                    .order(by: "timestamp",descending: true)
                    .start(afterDocument: self.lastSnapshot!)
                    .limit(to: limit)
                    .getDocuments { querySnapshot, error in
                        if let error = error{
                            print(error)
                            promise(.failure(error))
                        }else{
                            self.lastSnapshot = querySnapshot!.documents.last
                            let posts = querySnapshot!.documents.compactMap{ queryDocumentSnapshot in
                                let result = Result{ try queryDocumentSnapshot.data(as: Post.self) }
                                switch result{
                                case .success(let post):
                                    return post
                                case .failure(let error):
                                    print(error)
                                    return nil
                                }
                            }
                            promise(.success(posts))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }
    
    
    func addNewPost(_ post: Post) throws {
        let collectionRef = self.db.collection("posts")
        let newDocReference = try collectionRef.addDocument(from: post)
    }
    
    
}


