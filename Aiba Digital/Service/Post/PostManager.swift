//
//  PostManager.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

protocol PostManaging {
    func fetchLatestPosts(limit: Int) -> AnyPublisher<[Post],Error>
    func fetchMorePosts(after post: Post, limit: Int) -> AnyPublisher<[Post],Error>
    func addNewPost(_ post: Post) throws
    func deletePost(_ post: Post) throws
    func fetchPostsByTimeline(after post: Post?, limit: Int) async throws -> [Post]
}

class PostManager: PostManaging {
    
    enum PostManagerError: Error{
        case deletionFromFireStoreFailed
        case deletionFromBunnyFailed
        case invalidURL
        case cannotFetchDocument
    }
    
    // MARK: - Firebase FireStore References
    private let db = Firestore.firestore()
    private lazy var postCollRef = db.collection("posts")
    private lazy var timelineQuery = postCollRef.order(by: "timestamp",descending: true)
    

    var lastPrevDocument : QueryDocumentSnapshot?
    
    
    //MARK: - Fetch Comment
   

    func fetchMorePosts(after post: Post, limit: Int) -> AnyPublisher<[Post],Error> {
      
        Deferred {
            Future{ promise in
                guard self.lastPrevDocument != nil else {
                    // The collection is empty
                    print("collection empty")
                    promise(.success([]))
                    return
                }
                
                self.postCollRef
                    .order(by: "timestamp",descending: true)
                    .start(afterDocument: self.lastPrevDocument!)
                    .limit(to: limit)
                    .getDocuments { querySnapshot, error in
                        if let error = error{
                            print(error)
                            promise(.failure(error))
                        }else{
                            self.lastPrevDocument = querySnapshot!.documents.last
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
    
    // nil means latest posts
    func fetchPostsByTimeline(after post: Post?, limit: Int) async throws -> [Post] {
        
        if let prevPost = post {
            let prevDocument = try await fetchDocument(for: prevPost)
            let query = postCollRef
                .order(by: "timestamp",descending: true)
                .start(afterDocument: prevDocument)
                .limit(to: limit)
            let posts = try await fetchPosts(with: query)
            return posts
        }else{
            let query = postCollRef
                .order(by: "timestamp",descending: true)
                .limit(to: limit)
            let posts = try await fetchPosts(with: query)
            return posts
        }
    }
    
    private func fetchDocument(for post: Post) async throws -> DocumentSnapshot{
        
        try await withCheckedThrowingContinuation{ continuation in
            let docRef = postCollRef.document(post.postID!)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    //print("Document data: \(dataDescription)")
                    continuation.resume(returning: document)
                } else {
                    continuation.resume(throwing: PostManagerError.cannotFetchDocument)
                }
            }
        }
    }
    
    private func fetchPosts(with query: Query) async throws -> [Post] {
        
        try await withCheckedThrowingContinuation{ continuation in
            query.getDocuments { querySnapshot, error in
                if let error = error{
                    print("ERRRRRRRRRRRRR \(error)")
                    continuation.resume(throwing: PostManagerError.cannotFetchDocument)
                }
                let fetchedDocuments = querySnapshot!.documents
                let posts = fetchedDocuments.compactMap{ document in
                    let result = Result{ try document.data(as: Post.self) }
                    switch result{
                    case .success(let post):
                        return post
                    case .failure(let error):
                        print(error)
                        return nil
                    }
                }
                continuation.resume(returning: posts)
            }
        }
    }
    
    
    func addNewPost(_ post: Post) throws {
        try postCollRef.addDocument(from: post)
    }
    
    func deletePost(_ post: Post) throws {
        Task{
            try await deletePostFromFirestore(postID: post.postID!)
            try await deleteMediaFromBunny(media: post.media)
        }
    }
 
    private func deletePostFromFirestore(postID: String) async throws {
        try await withCheckedThrowingContinuation{ (continuation: CheckedContinuation<Void, Error>) in
            postCollRef.document(postID).delete(){ err in
                if let err = err {
                    continuation.resume(throwing: PostManagerError.deletionFromFireStoreFailed)
                    print("Error removing document: \(err)")
                } else {
                    continuation.resume()
                    print("Document successfully removed!")
                }
            }
        }
    }
    
    func fetch(post: Post){
        let docRef = postCollRef.document(post.postID!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func deleteMediaFromBunny(media: [MediaAsset]) async throws {
        
        try await withThrowingTaskGroup(of: Void.self){ group in
            
            media.forEach{ asset in
                group.addTask {
                    let fileURL = URL(string: asset.url)!
                    let accessKey = asset.type == .photo ? BunnyInfo.storageAPIKey : BunnyInfo.streamAPIKey
                    var request = URLRequest(url: fileURL)
                    request.httpMethod = "Delete"
                    request.setValue(accessKey, forHTTPHeaderField: "AccessKey")
                    
                    do{
                        let (_, response) = try await URLSession.shared.data(for: request)
                        
                       
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        if (200...299).contains(statusCode){
                            print("delete sucess")
                        }else{
                            print(statusCode)
                            throw PostManagerError.deletionFromBunnyFailed
                        }
                    }catch{
                        print(error)
                        throw error
                    }
                }
                
                //            for try await tuple in group {
                //                tuples.append(tuple)
                //            }
            }
            
        }
    }
    
    
    
    func fetchLatestPosts(limit: Int) -> AnyPublisher<[Post],Error> {
        Deferred {
            Future{ promise in
                self.timelineQuery.limit(to: limit).getDocuments { querySnapshot, error in
                    if let error = error{
                        print(error)
                        promise(.failure(error))
                    }else{
                        self.lastPrevDocument = querySnapshot!.documents.last
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
    
}
