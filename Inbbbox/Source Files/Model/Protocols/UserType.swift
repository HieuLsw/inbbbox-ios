//
//  UserType.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/17/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

enum UserAccountType: String {
    case User = "User"
    case Player = "Player"
    case Team = "Team"
}

/// Interface for User and ManagedUser.
protocol UserType {

    /// Unique identifier.
    var identifier: String { get }

    /// Name of the User.
    var name: String? { get }

    /// Username of the User.
    var username: String { get }

    /// URL to avatar image.
    var avatarURL: URL? { get }

    /// Number of shots created by User.
    var shotsCount: UInt { get }

    /// Account type of User.
    /// Can be User, Player, Team.
    var accountType: UserAccountType? { get }

    /// Number of user's followers
    var followersCount: UInt { get }

    /// Number of users followed by User.
    var followingsCount: UInt { get }

    /// Number of User's projects.
    var projectsCount: UInt { get }

    /// Number of User's buckets.
    var bucketsCount: UInt { get }

    /// Bio of the User.
    var bio: String { get }

    /// Location of the User.
    var location: String { get }
}

func == (lhs: UserType, rhs: UserType) -> Bool {
    return lhs.identifier == rhs.identifier
}

func == (lhs: [UserType], rhs: [UserType]) -> Bool {

    guard lhs.count == rhs.count else { return false }

    var indexingGenerators = (left: lhs.makeIterator(), right: rhs.makeIterator())

    var isEqual = true
    while let leftElement = indexingGenerators.left.next(),
            let rightElement = indexingGenerators.right.next(), isEqual {
        isEqual = leftElement == rightElement
    }

    return isEqual
}

func != (lhs: [UserType], rhs: [UserType]) -> Bool {
    return !(lhs == rhs)
}
