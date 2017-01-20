//
//  UIViewExtension.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/8/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIView {
    static func withColor(_ color: UIColor) -> UIView {
        let viewForReturn = UIView()
        viewForReturn.backgroundColor = color
        return viewForReturn
    }

    static func extendedFrame(forFrame frame: CGRect) -> CGRect {
        let margin = CGFloat(4)
        var rect = frame
        rect.size.height += margin
        return rect
    }
}
