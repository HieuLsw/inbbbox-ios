//
//  UserStorage.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 05/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import KeychainAccess

class UserStorage {

    fileprivate static let KeychainService = "co.netguru.inbbbox.keychain.user"
    fileprivate static let keychain = Keychain(service: KeychainService)

    /// Currently signed in user. If there isn't any then returns *nil*.
    class var currentUser: User? {
        guard let data = keychain[data: Key.UserToken.rawValue] else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? User
    }

    /// Indicates if there is any signed in user.
    class var isUserSignedIn: Bool {
        return currentUser != nil
    }

    /// Indicates if user is using app as an guest.
    class var isGuestUser: Bool {
        return keychain[data: Key.GuestToken.rawValue] != nil ? true : false
    }

    /// Store given user.
    ///
    /// - parameter user: User that should be stored.
    class func storeUser(_ user: User) {
        keychain[data: Key.UserToken.rawValue] = NSKeyedArchiver.archivedData(withRootObject: user)
    }

    /// Store bool flag indicating guest mode on.
    class func storeGuestUser() {
        keychain[data: Key.GuestToken.rawValue] = NSKeyedArchiver.archivedData(withRootObject: true)
    }

    /// Clear stored user.
    class func clearUser() {
        keychain[Key.UserToken.rawValue] = nil
    }

    /// Clear guest user.
    class func clearGuestUser() {
        keychain[Key.GuestToken.rawValue] = nil
    }
}

private extension UserStorage {

    enum Key: String {
        case UserToken = "co.netguru.inbbbox.keychain.user.key"
        case GuestToken = "co.netguru.inbbbox.keychain.guest.key"
    }
}
