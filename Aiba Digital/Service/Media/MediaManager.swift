//
//  MediaManager.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/12.
//

import Foundation
import AVFoundation

typealias progressHandler = ((Double) -> ())

protocol MediaDownloading: AnyObject {
    func fetchImageData(from url: URL, progressHandler: progressHandler?) async throws -> Data
    func fetchVideoAsset(from url: URL, progressHandler: progressHandler?) async throws -> AVURLAsset
}

protocol MediaUploading: AnyObject {
    func uploadImage(from url: URL, progressHandler: progressHandler?) async throws -> URL
    func uploadVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL
}

protocol MediaCompressing: AnyObject {
    func compressVideo(from url: URL, maxDimentionInPixels: Int, progressHandler: progressHandler?) async throws -> URL
    func compressImage(from url: URL, maxDimentionInPixels: Int) async throws -> URL
}


final class MediaManager {
    
    static let shared: MediaManager = MediaManager()
    
    private let imageLoader = BunnyImageLoader()
    private let videoLoader = BunnyVideoLoader()
    
    private let imageCompressor = ImageCompressor()
    private let videoCompressor = VideoCompressor()
    
    private let imageUploader = BunnyImageUploader()
    private let videoUploader = BunnyVideoUploader()
}

// MARK: - MediaUploading
extension MediaManager: MediaUploading {
    
    func uploadImage(from url: URL, progressHandler: progressHandler?) async throws -> URL{
        return try await imageUploader.uploadImage(from: url, progressHandler: progressHandler)
    }
    
    func uploadVideo(from url: URL, progressHandler: progressHandler?) async throws -> URL{
        return try await videoUploader.uploadVideo(from: url, progressHandler: progressHandler)
    }
    
    func uploadImages(from urls: [URL], progressHandler: progressHandler?) async throws -> [URL] {
       return []
    }
    
    func uploadVideos(from urls: [URL], progressHandler: progressHandler?) async throws -> [URL] {
        return []
     }
}

extension MediaManager: MediaDownloading {
    
    func fetchVideoAsset(from url: URL, progressHandler: progressHandler?) async throws -> AVURLAsset {
        return try await videoLoader.loadVideoAsset(from: url) as! AVURLAsset
    }
    
    func fetchImageData(from url: URL, progressHandler: progressHandler?) async throws -> Data {
        return try await imageLoader.downloadImageData(from: url)
    }
    
    func fetchVideoThumbnail(from url: URL, progressHandler: progressHandler?) async throws -> Data {
        return try await imageLoader.loadVideoThumbnailData(from: url)
    }
}

// MARK: - MediaCompressing
extension MediaManager: MediaCompressing {
    
    enum MediaCompressError: Error { case cannotCompressVideo, cannotCompressImage }
    
    func compressVideo(from url: URL, maxDimentionInPixels: Int, progressHandler: progressHandler?) async throws -> URL {
        let outputURL = try await videoCompressor.compressVideo(from: url, maxDimentionInPixels: maxDimentionInPixels)
        return outputURL
    }
    //When compressing image, do not wrapping the compressed cgImage to UIImage and convert to jpg will increase file size, save the cgImage to jpeg directly :)
    func compressImage(from url: URL, maxDimentionInPixels: Int) async throws -> URL {
       
        try await withCheckedThrowingContinuation { continuation in

            //let imageData = try! Data(contentsOf: url)
            //print("image before compression: \(Double(imageData.count) / (1024 * 1024)) MB")
         
            imageCompressor.compressImage(from: url, maxDimentionInPixels: maxDimentionInPixels){ image in
         
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                
                if let cgImage = image, let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) {
                    CGImageDestinationAddImage(destination, cgImage, nil)
                    if CGImageDestinationFinalize(destination) {
                        //let data = try! Data(contentsOf: fileURL)
                        //print("image after compression: \(Double(data.count) / (1024 * 1024)) MB")
                        continuation.resume(returning: fileURL)
                    }else{
                        continuation.resume(throwing: MediaCompressError.cannotCompressImage)
                    }
                }else{
                    continuation.resume(throwing: MediaCompressError.cannotCompressImage)
                }
            }
        }

    }

}

extension MediaManager {
    
    
}


