//
//  VideoUploader.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/30.
//

import Foundation

class BunnyVideoUploader {
    
    enum VideoUploaderError: Error {
        case CustomError
        case createVideoFailed
        case uploadVideoFailed
        case unknown
    }
   
    func uploadVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL {
        let videoTitle = UUID().uuidString
        let videoID = try await createVideo(title: videoTitle)
        let videoURL = try await uploadVideo(from: url, videoID: videoID)
        return videoURL
    }
    
    private func createVideo(title: String) async throws -> String {
        let url = URL(string:"https://video.bunnycdn.com/library/\(BunnyInfo.streamLibraryID)/videos")!
        let postData = Data("{ \"collectionId\":\"\(BunnyInfo.streamCollectionID)\",           \"title\":\"\(title)\", \"thumbnailTime\":\"0\"}".utf8)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/*+json", forHTTPHeaderField: "content-type")
        request.setValue(BunnyInfo.streamAPIKey, forHTTPHeaderField: "AccessKey")
        request.httpBody = postData
        
        do{
            let (data, response) = try await URLSession.shared.data(for: request)
 
            guard let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) else {
                     //  self.handleServerError(response)
                print("invalid server response")
                throw VideoUploaderError.CustomError
            }
            
//            let responseBody = String(data: data, encoding: .utf8)!
//            if let data = responseBody.data(using: .utf8)
            
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Invalid JSON format")
                throw VideoUploaderError.CustomError
            }
            
            guard let videoID = jsonObject["guid"] as? String else {
                print("missing 'guid' key")
                throw VideoUploaderError.CustomError
            }
            print("videoID: \(videoID)")
            return videoID
        }catch{
            print(error)
            throw error
        }
    }

    private func uploadVideo(from url: URL, videoID: String) async throws -> URL {
        let uploadURL = URL(string:"https://video.bunnycdn.com/library/\(BunnyInfo.streamLibraryID)/videos/\(videoID)")!
        
        var request = URLRequest(url: uploadURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: .greatestFiniteMagnitude)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(BunnyInfo.streamAPIKey, forHTTPHeaderField: "AccessKey")
        
        do{
            let (_, response) = try await URLSession.shared.upload(for: request, fromFile: url)
            let statusCode = (response as! HTTPURLResponse).statusCode
            if (200...299).contains(statusCode){
                print("upload video success")
            }else{
                print(statusCode)
                print(response)
                throw VideoUploaderError.CustomError
            }
        }catch{
            print(error)
            throw error
        }
        
        return uploadURL
    }
}

