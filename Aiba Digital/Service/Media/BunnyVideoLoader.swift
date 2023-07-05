//
//  VideoLoader.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/30.
//

import Foundation
import AVFoundation

actor BunnyVideoLoader {
    enum VideoLoaderError : Error{
        case CustomError
        case NOVideoID
    }
    
    private let cache = NSCache<NSURL, AVAsset>()
    private var loadingTasks = [URL: Task<AVAsset, Error>]()
    
    func loadVideoAsset(from videoURL: URL) async throws -> AVAsset {

        guard let videoID = videoURL.absoluteString.components(separatedBy: "/").last else {
            throw VideoLoaderError.NOVideoID
        }
        let url = URL(string: "https://\(BunnyInfo.streamPullZone)/\(videoID)/playlist.m3u8")!
        let asset = AVURLAsset(url: url)
     
        return asset
        
        
        if let videoAsset = cache.object(forKey: videoURL as NSURL) {
            print("video cached :)")
            return videoAsset
        }
        
        print("video not cached")
        if let loadingTask = loadingTasks[videoURL] {
            print("video already loading")
            return try await loadingTask.value
        }
        
        let task = Task {
            let videoAsset = AVAsset(url: videoURL)
            try await loadKeys(for: videoAsset)
            return videoAsset
        }

        loadingTasks[videoURL] = task
        let videoAsset = try await task.value
        cache.setObject(videoAsset, forKey: videoURL as NSURL)
        loadingTasks[videoURL] = nil
    
        return videoAsset
    }
    
    private func loadKeys(for asset: AVAsset) async throws {
        
        let track = #keyPath(AVURLAsset.tracks)
        let duration = #keyPath(AVURLAsset.duration)
        
        await asset.loadValues(forKeys: [duration])
        print(Thread.isMainThread)
        guard asset.statusOfValue(forKey: duration, error: nil) == .loaded,
              asset.statusOfValue(forKey: duration, error: nil) == .loaded else {
            print("unable to load asset keys")
            throw VideoLoaderError.CustomError
        }
        print(asset.duration)
        
        
    }
}
