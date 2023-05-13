//
//  MediaCell.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/9.
//

import UIKit
import AVFoundation
import Combine

class TestCell: UICollectionViewCell {

    var player: AVPlayer = AVPlayer()
    private var ratioConstraint : NSLayoutConstraint?
    private lazy var scrollView : TestScrollView = {
        let scrollView = TestScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        return scrollView
    }()
    
    private let mediaView = VideoView()
    private var subscriptions = Set<AnyCancellable>()
    var contentSizeWidthConstraint: NSLayoutConstraint!
    var contentSizeHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mediaView.player = player
        mediaView.clipsToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(mediaView)
        contentView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: mediaView.topAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor),
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: mediaView.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: mediaView.trailingAnchor),
            mediaView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor),
            mediaView.heightAnchor.constraint(lessThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
        player.pause()
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        scrollView.configureZoomScale(for: scrollView)
//        super.layoutSubviews()
//    }
//

    
    func configure(with viewModel: MediaCellViewModel, index : Int){
        layoutIfNeeded() //Key!!! or roation would look weird
        
        subscriptions.removeAll()
        mediaView.image = nil
        mediaView.video = nil
     
        viewModel.output.mediaDimensions
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] in
                guard let self else { return }
                ratioConstraint?.isActive = false
                let ratio = $0.height / $0.width
                ratioConstraint = mediaView.heightAnchor.constraint(equalTo: mediaView.widthAnchor, multiplier: ratio)
                ratioConstraint?.isActive = true
//               // scrollView.contentSize = $0
                scrollView.layoutIfNeeded()
                scrollView.maximumZoomScale = 4
//                scrollView.configureZoomScale(for: scrollView)
//              //  configureZoomScale(for: scrollView)
//               
            }
            .store(in: &subscriptions)
//
        // Attempted to read an unowned reference but the object was already deallocated, use weak self instead of unowned self
        viewModel.output.imageData
            .receive(on: DispatchQueue.main)
            .map(UIImage.init(data:))
            .sink { [weak self] image in
                self?.mediaView.image = image
            }.store(in: &subscriptions)

//        viewModel.output.videoData
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] video in
//                guard let self else { return }
//                mediaView.video = video
//                print("cell \(index) receieved video")
//            }
//            .store(in: &subscriptions)
    }

    func playVideo(){
        mediaView.shouldAutoPlay = true
    }
    
    func stopVideo(){
        mediaView.shouldAutoPlay = false
    }
    
    //Key Function1
//    private func configureZoomScale(for scrollView: UIScrollView){
//        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
//        layoutIfNeeded()
//        let widthScale = scrollView.bounds.width / zoomedView.bounds.width
//        let heightScale = scrollView.bounds.height / zoomedView.bounds.height
//
//        let minScale = min(widthScale, heightScale)
//        print(minScale)
//        scrollView.minimumZoomScale = minScale
//        scrollView.maximumZoomScale = minScale * 4
//        scrollView.zoomScale = minScale
//
//    }
    
    //Key Function2
//    private func centerZoomedView(in scrollView: UIScrollView){
//        guard let zoomedView = scrollView.delegate?.viewForZooming?(in: scrollView) else { return }
//        let xOffset = max(0, (scrollView.bounds.width - zoomedView.frame.width) / 2)
//        let yOffset = max(0, (scrollView.bounds.height - zoomedView.frame.height) / 2)
//        scrollView.contentInset = .init(top: yOffset , left: xOffset, bottom: yOffset, right: xOffset)
//    }
}

extension TestCell: UIScrollViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mediaView
    }
    
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        centerZoomedView(in: scrollView)
//        scrollView.isScrollEnabled = scrollView.zoomScale > scrollView.minimumZoomScale
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
    
}
