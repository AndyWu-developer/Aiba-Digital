//
//  ViLoader.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/30.
//

import Foundation
import AVFoundation

class AssetsLoader : NSObject {
    public typealias AssetsLoaderCallback = ((IndexPath,AVPlayerItem)->Void)
    private var callback: AssetsLoaderCallback
    private(set) var loadedAssets: [IndexPath:AVURLAsset] = [:]
    private(set) var pendingAssets: [IndexPath:AVURLAsset] = [:]
    
    static var assetKeysRequiredToPlay = ["playable","tracks","duration"]
    init(callback:@escaping AssetsLoaderCallback) {
        self.callback = callback
    }

    func loadAssetsAsync(assets:[IndexPath:AVURLAsset]) {
        loadedAssets = [:]
        pendingAssets = [:]
        for (key, value) in assets {
            loadAssetAsync(index: key, asset: value)
        }
    }

    private func loadAssetAsync(index:IndexPath,asset:AVURLAsset) {
        asset.loadValuesAsynchronously(forKeys: AssetsLoader.assetKeysRequiredToPlay) { [weak self] in
            for key in AssetsLoader.assetKeysRequiredToPlay {
                var error : NSError?
                if asset.statusOfValue(forKey: key, error: &error) == .failed {
                    //FIXME: Asset Could not load
                    print("Asset Could not load")
                }
            }
            if !asset.isPlayable {
                print("Cant play, move to next asset?")
            } else {
                // Asset Ready, Check if
                self?.prepareAssetForCallback(index: index, asset: asset)
            }
        }
    }
    private func prepareAssetForCallback(index:IndexPath,asset:AVURLAsset) {
        if index.row == 0 {
            /// First Asset
            loadedAssets[index] = asset
            self.sendReadyAsset(index: index)
            if let nextInline = pendingAssets[index.rowSuccessor()] {
                self.freePendingAsset(index: index.rowSuccessor(), asset: nextInline)
            }
        } else {
            self.freePendingAsset(index: index, asset: asset)
        }
    }

    private func freePendingAsset(index:IndexPath,asset:AVURLAsset) {
        if loadedAssets[index.rowPredecessor()] != nil && loadedAssets[index] == nil {
            loadedAssets[index] = asset
            self.sendReadyAsset(index: index)
            if let nextInline = pendingAssets[index.rowSuccessor()] {
                self.freePendingAsset(index: index.rowSuccessor(), asset: nextInline)
            }
        } else {
            if pendingAssets[index] == nil {
                pendingAssets[index] = asset
            }
        }
    }

    private func sendReadyAsset(index:IndexPath) {
        self.callback(index, AVPlayerItem(asset:self.loadedAssets[index]!))
    }
    
//    let exporter = AVAssetExportSession(asset: avUrlAsset, presetName: AVAssetExportPresetHighestQuality)
//    exporter?.outputURL = outputURL
//    exporter?.outputFileType = AVFileType.mp4
//
//    exporter?.exportAsynchronously(completionHandler: {
//        print(exporter?.status.rawValue)
//        print(exporter?.error)
//    })
//    
    
    
    
}

extension IndexPath {

    func rowPredecessor() -> IndexPath {
        assert(self.row != 0, "-1 is an illegal index row")
        return IndexPath(row: self.row - 1, section: self.section)
    }

    func rowSuccessor() -> IndexPath {
        return IndexPath(row: self.row + 1, section: self.section)
    }
}
