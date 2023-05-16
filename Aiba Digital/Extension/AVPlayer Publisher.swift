//
//  AVPlayer Publisher.swift
//  Aiba Digital
//
//  Created by Andy Wu on 2023/5/13.
//

import AVFoundation
import Combine

// simply use
// player.periodicTimePublisher()
//   .receive(on: RunLoop.main)
//   .assign(to: \SomeClass.elapsedTime, on: someInstance)
//   .store(in: &cancelBag)
// seconds: 0.5 default
extension AVPlayer {
    func periodicTimePublisher(forInterval interval: CMTime = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))) -> AnyPublisher<CMTime, Never> {
        Publisher(self, forInterval: interval)
            .eraseToAnyPublisher()
    }
}

fileprivate extension AVPlayer {
    private struct Publisher: Combine.Publisher {
    
        typealias Output = CMTime
        typealias Failure = Never
    
        unowned let player: AVPlayer
        var interval: CMTime

        init(_ player: AVPlayer, forInterval interval: CMTime) {
            self.player = player
            self.interval = interval
        }

        func receive<S>(subscriber: S) where S : Subscriber, Publisher.Failure == S.Failure, Publisher.Output == S.Input {
            let subscription = CMTime.Subscription(subscriber: subscriber, player: player, forInterval: interval)
            subscriber.receive(subscription: subscription)
        }
    }
}
// S = SubscriberType
fileprivate extension CMTime {
    final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == CMTime, S.Failure == Never {

        weak var player: AVPlayer? = nil
        var observer: Any? = nil

        init(subscriber: S, player: AVPlayer, forInterval interval: CMTime) {
            self.player = player
            observer = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { time in
                _ = subscriber.receive(time)
            }
        }

        func request(_ demand: Subscribers.Demand) {
            // We do nothing here as we only want to send events when they occur.
            // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
        }

        func cancel() {
            if let observer = observer {
                player?.removeTimeObserver(observer)
            }
            observer = nil
            player = nil
        }
    }
}
