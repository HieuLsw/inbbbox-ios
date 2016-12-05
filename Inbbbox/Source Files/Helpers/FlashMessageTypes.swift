//
//  FlashMessageTypes.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/2/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

public enum FlashMessageNotificationPosition {
    case Top
    case NavigationBarOverlay
    case Bottom
}

public enum FlashMessageDuration  {
    case Automatic
    case Endless
    case Custom(NSTimeInterval)
}

public func == (a: FlashMessageDuration, b: FlashMessageDuration) -> Bool {
    switch (a, b) {
        case (.Automatic, .Automatic): return true
        case (.Endless, .Endless): return true
        case (.Custom(let a), .Custom(let b)): return a == b
        default: return false
    }
}
