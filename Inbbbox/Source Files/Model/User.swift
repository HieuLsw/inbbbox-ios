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
    let projectsCount: UInt
    let bucketsCount: UInt
    let bio: String
    let location: String

    init(json: JSON) {
        identifier = json[Key.identifier.rawValue].stringValue
        name = json[Key.name.rawValue].string
        username = json[Key.username.rawValue].stringValue
        avatarURL = json[Key.avatar.rawValue].URL
        shotsCount = json[Key.shotsCount.rawValue].uIntValue
        accountType = UserAccountType(rawValue: json[Key.accountType.rawValue].stringValue)
        followersCount = json[Key.followersCount.rawValue].uIntValue
        followingsCount = json[Key.followingsCount.rawValue].uIntValue
        projectsCount = json[Key.projectsCount.rawValue].uIntValue
        bucketsCount = json[Key.bucketsCount.rawValue].uIntValue
        bio = json[Key.bio.rawValue].stringValue
        location = json[Key.location.rawValue].stringValue
    }

    required init(coder aDecoder: NSCoder) {
        identifier = aDecoder.decodeObject(forKey: Key.identifier.rawValue) as? String ?? ""
        name = aDecoder.decodeObject(forKey: Key.name.rawValue) as? String
        username = aDecoder.decodeObject(forKey: Key.username.rawValue) as? String ?? ""
        avatarURL = aDecoder.decodeObject(forKey: Key.avatar.rawValue) as? URL
        shotsCount = aDecoder.decodeObject(forKey: Key.shotsCount.rawValue) as? UInt ?? 0
        accountType = {
            if let key = aDecoder.decodeObject(forKey: Key.accountType.rawValue) as? String {
                return UserAccountType(rawValue: key)
            }
            return nil
        }()
        followersCount = aDecoder.decodeObject(forKey: Key.followersCount.rawValue) as? UInt ?? 0
        followingsCount = aDecoder.decodeObject(forKey: Key.followingsCount.rawValue) as? UInt ?? 0
        projectsCount = aDecoder.decodeObject(forKey: Key.projectsCount.rawValue) as? UInt ?? 0
        bucketsCount = aDecoder.decodeObject(forKey: Key.bucketsCount.rawValue) as? UInt ?? 0
        bio = aDecoder.decodeObject(forKey: Key.bio.rawValue) as? String ?? ""
        location = aDecoder.decodeObject(forKey: Key.location.rawValue) as? String ?? ""
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: Key.identifier.rawValue)
        aCoder.encode(name, forKey: Key.name.rawValue)
        aCoder.encode(username, forKey: Key.username.rawValue)
        aCoder.encode(avatarURL, forKey: Key.avatar.rawValue)
        aCoder.encode(shotsCount, forKey: Key.shotsCount.rawValue)
        aCoder.encode(accountType?.rawValue, forKey: Key.accountType.rawValue)
        aCoder.encode(followersCount, forKey: Key.followersCount.rawValue)
        aCoder.encode(followingsCount, forKey: Key.followingsCount.rawValue)
        aCoder.encode(projectsCount, forKey: Key.projectsCount.rawValue)
        aCoder.encode(bucketsCount, forKey: Key.bucketsCount.rawValue)
        aCoder.encode(bio, forKey: Key.bio.rawValue)
        aCoder.encode(location, forKey: Key.location.rawValue)
    }
}

private extension User {

    enum Key: String {
        case identifier = "id"
        case name = "name"
        case username = "username"
        case avatar = "avatar_url"
        case shotsCount = "shots_count"
        case accountType = "type"
        case followersCount = "followers_count"
        case followingsCount = "followings_count"
        case projectsCount = "projects_count"
        case bucketsCount = "buckets_count"
        case bio = "bio"
        case location = "location"
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
