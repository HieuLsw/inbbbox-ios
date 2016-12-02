//
//  Comment.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Comment: CommentType {

    let identifier: String
    let body: NSAttributedString?
    let createdAt: Date
    let user: UserType
    var likesCount: Int
    var likedByMe: Bool
    var checkedForLike: Bool
}

extension Comment: Mappable {
    static var map: (JSON) -> Comment {
        return { json in

            let stringDate = json[Key.CreatedAt.rawValue].stringValue
            let htmlBody: NSAttributedString? = {
                guard let htmlString = json[Key.Body.rawValue].string else {
                    return nil
                }
                return NSAttributedString(htmlString: htmlString)
            }()

            return Comment(
                identifier: json[Key.Identifier.rawValue].stringValue,
                body: htmlBody,
                createdAt: Formatter.Date.Timestamp.date(from: stringDate)!,
                user: User.map(json[Key.User.rawValue]),
                likesCount: json[Key.LikesCount.rawValue].intValue,
                likedByMe:  false,
                checkedForLike: false
            )
        }
    }

    fileprivate enum Key: String {
        case Identifier = "id"
        case Body = "body"
        case CreatedAt = "created_at"
        case User = "user"
        case LikesCount = "likes_count"
    }
}

extension Comment: Equatable {}

func == (lhs: Comment, rhs: Comment) -> Bool {
    return lhs.identifier == rhs.identifier
}
