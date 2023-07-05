////
////  SlideViewController.swift
////  Aiba Digital
////
////  Created by Andy Wu on 2023/5/13.
////
//
//import UIKit
//import Combine
//import AVFoundation
//
//class VView: UIView {
//    
//    override static var layerClass: AnyClass { AVPlayerLayer.self }
//    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
//    var player: AVPlayer? {
//        get { playerLayer.player }
//        set { playerLayer.player = newValue }
//    }
//}
//
//class SlideViewController: UIViewController {
//    let mediaURL = "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
//    let mediaURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2FSerial1App.mp4?alt=media&token=ff643f3f-4eee-429e-a8c0-ae49168a1621"
//    private let mediaProvider: MediaProviding = MediaProvider.shared
//    private var subscriptions = Set<AnyCancellable>()
//    let startLabel = UILabel()
//    let slider = UISlider()
//    let player = AVQueuePlayer()
//    let playerView = VView()
//    
//    var canUpdate: Bool = true
//    
//    lazy var isDraggingPublisher = slider.publisher(for: \.isTracking)
//        .removeDuplicates().eraseToAnyPublisher()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .backgroundWhite
//        playerView.player = player
//        startLabel.text = "3:59"
//        startLabel.textColor = .black
//        startLabel.textAlignment = .center
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        startLabel.translatesAutoresizingMaskIntoConstraints = false
//        playerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(slider)
//        view.addSubview(startLabel)
//        view.addSubview(playerView)
//        
//        NSLayoutConstraint.activate([
//            slider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
//            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//            slider.heightAnchor.constraint(equalToConstant: 50),
//            startLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
//            startLabel.trailingAnchor.constraint(equalTo: slider.leadingAnchor, constant: -5),
//            startLabel.heightAnchor.constraint(equalToConstant: 50),
//            startLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            
//            playerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -200),
//            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            playerView.heightAnchor.constraint(equalToConstant: 200),
//        ])
//        
//        let tap = UITapGestureRecognizer()
//        //slider.addGestureRecognizer(tap)
//        tap.publisher().sink { gesture in
//            //if tap on thumb, let slider deal with it
//            guard let slider = gesture.view as? UISlider, !slider.isHighlighted else { return }
//        
//            let tapPoint = gesture.location(in: slider)
//            let trackArea = slider.trackRect(forBounds: slider.bounds).insetBy(dx: 0, dy: -10)
//            if !trackArea.contains(tapPoint){
//                return // did not tap on track
//            }
//            
//            let percent = tapPoint.x / slider.bounds.width
//            let delta = Float(percent) * (slider.maximumValue - slider.minimumValue)
//            let value = slider.minimumValue + delta
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
//                UIView.animate(withDuration: 0.1) {
//                    slider.setValue(value, animated: true)
//                }
//            }
//        }.store(in: &subscriptions)
//        
//        
//        mediaProvider.fetchVideo(for: mediaURL)
//            .receive(on: DispatchQueue.main)
//            .compactMap{$0}
//            .sink { [weak self] video in
//                print("video arrived")
//                guard let self = self else { return }
//                slider.maximumValue = Float(CMTimeGetSeconds(video.duration))
//                player.replaceCurrentItem(with: AVPlayerItem(asset: video))
//                player.play()
//            }.store(in: &subscriptions)
//        
//        
////        player.periodicTimePublisher().map {value in (value:value, date:Date()) }
////            .receive(on: DispatchQueue.main)
////            .combineLatest(isDraggingPublisher)
////            .removeDuplicates { $0.0.date == $1.0.date }
////            .filter{ !$0.1 }
////            .map{ $0.0.value }
////            .sink { [weak self] time in
////                guard let self = self else { return }
////                if player.timeControlStatus != .playing { return }
////                startLabel.text = timeToDurationText(time: time)
////                slider.setValue(Float(CMTimeGetSeconds(time)), animated: true)
////            }.store(in: &subscriptions)
//
//
//        // user dragging
//        slider.publisher(for: .valueChanged)
//            .sink { [weak self] slider in
//                guard let self = self else { return }
//                let seconds = Int64(round(slider.value))
//                let targetTime = CMTimeMake(value: seconds, timescale: 1)
//                startLabel.text = timeToDurationText(time: targetTime)
//                if !slider.isTracking{
//                        player.pause()
//                    player.seek(to: targetTime){ finished in
//                        self.player.play()
//                    }
//                }
//            }.store(in: &subscriptions)
//    }
//    
//    func timeToDurationText(time: CMTime) -> String {
//        let totalSeconds = CMTimeGetSeconds(time)
//        let hours = Int(totalSeconds / 3600)
//        let minutes = Int(totalSeconds.truncatingRemainder(dividingBy: 3600) / 60)
//        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
//
//        if hours > 0 {
//            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
//        } else {
//            return String(format: "%d:%02d", minutes, seconds)
//        }
//    }
//
//}
//
//
//class ViewController: UIViewController  {
//    
//    var player:AVPlayer?
//    var playerItem:AVPlayerItem?
//    var playButton:UIButton?
//    var playbackSlider:UISlider?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .backgroundWhite
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        let mediaURL1 = "https://firebasestorage.googleapis.com/v0/b/aiba-digital.appspot.com/o/test%2FSerial1App.mp4?alt=media&token=ff643f3f-4eee-429e-a8c0-ae49168a1621"
//        
//        
//        let url = URL(string: mediaURL1)
//        let playerItem:AVPlayerItem = AVPlayerItem(url: url!)
//        player = AVPlayer(playerItem: playerItem)
//        
//        let playerLayer=AVPlayerLayer(player: player!)
//        playerLayer.frame=CGRect(x: 0, y: 0, width: 10, height: 50)
//        self.view.layer.addSublayer(playerLayer)
//        
//        playButton = UIButton(type: UIButton.ButtonType.system) as UIButton
//        let xPostion:CGFloat = 50
//        let yPostion:CGFloat = 100
//        let buttonWidth:CGFloat = 150
//        let buttonHeight:CGFloat = 45
//        
//        playButton!.frame = CGRect(x: xPostion, y: yPostion, width: buttonWidth, height: buttonHeight)
//        playButton!.backgroundColor = UIColor.lightGray
//        playButton!.setTitle("Play", for: UIControl.State.normal)
//        playButton!.tintColor = UIColor.black
//        //playButton!.addTarget(self, action: "playButtonTapped:", forControlEvents: .TouchUpInside)
//        playButton!.addTarget(self, action: #selector(self.playButtonTapped(_:)), for: .touchUpInside)
//        
//        self.view.addSubview(playButton!)
//        
//        
//        // Add playback slider
//        
//        playbackSlider = UISlider(frame:CGRect(x: 10, y: 300, width: 300, height: 20))
//        playbackSlider!.minimumValue = 0
//        
//        
//        let duration : CMTime = playerItem.asset.duration
//        let seconds : Float64 = CMTimeGetSeconds(duration)
//        
//        playbackSlider!.maximumValue = Float(seconds)
//        playbackSlider!.isContinuous = false
//        playbackSlider!.tintColor = UIColor.green
//        
//        playbackSlider?.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
//        //playbackSlider!.addTarget(self, action: "playbackSliderValueChanged:", for: .valueChanged)
//        self.view.addSubview(playbackSlider!)
//        
//        
//        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 2), queue: DispatchQueue.main) { (CMTime) -> Void in
//            if self.player!.currentItem?.status == .readyToPlay {
//                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
//                self.playbackSlider!.value = Float ( time );
//            }
//        }
//        
//    }
//    
//    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
//    {
//        
//        let seconds : Int64 = Int64(playbackSlider.value)
//        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
//        
//        player!.seek(to: targetTime)
//        
//        if player!.rate == 0
//        {
//            player?.play()
//        }
//    }
//    
//    
//    @objc func playButtonTapped(_ sender:UIButton)
//    {
//        if player?.rate == 0
//        {
//            player!.play()
//            //playButton!.setImage(UIImage(named: "player_control_pause_50px.png"), forState: UIControlState.Normal)
//            playButton!.setTitle("Pause", for: UIControl.State.normal)
//        } else {
//            player!.pause()
//            //playButton!.setImage(UIImage(named: "player_control_play_50px.png"), forState: UIControlState.Normal)
//            playButton!.setTitle("Play", for: UIControl.State.normal)
//        }
//    }
//    
//}
