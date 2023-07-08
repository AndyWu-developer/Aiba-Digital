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
        set {
            playerLayer.player = newValue
            playerObserver = playerLayer.player?.publisher(for: \.timeControlStatus)
                .sink{ [unowned self] status in
                    switch status {
                    case .playing:
                        spinner.stopSpinning()
                        spinner.isHidden = true
                        
                    case .paused:
                        spinner.stopSpinning()
                        spinner.isHidden = true

                    case .waitingToPlayAtSpecifiedRate:
                        if shouldAutoPlay{
                       //     DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                if self.shouldAutoPlay{
                                    self.spinner.startSpinning()
                                    self.spinner.isHidden = false
                                }
                            //}
                           
                        }
                    @unknown default:
                        fatalError("New timeControlStatus case to handle")
                    }

                }
            
        }
    }
    
    var thumbnail: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    var video: AVAsset? {
        get { player?.currentItem?.asset }
        set {
            guard newValue != player?.currentItem?.asset else { return }
            if let asset = newValue {
                let playerItem = AVPlayerItem(asset: asset)
                
                playerItemObserver = playerItem.publisher(for: \.isPlaybackBufferEmpty)
                    .filter{!$0}
                    .sink{ [unowned self] _ in
                        if shouldAutoPlay{
                            player?.play()
                        }
                    }
                playerLayer.player?.replaceCurrentItem(with: playerItem)
                if shouldAutoPlay { player?.playImmediately(atRate: 1) }
            } else {
                playerLayer.player?.replaceCurrentItem(with: nil)
                // the player will then enter .waitingToPlayAtSpecifiedRate state
            }
        }
    }
    
    @Published var shouldAutoPlay: Bool = false {
        didSet{
            shouldAutoPlay ? player?.playImmediately(atRate: 1) : player?.pause()
        }
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    private var playerItemObserver: AnyCancellable?
    private var playerObserver: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    private let spinner = SpinningView()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    override func layoutSubviews() {
        imageView.frame = self.bounds
        spinner.frame = CGRect(x: bounds.midX - 20, y: bounds.midY - 20, width: 40, height: 40)
        
    }
    
    private func customInit(){
        addSubview(imageView)
        addSubview(spinner)
        
        
        playerLayer.videoGravity = .resizeAspectFill
        
        playerLayer.publisher(for: \.isReadyForDisplay)
            .sink { [unowned self] ready in
                if !ready{
                    imageView.isHidden = false
                }else if ready && shouldAutoPlay{
                    imageView.isHidden = true
                }
            }.store(in: &subscriptions)
 
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .receive(on: DispatchQueue.main)
            .compactMap{ $0.object as? AVPlayerItem }
            .filter{ [unowned self] in $0 == player?.currentItem }
            .sink{ [unowned self] _ in
                player?.seek(to: .zero)
                if shouldAutoPlay { player?.playImmediately(atRate: 1) }
            }
            .store(in: &subscriptions)
        
        $shouldAutoPlay.combineLatest(playerLayer.publisher(for: \.isReadyForDisplay))
            .sink { [unowned self] canPlay, readyToPlay in
                if !readyToPlay { imageView.isHidden = false }
                if canPlay, readyToPlay { imageView.isHidden = true }
            }
            .store(in: &subscriptions)
    }
    
}
