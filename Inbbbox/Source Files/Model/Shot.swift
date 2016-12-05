//
//  Shot.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Shot: ShotType {
    let identifier: String
    let title: String
    let attributedDescription: NSAttributedString?
    let user: UserType
    let shotImage: ShotImageType
    let createdAt: NSDate
    let animated: Bool
    let likesCount: UInt
    let viewsCount: UInt
    let commentsCount: UInt
    let bucketsCount: UInt
    let team: TeamType?
    let attachmentsCount: UInt
}

extension Shot: Mappable {
    static var map: JSON -> Shot {
        return { json in

            let stringDate = json[Key.CreatedAt.rawValue].stringValue
            let attributedDescription: NSAttributedString? = {
                guard let htmlString = json[Key.Description.rawValue].string else {
                    return nil
                }
                return NSAttributedString(htmlString: htmlString)
            }()

            let team: Team? = {
                guard json[Key.Team.rawValue] != nil else {
                    return nil
                }
                return Team.map(json[Key.Team.rawValue])
            }()

            return Shot(
                identifier: json[Key.Identifier.rawValue].stringValue,
                title: json[Key.Title.rawValue].stringValue,
                attributedDescription: attributedDescription,
                user: User.map(json[Key.User.rawValue]),
                shotImage: ShotImage.map(json[Key.Images.rawValue]),
                createdAt: Formatter.Date.Timestamp.dateFromString(stringDate)!,
                animated: json[Key.Animated.rawValue].boolValue,
                likesCount: json[Key.LikesCount.rawValue].uIntValue,
                viewsCount: json[Key.ViewsCount.rawValue].uIntValue,
                commentsCount: json[Key.CommentsCount.rawValue].uIntValue,
                bucketsCount: json[Key.BucketsCount.rawValue].uIntValue,
                team: team,
                attachmentsCount: json[Key.AttachmentsCount.rawValue].uIntValue
            )
        }
    }

    private enum Key: String {
        case Identifier = "id"
        case Title = "title"
        case Description = "description"
        case User = "user"
        case Images = "images"
        case CreatedAt = "created_at"
        case Animated = "animated"
        case LikesCount = "likes_count"
        case ViewsCount = "views_count"
        case CommentsCount = "comments_count"
        case BucketsCount = "buckets_count"
        case Team = "team"
        case AttachmentsCount = "attachments_count"
    }
}

extension Shot: Equatable {}

func == (lhs: Shot, rhs: Shot) -> Bool {
    return lhs.identifier == rhs.identifier
}
