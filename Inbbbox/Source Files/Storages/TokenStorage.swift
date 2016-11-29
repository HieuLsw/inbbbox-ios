//
//  TokenStorage.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import KeychainAccess

final class TokenStorage {

    fileprivate static let KeychainService = "co.netguru.inbbbox.keychain.token"
    fileprivate static let keychain = Keychain(service: KeychainService)

    /// Token for currently logged in user.
    class var currentToken: String? {
        return keychain[Key.Token.rawValue]
    }

    /// Store token for current user.
    ///
    /// - parameter token: Current user's token.
    class func storeToken(_ token: String) {
        keychain[Key.Token.rawValue] = token
    }

    /// Clear stored token.
    class func clear() {
        keychain[Key.Token.rawValue] = nil
    }

    fileprivate enum Key: String {
        case Token = "co.netguru.inbbbox.keychain.token.key"
    }
}
