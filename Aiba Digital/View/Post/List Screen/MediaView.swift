//
//  MediaView.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/26.
//

import UIKit
import AVFoundation
import Combine

class MediaView: UIView {
 
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinningView: UIView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    override static var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    private var subscriptions = Set<AnyCancellable>()
    private var videoPipelineSubscriptions = Set<AnyCancellable>()
    
    private let viewModel: MediaViewModel
   
    weak var player: AVPlayer?{
        didSet{
            createNewVideoPipeline()
        }
    }
    
    private func createNewVideoPipeline(){
        videoPipelineSubscriptions.removeAll()
        
        playerLayer.player = player
        
        viewModel.output.videoAsset
            .sink { [weak self] in
                self?.player?.replaceCurrentItem(with: AVPlayerItem(asset: $0))
            }.store(in: &videoPipelineSubscriptions)
        
        player?.publisher(for: \.isMuted)
            .assign(to: \.isSelected, on: muteButton)
            .store(in: &videoPipelineSubscriptions)
    }
    
    init(viewModel: MediaViewModel){
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        playerLayer.videoGravity = .resizeAspectFill
        bindViewModelOutput()
    }
    
    required init?(coder: NSCoder) {
        fatalError("MediaView should only be instantiated through init(viewModel:)")
    }

    private func setupViews(){
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        let view = Bundle.main.loadNibNamed("MediaView", owner : self)!.first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        let aspectRatio = viewModel.mediaContentSize.width / viewModel.mediaContentSize.height
        let ratioConstraint = widthAnchor.constraint(equalTo: heightAnchor, multiplier: aspectRatio)
        ratioConstraint.priority = .defaultHigh
        ratioConstraint.isActive = true
    }

    private func configure(){
        
        playerLayer.publisher(for: \.isReadyForDisplay)
            .sink { [weak self] isReady in
                self?.imageView.isHidden = isReady
                self?.muteButton.isHidden = !isReady
            }.store(in: &subscriptions)
        
        muteButton.publisher(for: .touchUpInside)
            .map{_ in}
            .sink{ [weak self] in
                self?.player?.isMuted.toggle()
            }.store(in: &subscriptions)
    }
 
    private func bindViewModelOutput(){

        viewModel.output.imageData
             .removeDuplicates()
             .receive(on: DispatchQueue(label:"Serial Background Queue"))
             .compactMap(UIImage.init(data:))
             .map{ $0.scaledDown(into: UIScreen.main.bounds.size) }
             .receive(on: DispatchQueue.main)
             .assign(to: \.image, on: imageView)
             .store(in: &subscriptions)
    }
}
