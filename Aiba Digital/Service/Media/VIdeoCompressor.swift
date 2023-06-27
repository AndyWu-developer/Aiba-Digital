//
//  VideoCompressor.swift
//
//  Created by Andy Wu on 2023/6/6.
//

import Foundation
import AVFoundation

final class VideoCompressor{
    
    private var assetReaders: [AVAssetReader] = []
    private var assetWriters: [AVAssetWriter] = []
    
    private let defaultCompressVideoBitRate: Float = 2496000
    private let defaultCompressAudioBitRate: Float = 128000

    private let videoReaderSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32ARGB]
    
    private let audioReaderSettings = [AVFormatIDKey: kAudioFormatLinearPCM,
                                    AVSampleRateKey: 44100,
                                    AVNumberOfChannelsKey: 2]
    
    func compress(asset: AVAsset, progressHandler: ((Double) -> ())? = nil) async throws -> URL {
        
        let videoData = try Data(contentsOf: (asset as! AVURLAsset).url)
        print("Video before compression: \( Double(videoData.count) / (1024 * 1024)) MB")
        
        try await loadKeysForCompression(for: asset)
       
        let videoTrack = asset.tracks(withMediaType: .video).first
        let audioTrack = asset.tracks(withMediaType: .audio).first
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        // MARK: AVAssetReader Configuration
        let reader = try AVAssetReader(asset: asset)
        
        let videoOutput: AVAssetReaderTrackOutput? = {
            guard let track = videoTrack else { return nil }
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: videoReaderSettings)
            guard reader.canAdd(output) else { return nil  }
            reader.add(output)
            return output
        }()
        
        let audioOutput: AVAssetReaderTrackOutput? = {
            guard let track = audioTrack else { return nil }
            let output = AVAssetReaderTrackOutput(track: track, outputSettings: audioReaderSettings)
            guard reader.canAdd(output) else { return nil }
            reader.add(output)
            return output
        }()
            
        // MARK: AVAssetWriter Configuration
        let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        writer.shouldOptimizeForNetworkUse = true
        
        let videoInput: AVAssetWriterInput? = {
            guard let videoTrack = videoTrack else { return nil }
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: writerVideoSettings(for: videoTrack))
            input.transform = videoTrack.preferredTransform //*
            guard writer.canAdd(input) else { return nil }
            writer.add(input)
            return input
        }()
        
        let audioInput: AVAssetWriterInput? = {
            guard let audioTrack = audioTrack else { return nil }
            let input = AVAssetWriterInput(mediaType: .audio, outputSettings: writerAudioSettings(for: audioTrack))
            guard writer.canAdd(input) else { return nil }
            writer.add(input)
            return input
        }()
       
        assetReaders.append(reader)
        assetWriters.append(writer)
    
        // MARK: Start Compression
        
        writer.startWriting()
        reader.startReading()
        writer.startSession(atSourceTime: .zero)
        
        await withTaskGroup(of: Void.self){ group in
            if let videoOutput = videoOutput, let videoInput = videoInput{
                group.addTask {
                    await self.transcode(readerOutput: videoOutput, writerInput: videoInput,progressHandler: progressHandler)
                }
            }
          
            if let audioOutput = audioOutput, let audioInput = audioInput{
                group.addTask {
                    await self.transcode(readerOutput: audioOutput, writerInput: audioInput,progressHandler: progressHandler)
                }
            }
        }
        
        // MARK: Cleanup After Compression

        await writer.finishWriting()
        writer.cancelWriting()
        reader.cancelReading()
        assetReaders.removeAll{ $0.asset == asset }
        assetWriters.removeAll{ $0.outputURL == outputURL }
        
        let data = try Data(contentsOf: outputURL)
        print("Video after compression: \(Double(data.count) / 1048576) MB")
        return outputURL
    }
    
    private func loadKeysForCompression(for asset: AVAsset) async throws {
        
        let readable = #keyPath(AVURLAsset.isReadable)
        let track = #keyPath(AVURLAsset.tracks)
        let timeRange = #keyPath(AVAssetTrack.timeRange)
        let size = #keyPath(AVAssetTrack.naturalSize)
        let bitRate = #keyPath(AVAssetTrack.estimatedDataRate)
        let transform = #keyPath(AVAssetTrack.preferredTransform)
    
        await asset.loadValues(forKeys: [track,readable])
      
        guard asset.statusOfValue(forKey: track, error: nil) == .loaded,
              asset.statusOfValue(forKey: readable, error: nil) == .loaded,
              asset.isReadable
        else {
            print("unable to load asset keys")
            throw VideoCompressorError.CustomError
        }
       
        if let audioTrack = asset.tracks(withMediaType: .audio).first{
            await audioTrack.loadValues(forKeys: [timeRange,bitRate])
            guard audioTrack.statusOfValue(forKey: timeRange, error: nil) == .loaded,
                  audioTrack.statusOfValue(forKey: bitRate, error: nil) == .loaded else {
                print("unable to load audioTrack's property")
                throw VideoCompressorError.CustomError
            }
        }
        
        guard let videoTrack = asset.tracks(withMediaCharacteristic: .visual).first else{
            print("no video")
            throw VideoCompressorError.CustomError
        }
        await videoTrack.loadValues(forKeys: [size, bitRate, transform, timeRange])
        
        guard videoTrack.statusOfValue(forKey: size, error: nil) == .loaded,
              videoTrack.statusOfValue(forKey: bitRate, error: nil) == .loaded,
              videoTrack.statusOfValue(forKey: transform, error: nil) == .loaded,
              videoTrack.statusOfValue(forKey: timeRange, error: nil) == .loaded
        else {
            print("unable to load videoTrack keys")
            throw VideoCompressorError.CustomError
        }
    }
    
    private func writerVideoSettings(for videoTrack: AVAssetTrack) -> [String : Any]{
        let compressBitRate = {
            let bitRate = videoTrack.estimatedDataRate
            return bitRate == .zero ? defaultCompressVideoBitRate : min(bitRate, defaultCompressVideoBitRate)
        }()

        let videoInputSettings: [String:Any] = [
            AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: compressBitRate,
                                           AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ] as [String : Any],
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoTrack.naturalSize.width,
            AVVideoHeightKey: videoTrack.naturalSize.height,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill
        ]
        return videoInputSettings
    }
    
    private func writerAudioSettings(for audioTrack: AVAssetTrack) -> [String : Any]{
        let compressBitRate = {
            let bitRate = audioTrack.estimatedDataRate
            return bitRate == .zero ? defaultCompressAudioBitRate : min(bitRate, defaultCompressAudioBitRate)
        }()
        let audioInputSettings: [String:Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                               AVEncoderBitRateKey: 128000,
                                               AVSampleRateKey: 44100,
                                               AVNumberOfChannelsKey: 2]
        return audioInputSettings
    }
    
    private func transcode(readerOutput: AVAssetReaderTrackOutput, writerInput: AVAssetWriterInput, progressHandler: ((Double) -> ())? = nil) async {
      
        await withUnsafeContinuation{ continuation in
            writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "serialQueue")) {
                while(writerInput.isReadyForMoreMediaData){
                    guard let nextSampleBuffer = readerOutput.copyNextSampleBuffer() else {
                        writerInput.markAsFinished()
                        continuation.resume()
                        break
                    }
                    writerInput.append(nextSampleBuffer)
                    
                    let duration = readerOutput.track.timeRange.duration
                    let timeStamp = CMSampleBufferGetPresentationTimeStamp(nextSampleBuffer)
                    let progress = CMTimeGetSeconds(timeStamp) / CMTimeGetSeconds(duration)
                    progressHandler?(progress)
                }
            }
        }
    }
}

extension VideoCompressor{
    
    enum VideoCompressorError: Error{
        case CustomError
    }
}
