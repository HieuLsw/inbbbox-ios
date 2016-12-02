//
//  UITextFieldExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 01.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UITextField {

    /// Sets left padding in text field
    ///
    /// - parameter padding: float value of padding
    func setLeftPadding(_ padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: frame.size.height))
        leftView = view
        leftViewMode = .always
    }

    /// Sets right padding in text field
    ///
    /// - parameter padding: float value of padding
    func setRightPadding(_ padding: CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: frame.size.height))
        rightView = view
        rightViewMode = .always
    }
}
