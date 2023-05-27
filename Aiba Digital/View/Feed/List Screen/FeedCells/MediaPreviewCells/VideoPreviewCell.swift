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

    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var muteButton: UIButton!
    
    let player = AVPlayer()
   
    private var videoProcessSubscription = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoView.player = player
        player.isMuted = true
        configureButtonActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        videoProcessSubscription.removeAll()
        player.pause()
    }
    
    func configure(with viewModel: VideoCellViewModel, index : Int){
        
        videoProcessSubscription .removeAll()
        
        videoView.thumbnailImage = nil
        videoView.video = nil
        
//        viewModel.output.videoDimensions
//            .receive(on: DispatchQueue.main)
//            .sink{ [weak self] size in
//                guard let self else { return }
//                ratioConstraint?.isActive = false
//                ratioConstraint = videoView.widthAnchor.constraint(equalTo: videoView.heightAnchor, multiplier: CGFloat(size.width) / CGFloat(size.height))
//                ratioConstraint.isActive = true
//                layoutIfNeeded()
//            }
//            .store(in: &videoProcessSubscription)
        
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        
        viewModel.output.videoData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                guard let self else { return }
                videoView.video = video
                playVideo() // test
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
        
        muteButton.publisher(for: .touchUpInside)
            .sink{ [weak self] _ in
                guard let self = self else { return }
                player.isMuted.toggle()
                muteButton.isSelected.toggle()
            }.store(in: &subscriptions)
    }
}
