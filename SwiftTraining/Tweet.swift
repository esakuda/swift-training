//
//  TwitModel.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa

typealias JSON = [String : AnyObject]

struct TweetEntity {
    
    let startIndex: Int
    let endIndex: Int
    let entityURL: NSURL
    
}

struct Tweet {
    
    let ID: String
    let username: String
    let avatarURL: NSURL
    let text: String
    let createdAt:  NSDate
    let hashtags: [TweetEntity]
    let userMentions: [TweetEntity]
    
}

protocol Deserializable {
    
    static func fromJSON(tweet: JSON) -> Self?
    
}

//func foo<D: Deserializable where D.Object == Tweet>(d: D) -> Tweet {
//    return d.fromJSON([:])
//}

extension Tweet: Deserializable {
    
    static func fromJSON(tweet: JSON) -> Tweet? {
        
        let ID = tweet["id_str"] as! String
        let username = tweet["user"]!["name"] as! String
        let text = tweet["text"] as! String
        let avatarURL = tweet["user"]!["profile_image_url"] as! String
        let createdAt = tweet["created_at"] as! String
        let entities = tweet["entities"] as! JSON
        let hashtags = entities["hashtags"] as! [JSON]
        let userMentions = entities["user_mentions"] as! [JSON]
        
        return Tweet(
            ID: ID,
            username: username,
            avatarURL: NSURL(string: avatarURL)!,
            text: text,
            createdAt: NSDate.parseTwitterDate(createdAt)!,
            hashtags: hashtags.flatMap { TweetEntity.fromJSON($0) },
            userMentions: userMentions.flatMap { TweetEntity.fromJSON($0) }
        )
    }
    
}

extension TweetEntity: Deserializable {
    
    static func fromJSON(entity: JSON) -> TweetEntity? {
        let indices = entity["indices"] as! [Int]
        return entityURL(entity)
            .flatMap { NSURL(string: $0) }
            .map { TweetEntity(startIndex: indices[0], endIndex: indices[1], entityURL: $0) }
    }
    
    private static func entityURL(entity: JSON) -> String? {
        switch (entity["text"] as? String, entity["screen_name"] as? String) {
        case (.Some(let hashtag), .None): return "https://twitter.com/hashtag/\(hashtag)"
        case (.None, .Some(let user)): return "https://twitter.com/\(user)"
        default: return .None
        }
    }
    
}

private extension NSDate {
    
    static func parseTwitterDate(date: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        return dateFormatter.dateFromString(date)
    }
    
}
