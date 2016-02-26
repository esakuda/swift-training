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
    var dataSource = [TweetModel]()
    var page = 0
    var twitterRepository = TwitterRepositoryImplementation.init()
    
    init() {
        fetchLineTime()
    }
    
    func fetchLineTime() -> SignalProducer<Array<TweetModel>, NSError> {
        return twitterRepository.fetchHomeTimeLine("euge__s")
    }
    
    func refresh() -> SignalProducer<Array<TweetModel>, NSError> {
        self.page = 0
        return fetchLineTime()
    }
    
    func elementsCount() -> Int {
        return self.dataSource.count
    }
    
    func elementForIndexPath (indexPath: NSIndexPath) -> TweetModel {
        return self.dataSource[indexPath.row]
    }
    
}