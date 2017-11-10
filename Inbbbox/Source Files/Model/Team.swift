//
//  Team.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 15/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Team: TeamType {

    let identifier: String
    let name: String
    let username: String
    let avatarURL: URL?
    let createdAt: Date
    let followersCount: UInt
    let followingsCount: UInt
    let bio: String
    let location: String

}

extension Team: Mappable {
    static var map: (JSON) -> Team {
        return { json in

            let stringDate = json[Key.createdAt.rawValue].stringValue

            return Team(
                identifier: json[Key.identifier.rawValue].stringValue,
                name: json[Key.name.rawValue].stringValue,
                username: json[Key.username.rawValue].stringValue,
                avatarURL: json[Key.avatar.rawValue].url,
                createdAt: Formatter.Date.Timestamp.date(from: stringDate)!,
                followersCount: json[Key.followersCount.rawValue].uIntValue,
                followingsCount: json[Key.followingsCount.rawValue].uIntValue,
                bio: json[Key.bio.rawValue].stringValue,
                location: json[Key.location.rawValue].stringValue
            )
        }
    }

    fileprivate enum Key: String {
        case identifier = "id"
        case name = "name"
        case username = "username"
        case avatar = "avatar_url"
        case createdAt = "created_at"
        case followersCount = "followers_count"
        case followingsCount = "followings_count"
        case bio = "bio"
        case location = "location"
    }
}

extension Team: Equatable {}

func == (lhs: Team, rhs: Team) -> Bool {
    return lhs.identifier == rhs.identifier
}
