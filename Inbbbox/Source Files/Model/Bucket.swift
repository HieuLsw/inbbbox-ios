//
//  Bucket.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 27/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Bucket: BucketType {

    let identifier: String
    let name: String
    let attributedDescription: NSAttributedString?
    let shotsCount: UInt
    let createdAt: Date
    let owner: UserType
}

extension Bucket: Mappable {
    static var map: (JSON) -> Bucket {
        return { json in

            let stringDate = json[Key.CreatedAt.rawValue].stringValue
            let attributedDescription: NSAttributedString? = {
                guard let htmlString = json[Key.Description.rawValue].string else {
                    return nil
                }
                return NSAttributedString(htmlString: htmlString)
            }()

            return Bucket(
                identifier: json[Key.Identifier.rawValue].stringValue,
                name: json[Key.Name.rawValue].stringValue,
                attributedDescription: attributedDescription,
                shotsCount: json[Key.ShotsCount.rawValue].uIntValue,
                createdAt: Formatter.Date.Timestamp.date(from: stringDate)!,
                owner: User.map(json[Key.User.rawValue])
            )
        }
    }

    fileprivate enum Key: String {
        case Identifier = "id"
        case Name = "name"
        case Description = "description"
        case CreatedAt = "created_at"
        case ShotsCount = "shots_count"
        case User = "user"
    }
}

extension Bucket: Hashable {
    var hashValue: Int {
        return identifier.hashValue
    }
}

extension Bucket: Equatable {}

func == (lhs: Bucket, rhs: Bucket) -> Bool {
    return lhs.identifier == rhs.identifier
}
