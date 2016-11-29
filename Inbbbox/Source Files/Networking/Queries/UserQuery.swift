//
//  UserQuery.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 19/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct UserQuery: Query {

    let method = Method.GET
    let path: String
    var parameters = Parameters(encoding: .url)

    /// Initialize query for getting currently signed in user.
    init() {
        path = "/user"
    }

    /// Initialize query for getting a user with given identifier.
    ///
    /// - parameter identifier: User's identifier.
    init(identifier: String) {
        path = "/users/" + identifier
    }
}
