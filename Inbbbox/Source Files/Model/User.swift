//
//  User.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyJSON

final class User: NSObject, UserType {

    let identifier: String
    let name: String?
    let username: String
    let avatarURL: URL?
    let shotsCount: UInt
    let accountType: UserAccountType?
    let followersCount: UInt
    let followingsCount: UInt
    let bio: String
    let location: String

    init(json: JSON) {
        identifier = json[Key.Identifier.rawValue].stringValue
        name = json[Key.Name.rawValue].string
        username = json[Key.Username.rawValue].stringValue
        avatarURL = json[Key.Avatar.rawValue].URL
        shotsCount = json[Key.ShotsCount.rawValue].uIntValue
        accountType = UserAccountType(rawValue: json[Key.AccountType.rawValue].stringValue)
        followersCount = json[Key.FollowersCount.rawValue].uIntValue
        followingsCount = json[Key.FollowingsCount.rawValue].uIntValue
        bio = json[Key.Bio.rawValue].stringValue
        location = json[Key.Location.rawValue].stringValue
    }

    required init(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObject(forKey: Key.Identifier.rawValue) as? String ?? ""
        name = aDecoder.decodeObject(forKey: Key.Name.rawValue) as? String
        username = aDecoder.decodeObject(forKey: Key.Username.rawValue) as? String ?? ""
        avatarURL = aDecoder.decodeObject(forKey: Key.Avatar.rawValue) as? URL
        shotsCount = aDecoder.decodeObject(forKey: Key.ShotsCount.rawValue) as? UInt ?? 0
        accountType = {
            if let key = aDecoder.decodeObject(forKey: Key.AccountType.rawValue) as? String {
                return UserAccountType(rawValue: key)
            }
            return nil
        }()
        followersCount = aDecoder.decodeObject(forKey: Key.FollowersCount.rawValue) as? UInt ?? 0
        followingsCount = aDecoder.decodeObject(forKey: Key.FollowingsCount.rawValue) as? UInt ?? 0
        bio = aDecoder.decodeObject(forKey: Key.Bio.rawValue) as? String ?? ""
        location = aDecoder.decodeObject(forKey: Key.Location.rawValue) as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: Key.Identifier.rawValue)
        aCoder.encode(name, forKey: Key.Name.rawValue)
        aCoder.encode(username, forKey: Key.Username.rawValue)
        aCoder.encode(avatarURL, forKey: Key.Avatar.rawValue)
        aCoder.encode(shotsCount, forKey: Key.ShotsCount.rawValue)
        aCoder.encode(accountType?.rawValue, forKey: Key.AccountType.rawValue)
        aCoder.encode(followersCount, forKey: Key.FollowersCount.rawValue)
        aCoder.encode(followingsCount, forKey: Key.FollowingsCount.rawValue)
        aCoder.encode(bio, forKey: Key.Bio.rawValue)
        aCoder.encode(location, forKey: Key.Location.rawValue)
    }
}

private extension User {

    enum Key: String {
        case Identifier = "id"
        case Name = "name"
        case Username = "username"
        case Avatar = "avatar_url"
        case ShotsCount = "shots_count"
        case AccountType = "type"
        case FollowersCount = "followers_count"
        case FollowingsCount = "followings_count"
        case Bio = "bio"
        case Location = "location"
    }
}

extension User: NSSecureCoding {

    static var supportsSecureCoding: Bool {
        return true
    }
}

extension User: Mappable {
    static var map: (JSON) -> User {
        return { json in
            User(json: json)
        }
    }
}

extension User {

    override var debugDescription: String {
        return
            "<Class: " + String(describing: type(of: self)) + "> " +
            "{ " +
                "ID: " + identifier + ", " +
                "Username: " + username + ", " +
                "Name: " + (name ?? "unknown") +
            " }"
    }
}
