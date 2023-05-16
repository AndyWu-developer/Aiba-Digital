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
    func cellDidTap(_ cell: VideoCell)
}


class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlView: UIStackView!
    @IBOutlet weak var playbackSlider: UISlider!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var muteButton: UIButton!
    
    private let player = AVPlayer()
    weak var delegate : VideoCellDelegate?
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
        scrollView.decelerationRate = .fast
        let configuration = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(systemName: "circle.fill", withConfiguration: configuration)
        playbackSlider.setThumbImage(image, for: .normal)
        contentView.addGestureRecognizer(singleTap)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
        configureZoomScale(for: scrollView)
        centerZoomedView(in: scrollView) //setting zoom scale wont call viewDIDZoom if setting the same zoomscale?
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
        player.pause()
    }
 
    func configure(with viewModel: VideoCellViewModel, index : Int){
        //layoutIfNeeded() //Key!!! or roation would look weird
        subscriptions.removeAll()
        configureButtonActions()
        videoView.thumbnailImage = nil
        videoView.video = nil
     
        viewModel.output.mediaDimensions
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] in
                guard let self else { return }
                videoView.bounds.size = $0
                scrollView.contentSize = videoView.bounds.size
                configureZoomScale(for: scrollView)
            }
            .store(in: &subscriptions)
        
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        viewModel.output.imageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink { [weak self] image in
                self?.videoView.thumbnailImage = image
            }.store(in: &subscriptions)

        viewModel.output.videoData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                guard let self else { return }
                videoView.video = video
                totalTimeLabel.text = timeToDurationText(time: video.duration)
                playbackSlider.maximumValue = Float(CMTimeGetSeconds(video.duration))
                print("cell \(index) receieved video")
            }
            .store(in: &subscriptions)
        
        
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
        
        singleTap.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    self.playButton.alpha = self.playButton.alpha == 0 ? 1 : 0
                    self.playbackControlView.alpha = self.playbackControlView.alpha == 0 ? 1 : 0
                }
            }.store(in: &subscriptions)
 
        
        muteButton.publisher(for: .touchUpInside)
            .map{_ in}
            .sink{ [weak self] in
                self?.player.isMuted.toggle()
            }.store(in: &subscriptions)
    }
    
    //Key Function1
    func configureZoomScale(for scrollView: UIScrollView){
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        let widthScale = scrollView.bounds.width / zoomedView.bounds.width
        let heightScale = scrollView.bounds.height / zoomedView.bounds.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 4
        scrollView.zoomScale = minScale
    }
    
    //Key Function2
    private func centerZoomedView(in scrollView: UIScrollView){
        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
        let xOffset = max(0, (scrollView.bounds.width - zoomedView.frame.width) / 2)
        let yOffset = max(0, (scrollView.bounds.height - zoomedView.frame.height) / 2)
        zoomedView.frame.origin = CGPoint(x: xOffset, y: yOffset)
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

extension VideoCell: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return videoView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.bouncesZoom = scrollView.zoomScale > scrollView.minimumZoomScale
    }
       
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomedView(in: scrollView)
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
    }
}

