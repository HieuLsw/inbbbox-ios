//
//  UIScrollViewExtension.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIScrollView {

    /// Updates content insets. If you don't provide value for any inset, current value will be used.
    ///
    /// - Parameters:
    ///   - top: Top inset.
    ///   - left: Left inset.
    ///   - bottom: Bottom inset.
    ///   - right: Right inset.
    func updateInsets(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        contentInset = UIEdgeInsets(
            top: top ?? contentInset.top,
            left: left ?? contentInset.left,
            bottom: bottom ?? contentInset.bottom,
            right: right ?? contentInset.right
        )
    }
}
