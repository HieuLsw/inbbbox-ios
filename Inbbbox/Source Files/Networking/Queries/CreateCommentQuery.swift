//
//  CreateCommentQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct CreateCommentQuery: Query {

    let method = Method.POST
    let path: String
    var parameters = Parameters(encoding: .json)

    /// Initialize query for posting comment.
    ///
    /// - parameter shot: Shot that should be commented.
    /// - parameter body: Comment's body.
    init(shot: ShotType, body: String) {
        path = "/shots/" + shot.identifier + "/comments"
        parameters["body"] = body as AnyObject?
    }
}
