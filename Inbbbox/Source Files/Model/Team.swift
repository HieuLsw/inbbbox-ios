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

}

extension Team: Mappable {
    static var map: (JSON) -> Team {
        return { json in

            let stringDate = json[Key.CreatedAt.rawValue].stringValue

            return Team(
                identifier: json[Key.Identifier.rawValue].stringValue,
                name: json[Key.Name.rawValue].stringValue,
                username: json[Key.Username.rawValue].stringValue,
                avatarURL: json[Key.Avatar.rawValue].URL,
                createdAt: Formatter.Date.Timestamp.date(from: stringDate)!
            )
        }
    }

    fileprivate enum Key: String {
        case Identifier = "id"
        case Name = "name"
        case Username = "username"
        case Avatar = "avatar_url"
        case CreatedAt = "created_at"
    }
}

extension Team: Equatable {}

func == (lhs: Team, rhs: Team) -> Bool {
    return lhs.identifier == rhs.identifier
}
