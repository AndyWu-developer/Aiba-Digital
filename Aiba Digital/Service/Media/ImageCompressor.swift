//
//  ImageCompressor.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/13.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit.UIImage

final class ImageCompressor {

    enum ImageCompressorError: Error{
        case CustomError
    }
    /// A serial `OperationQueue` to lock access to the `imageProcessingQueue` and `completionHandlers` properties.
    private let serialAccessQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private let imageProcessingQueue = OperationQueue()
    private var completionHandlers = [URL: [(CGImage?) -> Void]]()
   
    func compressImage(from imageURL: URL, maxDimentionInPixels: Int, completion: ((CGImage?) -> Void)? = nil){
        serialAccessQueue.addOperation {
            if let completion = completion {
                let handlers = self.completionHandlers[imageURL, default: []]
                self.completionHandlers[imageURL] = handlers + [completion]
            }
            
            self.downsampleImage(for: imageURL, maxDimentionInPixels: maxDimentionInPixels)
        }
    }
   
    private func downsampleImage(for imageURL: URL, maxDimentionInPixels: Int) {
        guard operation(for: imageURL) == nil else { return }
    
        let operation = ImageDownsampleOperation(imageURL: imageURL,
                                                maxDimentionInPixels: maxDimentionInPixels)
        operation.completionBlock = { [weak operation] in
            guard let downsampledImage = operation?.downsampledImage else { return }
            
            self.serialAccessQueue.addOperation {
//                let task = Task {
//                    let outputURL = try await saveToFile(cgImage: downsampledImage)
//                }
                self.invokeCompletionHandlers(for: imageURL, with: downsampledImage)
            }
        }
        
        imageProcessingQueue.addOperation(operation)
    }
    
    func cancelDownsampling(for imageURL: URL) {
        serialAccessQueue.addOperation {
            self.imageProcessingQueue.isSuspended = true
            self.operation(for: imageURL)?.cancel()
            self.completionHandlers[imageURL] = nil
            self.imageProcessingQueue.isSuspended = false
        }
    }
    
    private func operation(for imageURL: URL) -> ImageDownsampleOperation? {
        for case let fetchOperation as ImageDownsampleOperation in imageProcessingQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.imageURL == imageURL {
                return fetchOperation
        }
        return nil
    }
    
    private func invokeCompletionHandlers(for imageURL: URL, with downsampledImage: CGImage) {
        let invokedCompletionHandlers = completionHandlers[imageURL, default: []]
        completionHandlers[imageURL] = nil
        invokedCompletionHandlers.forEach { $0(downsampledImage) }
    }
    
    private func saveToFile(cgImage: CGImage) async throws -> URL {
        
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw ImageCompressorError.CustomError
        }
       
        CGImageDestinationAddImage(destination, cgImage, nil)
        if CGImageDestinationFinalize(destination) {
            return fileURL
        }else{
            throw ImageCompressorError.CustomError
        }
    }
    
}

