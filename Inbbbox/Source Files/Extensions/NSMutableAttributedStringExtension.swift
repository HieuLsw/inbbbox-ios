//
//  NSMutableAttributedStringExtension.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 08.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {

    /// Returns string attributed with
    /// * font: Helvetica Neue Light, size 25
    /// * foreground color: `UIColor.cellBackgroundColor()`
    /// - SeeAlso: UIColorExtension for colors definitions.
    ///
    /// - parameter string: String to add attributes.
    ///
    /// - returns: Attributed string based on given string.
    class func emptyDataSetStyledString(string: String) -> NSMutableAttributedString {
        let attributes = [NSFontAttributeName: UIFont.helveticaFont(.NeueLight, size: 25),
               NSForegroundColorAttributeName: UIColor.cellBackgroundColor()]
        return NSMutableAttributedString(string: string, attributes: attributes)
    }
}
