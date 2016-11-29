//
//  UIFontExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 29/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIFont {

    /// Enumerated type of helvetica font.
    enum Helvetica {
        case neue, neueMedium, neueLight, neueBold

        /// Font name
        var name: String {
            switch self {
                case .neue: return "HelveticaNeue"
                case .neueMedium: return "HelveticaNeue-Medium"
                case .neueLight: return "HelveticaNeue-Light"
                case .neueBold: return "HelveticaNeue-Bold"
            }
        }
    }

    /// Helvetica font with set type and size.
    ///
    /// - parameter type: type of helvetica font
    /// - parameter size: size of font
    ///
    /// - returns: helvetica font with set type and size.
    class func helveticaFont(_ type: Helvetica, size: CGFloat = UIFont.systemFontSize) -> UIFont {
        return UIFont(name: type.name, size: size)!
    }
}
