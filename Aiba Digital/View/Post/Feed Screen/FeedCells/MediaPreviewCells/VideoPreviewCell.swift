//
//  VideoPreviewCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/24.
//

import UIKit
import AVFoundation
import Combine

class VideoPreviewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoIcon: UIImageView!
    static let unmutedNotification = Notification.Name("playerUnmuted")
    static var isPlayerMuted = true
    
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var muteButton: UIButton!
   
    let maxOverlayAlpha: CGFloat = 0.8
    let minOverlayAlpha: CGFloat = 0.2
    
    var overlayView: UIView!
    var windowVideoView: VideoView!
    var initialGestureInView: CGPoint!
    
    var viewModel: VideoViewModel!{
        didSet{
            if oldValue != viewModel{
                bindViewModelOutput()
            }else{
                print("Same shot")
            }
            
        }
    }
    
    private var zoom: AnyCancellable?
    private var videoProcessSubscription = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    private var ratioConstraint: NSLayoutConstraint!
    private let maxRatio: CGFloat = 1.5
    private let minRatio: CGFloat = 1/3
    private let player = AVPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // player.automaticallyWaitsToMinimizeStalling = false
        videoView.player = player
        player.isMuted = Self.isPlayerMuted
        muteButton.isSelected = !Self.isPlayerMuted
        configureVolumeActions()
      
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        pinch.delegate = self
        videoView.addGestureRecognizer(pinch)
        videoView.isUserInteractionEnabled = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
      //  videoProcessSubscription.removeAll()
        player.pause()
    }
    
    func playVideo(){
        videoView.shouldAutoPlay = true
    }
    
    func stopVideo(){
        videoView.shouldAutoPlay = false
    }
    
    private func configureVolumeActions(){
        
        player.publisher(for: \.timeControlStatus)
            .map {$0 == .playing}
            .removeDuplicates()
            .sink { [unowned self] isPlaying in
                UIView.animate(withDuration: 0.2) {
                    self.muteButton.alpha = isPlaying ? 1 : 0
                    self.videoIcon.alpha = isPlaying ? 0 : 1
                }
            }
            .store(in: &subscriptions)
        
        muteButton.publisher(for: .touchUpInside)
            .map { !$0.isSelected }
            .sink { NotificationCenter.default.post(name: Self.unmutedNotification, object: $0) }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: Self.unmutedNotification)
            .map {$0.object as! Bool}
            .sink { [unowned self] unmuted in
                player.isMuted = !unmuted
                muteButton.isSelected = unmuted
                Self.isPlayerMuted = !unmuted
            }
            .store(in: &subscriptions)
    }
    
    private func bindViewModelOutput(){
        
        videoProcessSubscription.removeAll()
        videoView.thumbnail = nil
        videoView.video = nil
        
        updateFrameRatio()
        
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        
        viewModel.output.videoData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                guard let self else { return }
                videoView.video = video
            }
            .store(in: &videoProcessSubscription)
        
        viewModel.output.videoThumbnail
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink { [weak self] image in
                guard let self else { return }
                videoView.thumbnail = image
            }
            .store(in: &videoProcessSubscription)
    }
    
    private func updateFrameRatio(){
        ratioConstraint?.isActive = false
        var ratio = CGFloat(viewModel.contentPixelHeight) / CGFloat(viewModel.contentPixelWidth)
        ratio = max(minRatio, min(ratio, maxRatio))
        ratioConstraint = videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: ratio)
        ratioConstraint.priority = .init(999)
        ratioConstraint.isActive = true
        layoutIfNeeded()
    }
}


extension VideoPreviewCell: UIGestureRecognizerDelegate  {
    @objc private func pinch(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = videoView.frame.size.width / videoView.bounds.size.width
            let newScale = currentScale * sender.scale
            if newScale > 1 {
                guard let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

                overlayView = UIView(frame: currentWindow.bounds)
                overlayView.backgroundColor = .black
                overlayView.alpha = 0
                currentWindow.addSubview(overlayView)

                windowVideoView = VideoView()
                windowVideoView.player = videoView.player
                windowVideoView.frame = videoView.convert(videoView.bounds, to: currentWindow)
                windowVideoView.clipsToBounds = true
                windowVideoView.accessibilityIgnoresInvertColors = true
                windowVideoView.alpha = 0
                currentWindow.addSubview(windowVideoView)

                zoom = windowVideoView.playerLayer.publisher(for: \.isReadyForDisplay)
                    .receive(on: DispatchQueue.main)
                    .filter{ $0 }
                    .sink { [unowned self] _ in
                        print("ready")
                        UIView.animate(withDuration: 0.1,animations: {
                             windowVideoView.alpha = 1
                        }){ _ in
                            videoView.alpha = 0
                        }
                    }
              
                initialGestureInView = sender.location(in: sender.view)
            }
          
        } else if sender.state == .changed {
            guard windowVideoView != nil else { return }
            
            if sender.numberOfTouches < 2 {
                return
            }

            let shift = CGPoint(x: initialGestureInView.x - videoView!.bounds.midX,
                               y: initialGestureInView.y - videoView!.bounds.midY)

            let delta = CGPoint(x: sender.location(in: sender.view).x - initialGestureInView.x,
                               y: sender.location(in: sender.view).y - initialGestureInView.y)

            let currentScale = windowVideoView!.frame.width / windowVideoView!.bounds.width

            let senderScale = (currentScale > 4) ? (sender.scale > 1) ? 1 : sender.scale : sender.scale
            let newScale = currentScale * senderScale
            overlayView.alpha = minOverlayAlpha + (newScale - 1) < maxOverlayAlpha ? minOverlayAlpha + (newScale - 1) : maxOverlayAlpha

            let zoomScale = (newScale * windowVideoView!.frame.width >= videoView.frame.width) ? newScale : currentScale

            let transform = CGAffineTransform.identity
                .translatedBy(x: delta.x, y: delta.y)
                .translatedBy(x: shift.x , y: shift.y )
                .scaledBy(x: zoomScale, y: zoomScale)
                .translatedBy(x: -shift.x , y: -shift.y)
                //.translatedBy(x: centerXDif / zoomScale, y: centerYDif / zoomScale)

            windowVideoView?.transform = transform
            sender.scale = 1

        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
                guard let windowImageView = self.windowVideoView else { return }
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.3, options: .curveEaseInOut) {
                    windowImageView.transform = CGAffineTransform.identity
                    self.overlayView.alpha = 0
                } completion: { _ in
                    windowImageView.removeFromSuperview()
                    self.overlayView.removeFromSuperview()
                    self.videoView.alpha = 1
                    self.overlayView = nil
                    self.windowVideoView = nil
                }
                zoom = nil
        }
    }

}
