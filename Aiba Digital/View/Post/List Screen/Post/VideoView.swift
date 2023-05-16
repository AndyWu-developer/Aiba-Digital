//
//  VideoView.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/12.
//

import UIKit
import AVFoundation
import Combine

class VideoView: UIView {
    
    override static var layerClass: AnyClass { AVPlayerLayer.self }

    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var thumbnailImage: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    var video: AVAsset? {
        get { player?.currentItem?.asset }
        set {
            guard newValue != player?.currentItem?.asset else { print("duplicate"); return }
            if let asset = newValue {
                let item = AVPlayerItem(asset: asset)
                playerLayer.player?.replaceCurrentItem(with: item)
                if shouldAutoPlay { player?.play() }
            } else {
                playerLayer.player?.replaceCurrentItem(with: nil)
            
            }
        }
    }
    
    var shouldAutoPlay: Bool = false {
        didSet{
            shouldAutoPlay ? player?.play() : player?.pause()
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .loadGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        playerLayer.publisher(for: \.isReadyForDisplay)
            .sink { [weak self] ready in
                self?.imageView.isHidden = ready
            }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(imageView)
        playerLayer.publisher(for: \.isReadyForDisplay)
            .sink { [weak self] ready in
                self?.imageView.isHidden = ready
            }.store(in: &subscriptions)
    }
    
    override func layoutSubviews() {
        imageView.frame = self.bounds
    }
}
