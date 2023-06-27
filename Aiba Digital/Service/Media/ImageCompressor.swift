//
//  ImageCompressor.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/13.
//

import UIKit

final class ImageCompressor {

    /// A serial `OperationQueue` to lock access to the `imageProcessingQueue` and `completionHandlers` properties.
    private let serialAccessQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private let imageProcessingQueue = OperationQueue()
    private let cache = NSCache<NSURL, CGImage>()
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
    
        if let cachedImage = getCachedImage(for: imageURL) {
            invokeCompletionHandlers(for: imageURL, with: cachedImage)
            return
        }
        
        let operation = ImageDownsamplingOperation(imageURL: imageURL,
                                                maxDimentionInPixels: maxDimentionInPixels)
        operation.completionBlock = { [weak operation] in
            guard let downsampledImage = operation?.downsampledImage else { return }
            self.cache.setObject(downsampledImage, forKey: imageURL as NSURL)
            
            self.serialAccessQueue.addOperation {
                self.invokeCompletionHandlers(for: imageURL, with: downsampledImage)
            }
        }
        
        imageProcessingQueue.addOperation(operation)
    }
    
    
    private func getCachedImage(for imageURL: URL) -> CGImage? {
        return cache.object(forKey: imageURL as NSURL)
    }
    
    func cancelDownsampling(for imageURL: URL) {
        serialAccessQueue.addOperation {
            self.imageProcessingQueue.isSuspended = true
            self.operation(for: imageURL)?.cancel()
            self.completionHandlers[imageURL] = nil
            self.imageProcessingQueue.isSuspended = false
        }
    }
    
    private func operation(for imageURL: URL) -> ImageDownsamplingOperation? {
        for case let fetchOperation as ImageDownsamplingOperation in imageProcessingQueue.operations
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
    
}

