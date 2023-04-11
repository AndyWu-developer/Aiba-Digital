//
//  MediaViewModel.swift
//  Aiba Digital
//
//  Created by Andy on 2023/3/27.
//

import Foundation
import AVFoundation
import Combine

enum MediaType {
    case image
    case video
    case gif
    case unknown
}

class MediaViewModel{
   
    struct Input {
        let muteButtonPressed: AnySubscriber<Void,Never>
        let isReadyForDisplay: AnySubscriber<Bool,Never>
    }
    
    struct Output {
        let imageData: AnyPublisher<Data,Never>
        let currentPlayer: AnyPublisher<AVPlayer?,Never>
        let isPlayerMuted: AnyPublisher<Bool,Never>
        let isPlayerPlaying: AnyPublisher<Bool,Never>
        let isPlayerLoading: AnyPublisher<Bool,Never>
        
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    
    @Published var player: AVPlayer? {
        didSet{
            isPlayerPlayingSubject.send(false)
            createNewVideoProccessingChain()
        }
    }
  
    private var subscriptions = Set<AnyCancellable>()
    private var currentPlayerSubscription = Set<AnyCancellable>()

    private var mediaType: MediaType?
    private var mediaURL: String
    private let mediaProvider: MediaProviding = MediaProvider.shared
    
    private let playerAssetSubject = CurrentValueSubject<AVAsset?, Never>(nil)
    private let isPlayerMutedSubject = PassthroughSubject<Bool,Never>()
    private let isPlayerPlayingSubject = PassthroughSubject<Bool,Never>()
    private let isPlayerLoadingSubject = PassthroughSubject<Bool,Never>()
  
    init(url: String, fileExtension: String){
        
        mediaType = fileExtension == ".mp4" ? .video : .image
        mediaURL = url
        if mediaType == .video{
            mediaProvider.fetchVideoAsset(for: mediaURL)
                .compactMap{$0}
                .sink { [weak self] item in
                    self?.playerAssetSubject.value = item
                }.store(in: &subscriptions)
        }
      
        configureViewModelInput()
        configureViewModelOutput()
    }

    private func createNewVideoProccessingChain(){
        currentPlayerSubscription.removeAll()
        playerAssetSubject.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                self?.player?.replaceCurrentItem(with: AVPlayerItem(asset: item))
            }.store(in: &currentPlayerSubscription)
        
        player?.publisher(for: \.isMuted)
            .subscribe(isPlayerMutedSubject)
            .store(in: &currentPlayerSubscription)
        
        player?.publisher(for: \.timeControlStatus)
            .map{ $0 == .playing }
            .subscribe(isPlayerPlayingSubject)
            .store(in: &currentPlayerSubscription)
        
        player?.publisher(for: \.timeControlStatus)
            .map{ $0 == .waitingToPlayAtSpecifiedRate }
            .subscribe(isPlayerLoadingSubject)
            .store(in: &currentPlayerSubscription)
    }

    private func configureViewModelInput(){
     
        let layerReadyToPlay = PassthroughSubject<Bool,Never>()
        
        layerReadyToPlay
            .filter{$0}
            .sink { [weak self] _ in
                self?.player?.play()
            }.store(in: &subscriptions)
        
        let buttonSubject = PassthroughSubject<Void,Never>()
        
        buttonSubject.sink { [weak self] _ in
           self?.player?.isMuted.toggle()
        }.store(in: &subscriptions)
        
        input = Input(muteButtonPressed: buttonSubject.eraseToAnySubscriber(),
                      isReadyForDisplay: layerReadyToPlay.eraseToAnySubscriber())
    }
    
    private func configureViewModelOutput(){
       
        var imageDataPublisher: AnyPublisher<Data,Never>
        if mediaType == .image{
            imageDataPublisher = mediaProvider.fetchImage(for: mediaURL).compactMap{$0}.eraseToAnyPublisher()
        }else{
            imageDataPublisher = mediaProvider.fetchVideoTumbnail(for: mediaURL).compactMap{$0}.eraseToAnyPublisher()
        }
        
        let shouldHideImageSubject = PassthroughSubject<Bool,Never>()
        
        output = Output(imageData: imageDataPublisher,
                       currentPlayer: $player.eraseToAnyPublisher(),
                       isPlayerMuted: isPlayerMutedSubject.eraseToAnyPublisher(),
                       isPlayerPlaying: isPlayerPlayingSubject.eraseToAnyPublisher(),
                       isPlayerLoading: isPlayerLoadingSubject.eraseToAnyPublisher())
    }
    
    deinit{
        print("Media View Model deinit")
    }
}
