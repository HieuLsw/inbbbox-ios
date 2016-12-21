//
//  UIColorExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 23/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

/// Extension for predefined colors in Inbbbox app.
extension UIColor {

    /// Color based on RGB color model and alpha parameter.
    ///
    /// - parameter red:    Integer value of red color.
    /// - parameter green:  Integer value of green color.
    /// - parameter blue:   Integer value of blue color.
    /// - parameter alpha:  Float value of alpha. Needs to be between 0 and 1.
    ///
    /// - returns: Instance of UIColor.
    class func RGBA(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0,
                     green: CGFloat(green) / 255.0,
                      blue: CGFloat(blue) / 255.0,
                     alpha: alpha)
    }

    // MARK: Day Mode
    
    /// Returns brand pink color.
    class func pinkColor() -> UIColor {
        return pinkColor(alpha: 1)
    }

    /// Brand pink color with additional parameter alpha.
    ///
    /// - parameter alpha: float value of alpha. Needs to be between 0 and 1.
    ///
    /// - returns: pink color with set level of transparency.
    class func pinkColor(alpha: CGFloat) -> UIColor {
        return RGBA(240, 55, 126, alpha)
    }

    /// Returns brand background gray color.
    class func backgroundGrayColor() -> UIColor {
        return RGBA(246, 248, 248, 1)
    }
    
    /// Returns brand background gray color for nigth mode.
    class func backgroundNightModeGrayColor() -> UIColor {
        return RGBA(43, 49, 51, 1)
    }

    /// Returns brand text dark color.
    class func textDarkColor() -> UIColor {
        return RGBA(51, 51, 51, 1)
    }

    /// Returns brand text light color.
    class func textLightColor() -> UIColor {
        return RGBA(109, 109, 114, 1)
    }

    /// Returns brand text gray color used in followee cell.
    class func followeeTextGrayColor() -> UIColor {
        return RGBA(164, 180, 188, 1)
    }

    /// Returns brand gray color used in tabulator bar.
    class func tabBarGrayColor() -> UIColor {
        return RGBA(41, 41, 41, 1)
    }

    /// Returns brand background color used in collection view cells.
    class func cellBackgroundColor() -> UIColor {
        return RGBA(223, 224, 226, 1)
    }

    /// Returns brand gray color used for separator in shot details.
    class func separatorGrayColor() -> UIColor {
        return RGBA(218, 219, 221, 1)
    }
    
    /// Returns default white color.
    class func defaultWhiteColor() -> UIColor {
         return RGBA(249, 212, 226, 1)
    }

    /// Returns brand text light gray color.
    class func textLightGrayColor() -> UIColor {
        return RGBA(100, 100, 100, 1)
    }

    /// Returns brand text gray color.
    class func textGrayColor() -> UIColor {
        return RGBA(148, 147, 153, 1)
    }

    /// Returns brand text medium gray color.
    class func textMediumGrayColor() -> UIColor {
        return RGBA(127, 127, 127, 1)
    }

    /// Returns brand text dark gray color.
    class func textDarkGrayColor() -> UIColor {
        return RGBA(38, 38, 38, 1)
    }
    
    // MARK: Night Mode
    
    /// Returns brand text gray color used in followee cell in night mode.
    class func followeeTextGrayNightModeColor() -> UIColor {
        return RGBA(164, 180, 188, 1)
    }
    
    // Darker gray used in night mode
    class func darkGrayNightMode() -> UIColor {
        return .RGBA(43, 49, 51, 1)
    }
    
    // Less darker gray used in night mode
    class func lessDarkGrayNightMode() -> UIColor {
        return .RGBA(87, 98, 103, 1)
    }
    
    // Gray used in night mode
    class func grayNightMode() -> UIColor {
        return .RGBA(98, 113, 120, 1)
    }
    
    // Less white used in night mode
    class func lessWhiteNightMode() -> UIColor {
        return .RGBA(223, 224, 226, 1)
    }
    
    // Less white used in night mode
    class func whiteNightMode() -> UIColor {
        return .RGBA(236, 237, 239, 1)
    }
    

    // MARK: Flash Message
    
    /// Returns flash message gray background
    class func flashMessageBackgroundColor() -> UIColor {
        return RGBA(51, 51, 51, 1)
    }

    /// Returns random color.
    class func randomColor() -> UIColor {

        let red = Int(arc4random() % 256)
        let green = Int(arc4random() % 256)
        let blue = Int(arc4random() % 256)

        return RGBA(red, green, blue, 1)
    }
}
