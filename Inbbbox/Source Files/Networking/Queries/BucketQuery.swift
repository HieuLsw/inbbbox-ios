//
//  BucketQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 27/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct BucketQuery: Query {

    let method = Method.GET
    var parameters = Parameters(encoding: .url)
    fileprivate(set) var path: String

    /// Initialize query for list of the authenticated user's buckets.
    init() {
        path = "/user/buckets"
    }

    /// Initialize query for list of the given user's buckets.
    ///
    /// - parameter user: User whose buckets should be listed.
    init(user: UserType) {
        path = "/users/\(user.username)/buckets"
    }
}
