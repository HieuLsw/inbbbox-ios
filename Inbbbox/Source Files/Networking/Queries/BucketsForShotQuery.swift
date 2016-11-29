//
//  BucketsForShotQuery.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 24.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct BucketsForShotQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for list of buckets that contain given shot.
    ///
    /// - parameter shot: Shot that listed buckets should contain.
    init(shot: ShotType) {
        path = "/shots/" + shot.identifier + "/buckets"
    }
}
