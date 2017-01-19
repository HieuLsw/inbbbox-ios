//
//  LikedShot.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LikedShot: Sortable {
    let likeIdentifier: String
    let createdAt: Date
    let shot: ShotType
}

extension LikedShot: Mappable {
    static var map: (JSON) -> LikedShot {
        return { json in

            let identifier = json[Key.Identifier.rawValue].stringValue
            let stringDate = json[Key.CreatedAt.rawValue].stringValue
            let createdAt = Formatter.Date.Timestamp.date(from: stringDate)!
            let shot = Shot.map(json[Key.Shot.rawValue])

            return LikedShot(likeIdentifier: identifier, createdAt: createdAt, shot: shot)
        }
    }

    fileprivate enum Key: String {
        case Identifier = "id"
        case Shot = "shot"
        case CreatedAt = "created_at"
    }
}

extension LikedShot: Equatable {}

func == (lhs: LikedShot, rhs: LikedShot) -> Bool {
    return lhs.likeIdentifier == rhs.likeIdentifier
}
