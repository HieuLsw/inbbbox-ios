//
//  TeamMembersQuery.swift
//  Inbbbox
//
//  Created by Peter Bruz on 10/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct TeamMembersQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for list of given team's members.
    ///
    /// - parameter team: Team to list members for.
    init(team: TeamType) {
        path = "/teams/" + team.identifier + "/members"
    }
}
