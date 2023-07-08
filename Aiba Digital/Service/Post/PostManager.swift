//
//  PostManager.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/17.
//

import FirebaseFirestore

protocol PostManaging {
    func fetchPostsByTimeline(after post: Post?, limit: Int) async throws -> [Post]
    func addNewPost(_ post: Post) throws
    func deletePost(_ post: Post) throws
}

class PostManager: PostManaging {
    
    enum PostManagerError: Error{
        case deletionFromFireStoreFailed
        case deletionFromBunnyFailed
        case invalidURL
        case cannotFetchDocument
    }
    
    // MARK: - FireStore References
    private let postCollectionRef = Firestore.firestore().collection("posts")
    private lazy var timelineQuery = postCollectionRef.order(by: "timestamp", descending: true)
    
    //MARK: - Fetch Comment
    // nil means latest posts
    func fetchPostsByTimeline(after post: Post?, limit: Int) async throws -> [Post] {
        
        if let prevPost = post {
            let prevDocument = try await fetchDocument(for: prevPost)
            let query = timelineQuery.start(afterDocument: prevDocument).limit(to: limit)
            let posts = try await fetchPosts(with: query)
            return posts
        }else{
            let query = timelineQuery.limit(to: limit)
            let posts = try await fetchPosts(with: query)
            return posts
        }
    }
    
    private func fetchDocument(for post: Post) async throws -> DocumentSnapshot{
        
        try await withCheckedThrowingContinuation{ continuation in
            let documentRef = postCollectionRef.document(post.id!)
            documentRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    //let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
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
                    debugPrint(error)
                    continuation.resume(throwing: PostManagerError.cannotFetchDocument)
                }

                let posts = querySnapshot!.documents.compactMap{ document in
                    let result = Result{ try document.data(as: Post.self) }
                    switch result{
                    case .success(let post):
                        return post
                    case .failure(let error):
                        debugPrint(error)
                        return nil
                    }
                }
                continuation.resume(returning: posts)
            }
        }
    }
    
    
    func addNewPost(_ post: Post) throws {
        try postCollectionRef.addDocument(from: post)
    }
    
    func deletePost(_ post: Post) throws {
        Task{
            try await deletePostFromFirestore(postID: post.id!)
            try await deleteMediaFromBunny(media: post.media)
        }
    }
 
    private func deletePostFromFirestore(postID: String) async throws {
        try await withCheckedThrowingContinuation{ (continuation: CheckedContinuation<Void, Error>) in
            postCollectionRef.document(postID).delete(){ err in
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
    
    private func deleteMediaFromBunny(media: [MediaAsset]) async throws {
        
        try await withThrowingTaskGroup(of: Void.self){ group in
            
            media.forEach{ asset in
                group.addTask {
                    let fileURL = asset.url
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
    
    func updateAllDocuments(){
        
        postCollectionRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting all documents: \(err)")
            } else {
                querySnapshot!.documents.forEach{ document in
                    //print("\(document.documentID) => \(document.data())")
                    self.postCollectionRef.document(document.documentID)
                        .updateData(["userID": FieldValue.delete(), "user": ""]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                }
            }
        }
    }
    

}
