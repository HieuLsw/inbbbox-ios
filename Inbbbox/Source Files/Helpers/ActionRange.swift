//
//  ActionRange.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/14/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

//Simple struct defines range for action for gestures in shots cell
struct ActionRange {
    let min: CGFloat
    let max: CGFloat
    var mid: CGFloat {
        if min > max {
            return ((min - max) / 2) + max
        } else {
            return ((max - min) / 2) + min
        }
    }
}
