//
//  ImageUploader.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/30.
//

import Foundation

class BunnyImageUploader {

    enum ImageUploaderError: Error { case uploadError }
    
    func uploadImage(from url: URL, progressHandler: progressHandler?) async throws -> URL {
        let fileName = UUID().uuidString + ".jpg"
        let uploadURL = URL(string:"https://\(BunnyInfo.storageHostname)/\(BunnyInfo.storageName)/\(BunnyInfo.storageDirectory)/\(fileName)")!
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        request.setValue(BunnyInfo.storageAPIKey, forHTTPHeaderField: "AccessKey")
        
        do{
            let (_, response) = try await URLSession.shared.upload(for: request, fromFile: url)
            let statusCode = (response as! HTTPURLResponse).statusCode
            if (200...299).contains(statusCode){
                print("upload sucess")
            }else{
                throw ImageUploaderError.uploadError
            }
        }catch{
            print(error)
            throw error
        }
        
        return uploadURL
    }
}
