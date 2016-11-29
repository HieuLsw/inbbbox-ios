//
//  AutoSizable.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 07/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol AutoSizable {

    static var maximumContentWidth: CGFloat? { get }
    static var minimumRequiredHeight: CGFloat { get }
    static var contentInsets: UIEdgeInsets { get }
    static var verticalInteritemSpacing: CGFloat { get }
}

extension AutoSizable {

    static var maximumContentWidth: CGFloat? {
        return nil
    }

    static var minimumRequiredHeight: CGFloat {
        return 0
    }

    static var contentInsets: UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    static var verticalInteritemSpacing: CGFloat {
        return 0
    }
}
