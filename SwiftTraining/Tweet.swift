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
typealias Entity = String

struct Tweet {
    
    let ID: String
    let username: String
    let avatarURL: NSURL
    let text: String
    let createdAt:  NSDate
    let entities: [String: [AnyObject]]
    
}

extension Tweet {
    
    static func fromJSON(tweet: JSON) -> Tweet {
        let ID = tweet["id_str"] as! String
        let username = tweet["user"]!["name"] as! String
        let text = tweet["text"] as! String
        let avatarURL = tweet["user"]!["profile_image_url"] as! String
        let createdAt = tweet["created_at"] as! String
        let entities = tweet["entities"] as! [String : [AnyObject]]
        return Tweet(ID: ID, username: username, avatarURL: NSURL(string: avatarURL)!, text: text, createdAt: NSDate.parseTwitterDate(createdAt)!, entities: entities)
    }
    
}

private extension NSDate {
    
    static func parseTwitterDate(date: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        return dateFormatter.dateFromString(date)
    }
    
}
