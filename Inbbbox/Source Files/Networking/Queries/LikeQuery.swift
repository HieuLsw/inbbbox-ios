//
//  LikeQuery.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 17/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct LikeQuery: Query {

    let method = Method.POST
    let path: String
    var parameters = Parameters(encoding: .json)

    /// Initialize query for liking a shot.
    ///
    /// - parameter shot: Shot to like.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier + "/like"
    }
}
