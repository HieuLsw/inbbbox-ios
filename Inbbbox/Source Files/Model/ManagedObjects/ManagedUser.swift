//
//  User.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/17/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import CoreData

class ManagedUser: NSManagedObject {
    @NSManaged var mngd_identifier: String
    @NSManaged var mngd_name: String?
    @NSManaged var mngd_username: String
    @NSManaged var mngd_avatarURL: String?
    @NSManaged var mngd_shotsCount: UInt
    @NSManaged var mngd_accountType: String?
}

extension ManagedUser: UserType {
    var identifier: String { return mngd_identifier }
    var name: String? { return mngd_name }
    var username: String { return mngd_username }

    var avatarURL: URL? {
        guard let encodedString = mngd_avatarURL?.addingPercentEncoding(
                withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        return URL(string: encodedString)
    }

    var shotsCount: UInt { return mngd_shotsCount }
    var accountType: UserAccountType? {
        return mngd_accountType.flatMap { UserAccountType(rawValue: $0) }
    }
}
