//
//  UserFollowedByMeQuery.swift
//  Inbbbox
//
//  Created by Peter Bruz on 14/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct UserFollowedByMeQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for checking
    /// if given user is followed by currently signed in user.
    ///
    /// - parameter user: User to check.
    init(user: UserType) {
        path = "/user/following/" + user.identifier
    }

    /// Initialize query for checking
    /// if given team is followed by currently signed in user.
    ///
    /// - parameter team: Team to check.
    init(team: TeamType) {
        path = "/user/following/" + team.identifier
    }
}
