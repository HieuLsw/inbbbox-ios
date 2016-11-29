//
//  FlashMessageTypes.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/2/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

public enum FlashMessageNotificationPosition {
    case top
    case navigationBarOverlay
    case bottom
}

public enum FlashMessageDuration  {
    case automatic
    case endless
    case custom(TimeInterval)
}

public func == (a: FlashMessageDuration, b: FlashMessageDuration) -> Bool {
    switch (a, b) {
        case (.automatic, .automatic): return true
        case (.endless, .endless): return true
        case (.custom(let a), .custom(let b)): return a == b
        default: return false
    }
}
