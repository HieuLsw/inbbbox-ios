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
        case Neue, NeueMedium, NeueLight, NeueBold

        /// Font name
        var name: String {
            switch self {
                case .Neue: return "HelveticaNeue"
                case .NeueMedium: return "HelveticaNeue-Medium"
                case .NeueLight: return "HelveticaNeue-Light"
                case .NeueBold: return "HelveticaNeue-Bold"
            }
        }
    }

    /// Helvetica font with set type and size.
    ///
    /// - parameter type: type of helvetica font
    /// - parameter size: size of font
    ///
    /// - returns: helvetica font with set type and size.
    class func helveticaFont(type: Helvetica, size: CGFloat = UIFont.systemFontSize()) -> UIFont {
        return UIFont(name: type.name, size: size)!
    }
}
