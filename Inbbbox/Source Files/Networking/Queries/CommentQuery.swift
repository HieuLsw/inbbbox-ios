//
//  CommentQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct CommentQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for list of comments under given shot.
    ///
    /// - parameter shot: Shot that comments should be related to.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier + "/comments"
    }
}
