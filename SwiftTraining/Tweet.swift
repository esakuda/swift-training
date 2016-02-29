//
//  TwitModel.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import ReactiveCocoa

class Tweet: NSObject {
    var user: String!
    var avatar: String!
    var text: String!
    var time: String!
    
    init(dictionary: NSDictionary) {
        super.init()
        self.user = dictionary.objectForKey("user")?.objectForKey("name") as? String
        self.text = dictionary.objectForKey("text") as? String
        self.avatar = dictionary.objectForKey("user")?.objectForKey("profile_image_url") as? String
        print(self.avatar)
        self.time = dictionary.objectForKey("created_at") as? String
    }
    
    class func initWithArray (JSONArray: [NSDictionary]) -> [Tweet] {
    return JSONArray.map({
            dictionary in
            return Tweet.init(dictionary: dictionary)
        })
    }
    
}
