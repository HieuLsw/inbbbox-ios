//
//  ShotLikesQuery.swift
//  Inbbbox
//
//  Created by Tomasz W on 07/10/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct ShotDetailsQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for likes given to a shot
    ///
    /// - parameter shot: Shot that likes should be provided.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier
    }
}
