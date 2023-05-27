//
//  VideoCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/15.
//

import UIKit
import Combine
import AVFoundation

protocol VideoCellDelegate: AnyObject{
    func cellDidTap(_ cell: VideoDetailCell)
    func cellDidZoom(_ cell: VideoDetailCell)
    func cellDidEndZoom(_ cell: VideoDetailCell)
}

class VideoDetailCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlView: UIStackView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    private var currentIsLandscape = false
    private var ratioConstraint: NSLayoutConstraint!
    private let player = AVPlayer()
    weak var delegate: VideoCellDelegate?
    private var hasZoomedIn = false
    private var videoProcessSubscription = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    lazy var isDraggingPublisher = playbackSlider.publisher(for: \.isTracking)
        .removeDuplicates().eraseToAnyPublisher()
    
    private let singleTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoView.player = player
        player.isMuted = true
        scrollView.decelerationRate = .fast
        scrollView.maximumZoomScale = 4
        configurePlayerUI()
        configureButtonActions()
        configureGestures()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let isLandscape = bounds.width > bounds.height
        if isLandscape != currentIsLandscape {
            currentIsLandscape = isLandscape
            playbackControlView.alpha = isLandscape ? 0 : 1
        }
        bottomConstraint.constant = isLandscape ? 0 : -120
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoProcessSubscription.removeAll()
        player.pause()
    }
    
    func configure(with viewModel: VideoCellViewModel, index : Int){
        
        videoProcessSubscription .removeAll()
        
        videoView.thumbnailImage = nil //Wrap in DispatchQueue.main?
        videoView.video = nil
        
        viewModel.output.videoDimensions
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] size in
                guard let self else { return }
                ratioConstraint?.isActive = false
                ratioConstraint = videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: CGFloat(size.width) / CGFloat(size.height))
                ratioConstraint.isActive = true
                layoutIfNeeded()
            }
            .store(in: &videoProcessSubscription)
        
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        viewModel.output.thumbnailData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink { [weak self] image in
                self?.videoView.thumbnailImage = image
            }.store(in: &videoProcessSubscription)
        
        viewModel.output.videoData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                guard let self else { return }
                videoView.video = video
                totalTimeLabel.text = "-" + timeToDurationText(time: video.duration)
                playbackSlider.maximumValue = Float(CMTimeGetSeconds(video.duration))
                print("cell \(index) receieved video")
            }
            .store(in: &videoProcessSubscription)
    }
    
    func playVideo(){
        videoView.shouldAutoPlay = true
    }
    
    func stopVideo(){
        videoView.shouldAutoPlay = false
    }
    
    private func configureButtonActions(){
        
        playButton.publisher(for: .touchUpInside)
            .sink { [weak self] button in
                self?.videoView.shouldAutoPlay.toggle()
                button.isSelected.toggle()
            }.store(in: &subscriptions)
        
        muteButton.publisher(for: .touchUpInside)
            .sink{ [weak self] _ in
                guard let self = self else { return }
                player.isMuted.toggle()
                muteButton.isSelected.toggle()
            }.store(in: &subscriptions)
    }
    
    private func configureGestures(){
        
        contentView.addGestureRecognizer(singleTap)
        singleTap.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                delegate?.cellDidTap(self)
                UIView.animate(withDuration: 0.2) {
                    self.playbackControlView.alpha = self.playbackControlView.alpha == 0 ? 1 : 0
                }
            }.store(in: &subscriptions)
    }
    
    
    private func configurePlayerUI() {
        
        player.periodicTimePublisher().map {value in (value:value, date:Date()) }
            .receive(on: DispatchQueue.main)
            .combineLatest(isDraggingPublisher)
            .removeDuplicates { $0.0.date == $1.0.date }
            .filter{ !$0.1 }
            .map{ $0.0.value }
            .sink { [weak self] time in
                guard let self = self else { return }
                if player.timeControlStatus != .playing { return }
                currentTimeLabel.text = timeToDurationText(time: time)
                playbackSlider.setValue(Float(CMTimeGetSeconds(time)), animated: false)
            }.store(in: &subscriptions)
        
        // user dragging
        playbackSlider.publisher(for: .valueChanged)
            .sink { [weak self] slider in
                guard let self = self else { return }
                let seconds = Int64(round(slider.value))
                let targetTime = CMTimeMake(value: seconds, timescale: 1)
                currentTimeLabel.text = timeToDurationText(time: targetTime)
                if !slider.isTracking{
                        player.pause()
                    player.seek(to: targetTime){ finished in
                        self.player.play()
                    }
                }
            }.store(in: &subscriptions)
    }

    private func timeToDurationText(time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds / 3600)
        let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

extension VideoDetailCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return videoView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > scrollView.minimumZoomScale, !hasZoomedIn {
            playbackControlView.alpha = 0
            hasZoomedIn = true
            delegate?.cellDidZoom(self)
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale == scrollView.minimumZoomScale{
            hasZoomedIn = false
            delegate?.cellDidEndZoom(self)
        }
    }
}

