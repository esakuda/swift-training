//
//  UITextViewExtensions.swift
//  SwiftTraining
//
//  Created by María Eugenia Sakuda on 2/25/16.
//  Copyright © 2016 Wolox. All rights reserved.
//

import Foundation
import UIKit

extension UITextView {

    func fitContent() {
        let fixedWidth = self.frame.size.width
        self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = self.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        self.frame = newFrame;
    }
}
