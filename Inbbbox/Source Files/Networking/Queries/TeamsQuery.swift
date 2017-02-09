//
//  TeamsQuery.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

struct TeamsQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for getting currently signed user's teams.
    init() {
        path = "/user/teams"
    }

    /// Initialize query for list a given user’s teams.
    ///
    /// - parameter teamsOfUser: User that is followed by listed users.
    init(teamsOfUser user: UserType) {
        path = "/users/\(user.username)/teams"
    }
}
