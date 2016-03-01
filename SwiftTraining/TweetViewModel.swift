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
import ReactiveCocoa

enum ImageFetcherError: ErrorType {
    
    case FetchError(NSError)
    case InvalidImageData
    
}

typealias ImageFetcher = NSURL -> SignalProducer<UIImage, ImageFetcherError>

final class TweetViewModel {

    private let _tweet: Tweet
    
    var tweetID: String {
        return _tweet.ID
    }
    
    var username: String {
        return _tweet.username
    }
    
    var createdAt: String {
        return _tweet.createdAt.timeAgoSinceNow()
    }
    
    let text: NSAttributedString
    let avatarSignalProducer: SignalProducer<UIImage, ImageFetcherError>
    
    init(tweet: Tweet, imageFetcher: ImageFetcher = defaultImageFetcher) {
        _tweet = tweet
        text = parseEntities(tweet)
        avatarSignalProducer = imageFetcher(tweet.avatarURL)
    }
    
}

private func defaultImageFetcher(imageURL: NSURL) -> SignalProducer<UIImage, ImageFetcherError> {
    return NSURLSession.sharedSession()
        .rac_dataWithRequest(NSURLRequest(URL: imageURL))
        .flatMapError { SignalProducer(error: .FetchError($0)) }
        .flatMap(.Concat) { data, _ -> SignalProducer<UIImage, ImageFetcherError> in
            if let image = UIImage(data: data) {
                return SignalProducer(value: image)
            } else {
                return SignalProducer(error: .InvalidImageData)
            }
    }
}

private func chopOffNonAlphaNumericCharacters(text:String) -> String {
    let nonAlphaNumericCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
    let characterArray = text.componentsSeparatedByCharactersInSet(nonAlphaNumericCharacters)
    return characterArray[0]
}

private func parseEntities(tweet: Tweet) -> NSAttributedString {
//    let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
//    var attrString = NSMutableAttributedString(string: tweet.text, attributes:attrs)
//    
//    if let mentions = try  tweet.entities["user_mentions"] as? [[String : AnyObject]] {
//        attrString = parseMentions(mentions , attributedStr: attrString)
//    }
//
//    if let hashtags = try  tweet.entities["hashtags"] as? [[String : AnyObject]] {
//        attrString = parseHashtags(hashtags, attributedStr: attrString)
//    }
//    
//    return attrString
    let nsText:NSString = tweet.text
    let words:[NSString] = nsText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    
    let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
    
    let attrString = NSMutableAttributedString(string: nsText as String, attributes:attrs)
    
    var bookmark = 0
    for word in words {
        if word.hasPrefix("@") {
            var stringifiedWord = word as String
            let prefix = Array(stringifiedWord.characters)[0]
            stringifiedWord = chopOffNonAlphaNumericCharacters(String(stringifiedWord.characters.dropFirst()))
            
            let prefixedWord = "\(prefix)\(stringifiedWord)"
            let remainingRange = NSRange(location: bookmark, length: (nsText.length - bookmark))
            let matchRange:NSRange = nsText.rangeOfString(prefixedWord, options: NSStringCompareOptions.LiteralSearch, range:remainingRange)
            
            if let _ = stringifiedWord.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()){
                attrString.addAttribute(NSLinkAttributeName, value: "https://twitter.com/"+stringifiedWord, range: matchRange)
            }
            
            bookmark += word.length + 1
            
        } else if word.hasPrefix("#") {
                var stringifiedWord = word as String
                let prefix = Array(stringifiedWord.characters)[0]
                stringifiedWord = chopOffNonAlphaNumericCharacters(String(stringifiedWord.characters.dropFirst()))
                
                let prefixedWord = "\(prefix)\(stringifiedWord)"
                let remainingRange = NSRange(location: bookmark, length: (nsText.length - bookmark))
                let matchRange:NSRange = nsText.rangeOfString(prefixedWord, options: NSStringCompareOptions.LiteralSearch, range:remainingRange)
                
                if let _ = stringifiedWord.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()){
                    attrString.addAttribute(NSLinkAttributeName, value: "https://twitter.com/search?q="+stringifiedWord+"&src=hash", range: matchRange)
            }
            
            bookmark += word.length + 1
        }
    }
    return attrString
}

//func parseMentions(mentions: [[String : AnyObject]], attributedStr: NSMutableAttributedString) -> NSMutableAttributedString {
//    mentions.map {
//        mention in
//        let screenName = mention["screen_name"] as! String
//        let range = attributedStr.string.rangeOfString("@" + screenName)
//        
//        let start = attributedStr.string.startIndex.distanceTo(range!.startIndex)
//        let length = range!.startIndex.distanceTo(range!.endIndex)
//        let nsRange = NSMakeRange(start, length)
//        
//        if let _ = screenName.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()){
//                        attributedStr.addAttribute(NSLinkAttributeName, value: "https://twitter.com/" + screenName, range: nsRange)
//        }
//    }
//    return attributedStr
//}
//
//func parseHashtags(hashtags:[[String : AnyObject]], attributedStr: NSMutableAttributedString) -> NSMutableAttributedString {
//    hashtags.map {
//        hashtag in
//        let hashtagText = hashtag["text"] as! String
//        let range = attributedStr.string.rangeOfString("#" + hashtagText)
//        
//        let start = attributedStr.string.startIndex.distanceTo(range!.startIndex)
//        let length = range!.startIndex.distanceTo(range!.endIndex)
//        let nsRange = NSMakeRange(start, length)
//        
//        if let _ = hashtagText.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()){
//            attributedStr.addAttribute(NSLinkAttributeName, value: "https://twitter.com/" + hashtagText, range: nsRange)
//        }
//    }
//    return attributedStr
//}
