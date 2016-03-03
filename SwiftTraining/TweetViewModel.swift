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
        avatarSignalProducer = imageFetcher(tweet.avatarURL).observeOn(UIScheduler())
    }
    
}

private let URLSessionWithCache = { () -> NSURLSession in
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.requestCachePolicy = .ReturnCacheDataElseLoad
    return NSURLSession(configuration: configuration)
}()

private func defaultImageFetcher(imageURL: NSURL) -> SignalProducer<UIImage, ImageFetcherError> {
    return URLSessionWithCache
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

private func parseEntities(tweet: Tweet) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: tweet.text)
    
    func addLink(entity: TweetEntity) {
        let range = NSMakeRange(entity.startIndex, entity.endIndex - entity.startIndex)
        return attributedString.addAttribute(NSLinkAttributeName, value: entity.entityURL, range: range)
    }
    
    tweet.hashtags.forEach(addLink)
    tweet.userMentions.forEach(addLink)
    
    return attributedString
}
