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
        case notStarted
        case inProgress
        case updated
    }

    let index: Int
    var status: UpdateStatus = .notStarted

    init(index: Int, status: UpdateStatus = .notStarted) {
        self.index = index
        self.status = status
    }
}

func ==(lhs: UpdateableIndex, rhs: UpdateableIndex) -> Bool {
    return lhs.index == rhs.index
}
