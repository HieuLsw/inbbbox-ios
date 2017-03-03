//
//  UsersRequester.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class UsersRequester {
    let managedBlockedUsersRequester = ManagedBlockedUsersRequester()

    func block(user: UserType) -> Promise<Void> {
        return managedBlockedUsersRequester.block(user: user)
    }

    func unblock(user: UserType) -> Promise<Void> {
        return managedBlockedUsersRequester.unblock(user: user)
    }
}
