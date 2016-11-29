//
//  CommentUnlikeQuery.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 23/09/2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct CommentUnlikeQuery: Query {

    let method = Method.DELETE
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for unmarking comment as liked.
    ///
    /// - parameter shot: Shot that comment is related to.
    /// - parameter comment: Comment to be checked.
    init(shot: ShotType, comment: CommentType) {
        path = "/shots/" + shot.identifier + "/comments/" + comment.identifier + "/like"
    }
}
