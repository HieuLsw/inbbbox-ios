//
//  UpdateableIndexPaths.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 12.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct UpdateableIndex {

    enum UpdateStatus {
        case NotStarted
        case InProgress
        case Updated
    }

    let index: Int
    var status: UpdateStatus = .NotStarted

    init(index: Int, status: UpdateStatus = .NotStarted) {
        self.index = index
        self.status = status
    }
}

func ==(lhs: UpdateableIndex, rhs: UpdateableIndex) -> Bool {
    return lhs.index == rhs.index
}
