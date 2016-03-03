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
    
    private(set) var fetchTimeline: Action<AnyObject, [TweetViewModel], NSError>! = nil
    private(set) var fetchTimelineNextPage: Action<AnyObject, [TweetViewModel], NSError>! = nil
    
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
        fetchTimeline = Action { [unowned self] _ in self.fetchHomeTimeline() }
        fetchTimelineNextPage = Action { [unowned self] _ in self.fetchHomeTimeline(self._lastTweetID.value) }
        
        _tweets <~ fetchTimeline.values
        fetchTimelineNextPage.values.observeNext { self._tweets.value += $0 }
        
        _lastTweetID <~ _tweets.signal.map { $0.last?.tweetID }
        
    }
    
    subscript(index: Int) -> TweetViewModel {
        return _tweets.value[index]
    }
    
}

private extension TwitterTableViewModel {
    
    func fetchHomeTimeline(maxID: String? = Optional.None) -> SignalProducer<[TweetViewModel], NSError> {
        return _twitterRepository.fetchHomeTimeLine(maxID).map { tweets in
            tweets.map{ TweetViewModel(tweet: $0) }
        }
        .observeOn(UIScheduler())
    }
    
}
