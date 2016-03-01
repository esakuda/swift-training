//
//  TwitterTableViewModel.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/26/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa

final class TwitterTableViewModel {
    
    private(set) var fetchTimeline: Action<Bool, [TweetViewModel], NSError>! = nil
    
    private let _tweets = MutableProperty<[TweetViewModel]>([])
    let tweets: AnyProperty<[TweetViewModel]>
    
    private let _lastTweetID = MutableProperty<String?>(Optional.None)
    
    private let _twitterRepository: TwitterRepository
    
    var tweetsCount: Int {
        return _tweets.value.count
    }
    
    init(twitterRepository: TwitterRepository = TwitterRepository()) {
        _twitterRepository = twitterRepository
        tweets = AnyProperty(initialValue: [], signal: _tweets.signal)
        fetchTimeline = Action { [unowned self] reload in
            let maxID = reload ? Optional.None : self._lastTweetID.value
            return twitterRepository.fetchHomeTimeLine(maxID).map { tweets in
                tweets.map{ TweetViewModel(tweet: $0) }
            }
            .observeOn(UIScheduler())
        }
        _tweets <~ fetchTimeline.values
        _lastTweetID <~ _tweets.signal.map { $0.last?.tweetID }
    }
    
    subscript(index: Int) -> TweetViewModel {
        return _tweets.value[index]
    }
    
}
