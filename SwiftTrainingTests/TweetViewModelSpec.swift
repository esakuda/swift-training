//
//  SwiftTrainingTests.swift
//  SwiftTrainingTests
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Quick
import Nimble
import Twitter
import ReactiveCocoa
import UIKit

@testable import SwiftTraining

final class TweetViewModelSpec: QuickSpec {
    
    override func spec() {
        
        var tweetViewModel: TweetViewModel!
        var tweet: Tweet!

        beforeEach {
//            let fixtureFile = NSBundle.mainBundle().pathForResource("Tweet", ofType: "json")
//            let data = NSData(contentsOfFile: fixtureFile!)
//            do {
//                if let tweetJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? JSON {
            let tweetJSONWithMentions = [
                "created_at": "Tue Aug 28 21:08:15 +0000 2012",
                "id_str": "240556426106372096",
                "entities": [
                    "hashtags": [[
                        "text": "lecturing",
                        "indices": [
                            0,
                            9
                        ],
                    ]],
                    "user_mentions": [[
                    "name": "Cal",
                    "id_str": "17445752",
                    "id": 17445752,
                    "indices": [
                        61,
                        65
                    ],
                    "screen_name": "Cal"
                    ]]
                ],
                "text": "#lecturing at the \"analyzing big data with twitter\" class at @cal with @othman  http://t.co/bfj7zkDJ",
                "id": 240556426106372096,
                "user": [
                    "name": "Raffi Krikorian",
                    "profile_image_url": "http://a0.twimg.com/profile_images/1270234259/raffi-headshot-casual_normal.png"
                ]
            ] as JSON
                    tweet = Tweet.fromJSON(tweetJSONWithMentions)!
                    tweetViewModel = TweetViewModel.init(tweet:tweet , imageFetcher: imageFetcherTester)
//                }
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
        }
        
        describe(".tweetID") {
            it("Returns tweetID") {
                expect(tweetViewModel.tweetID).to(equal("240556426106372096"))
            }
        }
        
        describe(".username") {
            it("returns username") {
                expect(tweetViewModel.username).to(equal("Raffi Krikorian"))
            }
        }
        
        describe(".createdAt") {
            it("returns a string with timeAgo format") {
                expect(tweetViewModel.createdAt).to(equal("3 years ago"))
            }
        }
        
        describe(".text") {
            it("returns AttributedString with hashtags and mentions links setted") {
                let range = NSMakeRange(0, tweetViewModel.text.length)
                tweetViewModel.text.enumerateAttribute(NSLinkAttributeName, inRange: range, options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired, usingBlock: {attribute, range,_ in
                    let link = attribute as? NSURL
                    if range.length <= 4 {
                        expect(link!.isEqual(tweet.hashtags.first?.entityURL))
                    } else if range.length <= 10 {
                        expect(link!.isEqual(tweet.userMentions.first?.entityURL))
                    }
                })
            }
            
        }
        
        describe(".avatarSignalProducer") {
            it("returns a signalProducer with the avatar image as value") {
                tweetViewModel.avatarSignalProducer.startWithNext{ image in
                    let realImageData = UIImagePNGRepresentation(UIImage(named: "avatar_placeholder")!)
                    let viewModelImageData = UIImagePNGRepresentation(image)
                    expect(realImageData?.isEqualToData(viewModelImageData!))
                }
            }
        }
        
    }
    
}

private func imageFetcherTester(imageURL: NSURL) -> SignalProducer<UIImage, ImageFetcherError> {
    let image = UIImage(named: "avatar_placeholder")!
    let producer:SignalProducer<UIImage, ImageFetcherError> = SignalProducer(value: image)
    return producer
}
