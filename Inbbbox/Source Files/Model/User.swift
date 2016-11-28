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


    init(json: JSON) {
        identifier = json[Key.Identifier.rawValue].stringValue
        name = json[Key.Name.rawValue].string
        username = json[Key.Username.rawValue].stringValue
        avatarURL = json[Key.Avatar.rawValue].URL
        shotsCount = json[Key.ShotsCount.rawValue].uIntValue
        accountType = UserAccountType(rawValue: json[Key.AccountType.rawValue].stringValue)
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
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: Key.Identifier.rawValue)
        aCoder.encode(name, forKey: Key.Name.rawValue)
        aCoder.encode(username, forKey: Key.Username.rawValue)
        aCoder.encode(avatarURL, forKey: Key.Avatar.rawValue)
        aCoder.encode(shotsCount, forKey: Key.ShotsCount.rawValue)
        aCoder.encode(accountType?.rawValue, forKey: Key.AccountType.rawValue)
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
