//
//  CommentLikeQuery.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 23/09/2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct CommentLikeQuery: Query {

    let method = Method.POST
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for marking given comment as liked.
    ///
    /// - parameter shot: Shot that comment is related to.
    /// - parameter comment: Comment to be liked.
    init(shot: ShotType, comment: CommentType) {
        path = "/shots/" + shot.identifier + "/comments/" + comment.identifier + "/like"
    }
}
