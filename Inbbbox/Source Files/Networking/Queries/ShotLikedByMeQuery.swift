//
//  ShotLikedByMeQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 15/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct ShotLikedByMeQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for checking
    /// if given shot is liked by currently signed in user.
    ///
    /// - parameter shot: Shot to check.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier + "/like"
    }
}
