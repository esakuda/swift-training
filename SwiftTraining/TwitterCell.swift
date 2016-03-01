//
//  TwitterCell.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/24/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit
import ReactiveCocoa
import Result

class TwitterCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var rac_prepareForReuseProducer: SignalProducer<(), NoError> {
        return rac_prepareForReuseSignal
            .toSignalProducer()
            .flatMapError { _ in SignalProducer.empty }
            .map { _ in () }
    }
    
    func bindViewModel(tweet: TweetViewModel) {
        messageTextView.attributedText = tweet.text
        usernameLabel.text = tweet.username
        timeLabel.text = tweet.createdAt
        avatarImageView.image = UIImage.init(named: "avatar_placeholder")
        tweet.avatarSignalProducer
            .takeUntil(rac_prepareForReuseProducer)
            .startWithNext { [unowned self] image in self.avatarImageView.image = image }
    }
    
}
