//
//  UIFontExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 29/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIFont {

    /// Enumerated type of San Fransisco font.
    enum SanFransisco {
        case light, medium, regular, bold

        var weight: CGFloat {
            switch self {
                case .light: return UIFontWeightLight
                case .medium: return UIFontWeightMedium
                case .regular: return UIFontWeightRegular
                case .bold: return UIFontWeightBold
            }
        }
    }

    /// San Fransisco font with set type and size.
    ///
    /// - parameter type: type of San Fransisco font
    /// - parameter size: size of font
    ///
    /// - returns: San Fransisco font with set type and size.
    class func sanFransiscoFont(withType type: SanFransisco, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: type.weight)
    }

    /// San Fransisco font with size.
    ///
    /// - parameter size: size of font
    ///
    /// - returns: San Fransisco font with set type and size.
    class func sanFransiscoFont(ofSize: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize)
    }
}
