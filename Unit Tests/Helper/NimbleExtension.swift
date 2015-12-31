//
//  NimbleExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 31/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Nimble

func waitThenContinue(delay: Double = 0.2) {
    waitUntil { done in
        dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), done)
    }
}