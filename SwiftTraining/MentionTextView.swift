//
//  MentionTextView.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/29/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit

class MentionTextView: UITextView {
    var fontSize = 11.0 as CGFloat
    
    func chopOffNonAlphaNumericCharacters(text:String) -> String {
        let nonAlphaNumericCharacters = NSCharacterSet.alphanumericCharacterSet().invertedSet
        let characterArray = text.componentsSeparatedByCharactersInSet(nonAlphaNumericCharacters)
        return characterArray[0]
    }
    
    func addMentionsStyle () {
        let nsText:NSString = text
        let words:[NSString] = nsText.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let attrs = [NSFontAttributeName : UIFont.systemFontOfSize(self.fontSize)]
        
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
            }
        }
        self.attributedText = attrString
    }
}