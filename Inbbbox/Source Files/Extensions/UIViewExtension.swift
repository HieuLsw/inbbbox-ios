//
//  UIViewExtension.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/8/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIView {
    static func withColor(color: UIColor) -> UIView {
        let viewForReturn = UIView()
        viewForReturn.backgroundColor = color
        return viewForReturn
    }
}
