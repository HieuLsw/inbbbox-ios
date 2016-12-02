//
//  UserToURLProvider.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 31.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Provide URL represantation of user from user.
/// Uses user's identifier to create URL.
/// Helps with using TTTAttributedLabel in the project.

protocol UserToURLProvider {


    /// Converts user to URL represantation of user.
    ///
    /// - parameter user: Team that is converted.
    ///
    /// - returns: URL represantation of user.
    func urlForUser(_ user: UserType) -> URL?

    /// Converts team to URL represantation of team.
    ///
    /// - parameter team: Team that is converted.
    ///
    /// - returns: URL represantation of team.
    func urlForTeam(_ team: TeamType) -> URL?

}

extension UserToURLProvider {

    func urlForUser(_ user: UserType) -> URL? {
        return URL(string: user.identifier)
    }

    func urlForTeam(_ team: TeamType) -> URL? {
        return URL(string: team.identifier)
    }
}
