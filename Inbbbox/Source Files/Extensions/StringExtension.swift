//
//  StringExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 29/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension String {

    /// Calculates bounding rect for given font, constrained to specifiec width.
    /// By default `CGFloat.max` is used as `height` parameter during calculations.
    ///
    /// - parameter font:               Font to use as an attribute of string.
    /// - parameter constrainedToWidth: Maximum width of bounding rect.
    ///
    /// - returns: Bounding rect.
    func boundingRectWithFont(_ font: UIFont, constrainedToWidth width: CGFloat) -> CGRect {

        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSFontAttributeName: font]
        let rect = NSString(string: self).boundingRect(with: size,
                                                      options: .usesLineFragmentOrigin,
                                                   attributes: attributes,
                                                      context: nil)

        return rect.integral
    }
}
