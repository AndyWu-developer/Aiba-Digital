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
    private let maxRatio: CGFloat = 5/4
    private let minRatio: CGFloat = 1/3
    private var ratioConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var muteButton: UIButton!
    
    let player = AVPlayer()
    var viewModel: VideoViewModel!{
        didSet{
            bindViewModelOutput()
        }
    }
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
    
    
    func bindViewModelOutput(){
        videoProcessSubscription.removeAll()
        
        videoView.thumbnailImage = nil
        videoView.video = nil
        
        ratioConstraint?.isActive = false
        var ratio = CGFloat(viewModel.contentPixelHeight) / CGFloat(viewModel.contentPixelWidth)
        ratio = max(minRatio, min(ratio, maxRatio))
        ratioConstraint = videoView.heightAnchor.constraint(equalTo: videoView.widthAnchor, multiplier: ratio)
        ratioConstraint.priority = .init(999)
        ratioConstraint.isActive = true
        layoutIfNeeded()
        
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        
        viewModel.output.videoData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                guard let self else { return }
                videoView.video = video
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
