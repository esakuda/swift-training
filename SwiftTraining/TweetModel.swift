//
//  TwitModel.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa

class TweetModel: NSObject {
    var user: String!
    var avatarURL: NSURL!
    var text: String!
    var time: NSDate!
    
    let tweeterDateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
    
    init(dictionary: NSDictionary) {
        super.init()
        self.user = dictionary.objectForKey("user")?.objectForKey("name") as? String
        self.text = dictionary.objectForKey("text") as? String
        let avatarURLString = dictionary.objectForKey("text") as? String
        self.avatarURL = NSURL.init(fileURLWithPath:avatarURLString!)
        let createdAt = dictionary.objectForKey("created_at") as? String
        self.initializeDate(createdAt!)
    }
    
    class func initWithArray (JSONArray: Array<NSDictionary>) -> Array<TweetModel> {
    return JSONArray.map({
            dictionary in
            return TweetModel.init(dictionary: dictionary)
        })
    }
    
    func initializeDate(dateString: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = tweeterDateFormat
        self.time = dateFormatter.dateFromString(dateString)
    }
}
