//
//  UsersProvider.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class UsersProvider {

    let managedBlockedUsersProvider = ManagedBlockedUsersProvider()

    func provideBlockedUsers() -> Promise<[UserType]?> {
        return managedBlockedUsersProvider.provideBlockedUsers()
    }
}
