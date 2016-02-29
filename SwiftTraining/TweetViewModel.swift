//
//  TweetViewModel.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/29/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit
import DateTools

class TweetViewModel {

    let tweeterDateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
    let tweet: Tweet
    
    var avatarURL: NSURL!
    var user: String!
    var time: String!
    var text: String!
    
    init(tweet:Tweet) {
        self.tweet = tweet
        initializeProperties();
    }
    
    func initializeProperties() {
        print(self.tweet.avatar)
        avatarURL = NSURL(string:self.tweet.avatar)
        user = self.tweet.user
        text = self.tweet.text
        self.initializeDate()
    }
    
    func initializeDate() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = tweeterDateFormat
        let createdAt = dateFormatter.dateFromString(self.tweet.time)
        self.time = createdAt?.timeAgoSinceNow()
    }
}