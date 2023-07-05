//
//  ImageDownloader.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/30.
//

import Foundation
import UIKit
import AVFoundation

actor BunnyImageLoader {
    
    enum ImageLoaderError: Error{
        case CannotFetchThumbnail
    }
    private let cache = NSCache<NSURL, NSData>()
    private var downloadingTasks = [URL: Task<Data, Error>]()
    private var progressHandlers = [URL: [(Double) -> Void]]()
    
    func downloadImageData(from url: URL, progressHandler: ((Double) -> ())? = nil) async throws -> Data {
      
        let imageURL = getPullZoneURL(from: url)!
        
        if let handler = progressHandler {
            progressHandlers[imageURL, default: []].append(handler)
        }
       
        if let imageData = cache.object(forKey: imageURL as NSURL) as? Data {
          //  print("image cached :)")
            invokeProgressHandlers(for: imageURL, with: 1)
            return imageData
        }
        //print("image not cached")
        
        if let downloadingTask = downloadingTasks[imageURL] {
            //print("image downding")
            return try await downloadingTask.value
        }
        
        let task = Task {
            let (imageData, _) = try await URLSession.shared.data(from: imageURL)
            return imageData
        }

        downloadingTasks[imageURL] = task
        let imageData = try await task.value
        cache.setObject(imageData as NSData, forKey: imageURL as NSURL)
        downloadingTasks[imageURL] = nil
        progressHandlers[imageURL] = nil

        return imageData
    }
    
    func loadVideoThumbnailData(from url: URL, progressHandler: ((Double) -> ())? = nil) async throws -> Data {
        
        let videoID = url.absoluteString.components(separatedBy: "/").last!
        let thumbnailURL = URL(string: "https://\(BunnyInfo.streamPullZone)/\(videoID)/thumbnail.jpg")!
        
        if let handler = progressHandler {
            progressHandlers[thumbnailURL, default: []].append(handler)
        }
       
        if let imageData = cache.object(forKey: thumbnailURL as NSURL) as? Data {
            invokeProgressHandlers(for: thumbnailURL, with: 1)
            print("cached")
            return imageData
        }
        
        if let downloadingTask = downloadingTasks[thumbnailURL] {
            return try await downloadingTask.value
        }
        
        let task = Task {
            let (imageData, _) = try await URLSession.shared.data(from: thumbnailURL)
            return imageData
        }

        downloadingTasks[thumbnailURL] = task
        let imageData = try await task.value
        cache.setObject(imageData as NSData, forKey: thumbnailURL as NSURL)
        downloadingTasks[thumbnailURL] = nil
        progressHandlers[thumbnailURL] = nil
        return imageData
    }
    
    
    private func getPullZoneURL(from storageURL: URL) -> URL? {
        // PARSE: https:// {storageHostname} / {storageName} / {storageDirectory} / {fileName}
        // TO   : https:// {pullZoneHostname} /{storageDirectory} / {fileName}
        let originalURL = storageURL.absoluteString
        let pattern = #"https:\/\/([^\/]+)\/([^\/]+)\/(.+)"#
        let regex = try! NSRegularExpression(pattern: pattern)
        
        let range = NSRange(originalURL.startIndex..<originalURL.endIndex, in: originalURL)
        let convertedURL = regex.stringByReplacingMatches(in: originalURL, options: [], range: range, withTemplate: "https://\(BunnyInfo.storagePullZone)/$3")
        
        return URL(string: convertedURL)
    }
    
    private func invokeProgressHandlers(for imageURL: URL, with progress: Double) {
        let invokedCompletionHandlers = progressHandlers[imageURL, default: []]
        invokedCompletionHandlers.forEach{ $0(progress) }
    }
}


//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//
//        let totalBytes = dataTask.countOfBytesExpectedToReceive
//        let receivedBytes = dataTask.countOfBytesReceived
//        let progress = Double(receivedBytes) / Double(totalBytes)
//        print(progress)
//
//        if let imageURL = dataTask.originalRequest?.url {
//            invokeProgressHandlers(for: imageURL, with: progress)
//        }
//    }

