//
//  FolloweesQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct FolloweesQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for list who the authenticated user is following.
    init() {
        path = "/user/following"
    }

    /// Initialize query for list who given user is following.
    ///
    /// - parameter followeesOfUser: User that follows listed users.
    init(followeesOfUser user: UserType) {
        path = "/users/\(user.username)/following"
    }
}
