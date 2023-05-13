//
//  MediaCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/9.
//

import UIKit
import AVFoundation
import Combine

class MediaCell: UICollectionViewCell {

    var player: AVPlayer = AVPlayer()
    
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        return scrollView
    }()
    
    private let mediaView = VideoView()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.4)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular ,scale: .default)
        button.setImage(UIImage(systemName: "pause.fill")?.withConfiguration(symbolConfig).withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(UIImage(systemName: "play.fill")?.withConfiguration(symbolConfig).withTintColor(.white, renderingMode: .alwaysOriginal), for: .selected)
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    
    private lazy var muteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black.withAlphaComponent(0.4)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular ,scale: .default)
        button.setImage(UIImage(systemName: "speaker.wave.2.fill")?.withConfiguration(symbolConfig).withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        button.setImage(UIImage(systemName: "play.fill")?.withConfiguration(symbolConfig).withTintColor(.white, renderingMode: .alwaysOriginal), for: .selected)
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    
    private lazy var singleTapGesture: UIGestureRecognizer = {
        let singleTap = UITapGestureRecognizer()
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        return singleTap
    }()
    
    private var subscriptions = Set<AnyCancellable>()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mediaView.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        scrollView.addSubview(mediaView)
        contentView.addSubview(scrollView)
        mediaView.player = player
      
        playButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        playButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        mediaView.addGestureRecognizer(singleTapGesture)
        contentView.addSubview(playButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
        player.pause()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = contentView.bounds
        configureZoomScale(for: scrollView)
        //centerZoomedView(in: scrollView)
    }
 
    func configure(with viewModel: MediaCellViewModel, index : Int){
        //layoutIfNeeded() //Key!!! or roation would look weird
        subscriptions.removeAll()
        configureButtonActions()
        mediaView.image = nil
        mediaView.video = nil
     
        viewModel.output.mediaDimensions
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] in
                guard let self else { return }
                mediaView.bounds.size = $0
                scrollView.contentSize = mediaView.bounds.size
                configureZoomScale(for: scrollView)
            }
            .store(in: &subscriptions)
        
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        viewModel.output.imageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink { [weak self] image in
                self?.mediaView.image = image
            }.store(in: &subscriptions)

        viewModel.output.videoData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] video in
                guard let self else { return }
                mediaView.video = video
                print("cell \(index) receieved video")
            }
            .store(in: &subscriptions)
    }

    func playVideo(){
        mediaView.shouldAutoPlay = true
    }
    
    func stopVideo(){
        mediaView.shouldAutoPlay = false
    }
    
    private func configureButtonActions(){
        playButton.publisher(for: .touchUpInside)
            .sink { [weak self] button in
                self?.mediaView.shouldAutoPlay.toggle()
                button.isSelected.toggle()
            }.store(in: &subscriptions)
        
        singleTapGesture.publisher()
            .sink { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.2) {
                    self.playButton.alpha = self.playButton.alpha == 0 ? 1 : 0
                }
            }.store(in: &subscriptions)
        //scrollView.gestureRecognizers?.forEach{ $0.require(toFail: singleTapGesture)}
        
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
}

extension MediaCell: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.bouncesZoom = scrollView.zoomScale > scrollView.minimumZoomScale
    }
       
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomedView(in: scrollView)
        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
}

extension MediaCell: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if scrollView.gestureRecognizers!.contains(otherGestureRecognizer){
            print("gotcha")
        }
        
        if otherGestureRecognizer.view == playButton{
            print("Button tapped")
        }
      
        
        return true
    }
    
    
}
