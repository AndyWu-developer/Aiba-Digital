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
    private let viewModel: MediaViewModel
    private var ob: NSKeyValueObservation!
   
   
    init(viewModel: MediaViewModel){
        self.viewModel = viewModel
        super.init(frame: .zero)
        customInit()
        playerLayer.videoGravity = .resizeAspectFill
        bindViewModelInput()
        bindViewModelOutput()
    }
    


   
    required init?(coder: NSCoder) {
        fatalError("MediaView should only be instantiated through init(viewModel:)")
    }

    private func customInit(){
        let view = Bundle.main.loadNibNamed("MediaView", owner : self)!.first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func bindViewModelInput(){
        
        let layerReadyToPlay = PassthroughSubject<Bool,Never>()
        ob = playerLayer.observe(\.isReadyForDisplay, options: [.initial,.new]){ _, change in
            guard let ok = change.newValue else { return }
            layerReadyToPlay.send(ok)
        }
        layerReadyToPlay.subscribe(viewModel.input.isReadyForDisplay)
        
        muteButton.publisher(for: .touchUpInside)
            .map{ _ in}
            .subscribe(viewModel.input.muteButtonPressed)
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

        viewModel.output.currentPlayer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                self?.playerLayer.player = player
            }.store(in: &subscriptions)
        
        viewModel.output.isPlayerMuted
            .receive(on: DispatchQueue.main)
            .assign(to: \.isSelected, on: muteButton)
            .store(in: &subscriptions)

        viewModel.output.isPlayerPlaying
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying in
                if isPlaying{
                    self?.imageView.isHidden = true
                    self?.muteButton.isHidden = false
                    self?.playButton.isHidden = true
                }else{
                    self?.playButton.isHidden = false
                    self?.imageView.isHidden = false
                    self?.muteButton.isHidden = true
                }
            }.store(in: &subscriptions)
        
        viewModel.output.isPlayerLoading
            .receive(on: DispatchQueue.main)
            .map{!$0}
            .assign(to: \.isHidden, on: spinningView)
            .store(in: &subscriptions)
    }
}
