//
//  MediaProvider.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/30.
//

import UIKit
import AVKit
import Combine

protocol MediaProviding {
    func fetchImage(for urlString: String) -> AnyPublisher<Data?,Never>
    func fetchVideoTumbnail(for urlString: String) -> AnyPublisher<Data?,Never>
    func fetchVideoAsset(for urlString: String) -> AnyPublisher<AVAsset?,Never>
}

class MediaProvider: MediaProviding {
 
    static let shared: MediaProvider = MediaProvider()
    private init() { }
    
    private let imageCache = NSCache<NSString, NSData>()
    private let videoAssetCache = NSCache<NSString, AVAsset>()

    private var pendingImagePublishers = [String : AnyPublisher<Data?,Never>]()
    
    func fetchImage(for urlString: String) -> AnyPublisher<Data?, Never> {
        Deferred{ () -> AnyPublisher<Data?, Never> in
          
            if let cachedImageData = self.imageCache.object(forKey: urlString as NSString) as Data?{
                return Just(cachedImageData).eraseToAnyPublisher()
            }else if let pendingPublisher = self.pendingImagePublishers[urlString] {
                return pendingPublisher
            }else{
                guard let url = URL(string: urlString) else { return Just(nil).eraseToAnyPublisher() }
                let publisher =
                URLSession.shared.dataTaskPublisher(for: url)
                    .map {$0.data}
                    .replaceError(with: nil)
                    .handleEvents(receiveOutput: { [self] data in
                        if data != nil {
                            self.imageCache.setObject(data! as NSData, forKey: urlString as NSString)
                            self.pendingImagePublishers[urlString] = nil
                        }else{
                            print("network error cannot fetch image:)")
                        }
                     })
                    .share()
                    .eraseToAnyPublisher()
                self.pendingImagePublishers[urlString] = publisher
                return publisher
            }
        }.eraseToAnyPublisher()
    }
    
    func fetchVideoTumbnail(for urlString: String) -> AnyPublisher<Data?, Never> {
     
        Deferred { () -> AnyPublisher<Data?, Never> in
            if let cachedImageData = self.imageCache.object(forKey: urlString as NSString){
               // print("thumbnail cached :)")
                return Just(cachedImageData as Data).eraseToAnyPublisher()
            }
            if let publisher = self.pendingImagePublishers[urlString] {
               //print("thumbail duplicates :)")
                return publisher
            }else{
               // print("fetching thumbail...")
                guard let url = URL(string: urlString) else { return Just(nil).eraseToAnyPublisher() }
                
                let publisher = Future<Data?,Never>{ promise in
                    DispatchQueue.global(qos: .userInitiated).async{
                        let thumbnailGenerator = AVAssetImageGenerator(asset: AVAsset(url: url))
                        thumbnailGenerator.appliesPreferredTrackTransform = true
                        thumbnailGenerator.maximumSize = UIScreen.main.bounds.size
                        let thumnailTime = CMTimeMake(value: 1, timescale: 1)
                        do {
                            let cgThumbImage = try thumbnailGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                            let thumbImage = UIImage(cgImage: cgThumbImage)
                            if let data = thumbImage.pngData(){
                               // print("thumbnail fetched :)")
                                self.imageCache.setObject(data as NSData, forKey: urlString as NSString)
                                self.pendingImagePublishers[urlString] = nil
                                promise(.success(data))
                            }else{
                                promise(.success(nil))
                            }
                        } catch {
                            print("cannot fetch thumbnail \(error.localizedDescription)") //10
                            promise(.success(nil))
                        }
                    }
                }
                .share()
                .eraseToAnyPublisher()
                self.pendingImagePublishers[urlString] = publisher
                return publisher
            }
           
        }.eraseToAnyPublisher()
    }
    
    
//    func d(){
//        let serialQueue = DispatchQueue(label: "queue", qos: .utility, attributes: [], autoreleaseFrequency: .workItem, target: nil)
//
//        for i in 0...50 {
//            serialQueue.async {
//                let quality = 0.02 * CGFloat(i)
//                //let data = image.toJpegData(compressionQuality: quality)
//                let data = image.jpegData(compressionQuality: quality)
//                let size = CGFloat(data!.count)/1000.0/1024.0
//                print("\(i), quality: \(quality), \(size.rounded()) mb")
//            }
//        }
//    }

    
    func fetchVideoAsset(for urlString: String) -> AnyPublisher<AVAsset?, Never> {
       Deferred { () -> AnyPublisher<AVAsset?, Never> in
            if let cachedAsset = self.videoAssetCache.object(forKey: urlString as NSString){
                //print("asset cached :)")
                return Just(cachedAsset).eraseToAnyPublisher()
            }
            guard let url = URL(string: urlString) else { return Just(nil).eraseToAnyPublisher() }
            //print("fetching asset...")
            return Future<AVAsset?,Never> { promise in
                let asset = AVURLAsset(url: url)
                let track = #keyPath(AVURLAsset.tracks)
                let duration = #keyPath(AVURLAsset.duration)
                let playable = #keyPath(AVURLAsset.isReadable)
                asset.loadValuesAsynchronously(forKeys: [track]) { [weak self] in
                    let status = asset.statusOfValue(forKey: track, error: nil)
                    if status == .loaded{
                       // print("asset fetched :)")
                        self?.videoAssetCache.setObject(asset, forKey: urlString as NSString)
                        promise(.success(asset))
                    }else{
                       // print("asset not fetched :(")
                        promise(.success(nil))
                    }
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}


extension Data {
    func getAVAsset() -> AVAsset {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).mov"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        try! self.write(to: fullURL!)
        let asset = AVAsset(url: fullURL!)
        return asset
    }
}
