//
//  ImageDownsampleOperation.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/6/13.
//

import Foundation
import ImageIO

/// `ImageDownsamplingOperation` intended for downsampling an image. In current version assumed that image will be taken from the local storage. The operation could be extended to download the image from server and then apply downsampling.
class ImageDownsampleOperation: Operation {
   
    let imageURL: URL
    private(set) var downsampledImage: CGImage?
    private let maxDimentionInPixels: Int

    init(imageURL: URL, maxDimentionInPixels: Int) {
        self.imageURL = imageURL
        self.maxDimentionInPixels = maxDimentionInPixels
        super.init()
    }
    
    override func main() {
        guard !isCancelled else { return }
        downsampledImage = downsampleImage(from: imageURL, maxDimentionInPixels: maxDimentionInPixels)
    }
    
    private func downsampleImage(from imageURL: URL, maxDimentionInPixels: Int) -> CGImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else {
            return nil
        }
        
        let downsampledOptions: [CFString : Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels
        ]
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions as CFDictionary) else {
            return nil
        }
        
        return downsampledImage
    }
}
