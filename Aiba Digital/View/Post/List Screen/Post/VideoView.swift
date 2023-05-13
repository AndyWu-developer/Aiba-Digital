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
    
    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }
    
    var video: AVAsset? {
        get { player?.currentItem?.asset }
        set {
            if let asset = newValue {
                let item = AVPlayerItem(asset: asset)
                playerLayer.player?.replaceCurrentItem(with: item)
                if shouldAutoPlay { player?.play() }
            }else{
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
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.4)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular ,scale: .default)
        button.setImage(UIImage(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(UIImage(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .selected)
       
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        //addSubview(playButton)
        //playButton.isUserInteractionEnabled = false
        playerLayer.publisher(for: \.isReadyForDisplay)
            .sink { [weak self] ready in
                self?.imageView.isHidden = ready
            }.store(in: &subscriptions)
        
        playButton.publisher(for: .touchUpInside)
            .sink { [weak self] button in
                self?.shouldAutoPlay.toggle()
                button.isSelected.toggle()
            }.store(in: &subscriptions)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        imageView.frame = self.bounds
      //  playButton.frame = CGRect(x: bounds.midX - 30 , y: bounds.midY - 30, width: 60, height: 60)
        // Calculate the scale factor of the zoom
//        let zoomScale = self.transform.a
//        let dx = self.transform.tx
//        let dy = self.transform.ty
//        print((dx,dy))
//        // Calculate the size of the play button based on the zoom scale
//        let buttonSize = 60 / zoomScale
//        // Update the frame of the play button
//        playButton.frame = CGRect(x: bounds.midX - buttonSize/2, y: bounds.midY - buttonSize/2, width: buttonSize, height: buttonSize)
//        playButton.layer.cornerRadius = buttonSize/2
    }
}
