//
//  ManagedBlockedUser.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import CoreData

class ManagedBlockedUser: NSManagedObject {
    @NSManaged var mngd_identifier: String
    @NSManaged var mngd_name: String?
    @NSManaged var mngd_username: String
    @NSManaged var mngd_avatarURL: String?
}

extension ManagedBlockedUser: UserType {
    var identifier: String { return mngd_identifier }
    var name: String? { return mngd_name }
    var username: String { return "" }

    var avatarURL: URL? {
        guard let encodedString = mngd_avatarURL?.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                return nil
        }
        return URL(string: encodedString)
    }

    var shotsCount: UInt { return 0 }
    var accountType: UserAccountType? { return nil }
    var followersCount: UInt { return 0 }
    var followingsCount: UInt { return 0 }
    var projectsCount: UInt { return 0 }
    var bucketsCount: UInt { return 0 }
    var isPro: Bool { return false }
    var bio: String { return "" }
    var location: String { return "" }
}
