//
//  TwitterTableViewModel.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/26/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa

class TwitterTableViewModel {
    var dataSource = [TweetViewModel]()
    var page = 0
    var twitterRepository = TwitterRepositoryImplementation.init()
    var loaded: MutableProperty<Bool>
    var refreshing: MutableProperty<Bool>!
    
    init() {
        loaded = MutableProperty.init(false)
        refreshing = MutableProperty.init(false)
        fetchLineTime()
    }
    
    func fetchLineTime() {
        loaded.value = false
        twitterRepository.fetchHomeTimeLine(NSNumber.init(integer: page)).start { event in
            switch event {
            case .Next(let tweets):
                    self.dataSource.appendContentsOf(tweets.map { TweetViewModel(tweet: $0) })
                    self.page = self.page + 1
            case .Failed(let error): print("Error fetching tweets \(error)")
            default: break
            }
            print ("PageViewModel \(self.page)")
            self.loaded.value = true
        }
    }
    
    func refresh() {
        self.page = 0
        refreshing.value = true
        fetchLineTime()
        refreshing.value = false
    }
    
    func elementsCount() -> Int {
        return self.dataSource.count
    }
    
    func elementForIndexPath (indexPath: NSIndexPath) -> TweetViewModel {
        return self.dataSource[indexPath.row]
    }    
}
