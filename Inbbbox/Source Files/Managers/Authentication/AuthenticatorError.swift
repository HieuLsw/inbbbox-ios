//
//  AuthenticatorError.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 21/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

enum AuthenticatorError: Error {
    case unableToFetchUser
    case authenticationDidCancel
    case dataDecodingFailure
    case accessTokenMissing
    case authTokenMissing
    case unknownError
    case invalidCallbackURL
    case requestTokenURLFailure
}
