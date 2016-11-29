//
//  FollowUserQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct FollowUserQuery: Query {

    let method = Method.PUT
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for following a given user.
    ///
    /// - parameter user: User to follow.
    init(user: UserType) {
        path = "/users/" + user.identifier + "/follow"
    }

    /// Initialize query for following a given team.
    ///
    /// - parameter team: Team to follow.
    init(team: TeamType) {
        path = "/users/" + team.identifier + "/follow"
    }
}
