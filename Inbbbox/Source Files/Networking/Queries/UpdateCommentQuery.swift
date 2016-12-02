//
//  UpdateCommentQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 11/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct UpdateCommentQuery: Query {

    let method = Method.PUT
    let path: String
    var parameters = Parameters(encoding: .json)

    /// Initialize query for updating comment.
    ///
    /// - parameter shot:     Shot that contains comments to update.
    /// - parameter comment:  Comments that is being updated.
    /// - parameter withBody: New comment's body.
    init(shot: ShotType, comment: CommentType, withBody body: String) {
        path = "/shots/" + shot.identifier + "/comments/" + comment.identifier
        parameters["body"] = body as AnyObject?
    }
}
