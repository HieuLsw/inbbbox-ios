//
//  UnlikeQuery.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 17/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct UnlikeQuery: Query {

    let method = Method.DELETE
    let path: String
    var parameters = Parameters(encoding: .json)

    /// Initialize query for unliking a shot.
    ///
    /// - parameter shot: Shot to unlike.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier + "/like"
    }
}
