//
//  Verifiable.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 01/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

enum VerifiableError: Error {
    case authenticationRequired
    case wrongAccountType
    case incorrectTextLength(UInt)
}

protocol Verifiable {

    func verifyAuthenticationStatus(_ verify: Bool) -> Promise<Void>
    func verifyAccountType() -> Promise<Void>
    func verifyTextLength(_ text: String, min: UInt, max: UInt) -> Promise<Void>
}

extension Verifiable {

    func verifyAuthenticationStatus(_ verify: Bool) -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            if verify {
                guard let _ = TokenStorage.currentToken else {
                    throw VerifiableError.authenticationRequired
                }
            }

            fulfill()
        }
    }

    func verifyAccountType() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            guard let user = UserStorage.currentUser, user.accountType == .Team ||
                    user.accountType == .Player else {
                throw VerifiableError.wrongAccountType
            }

            fulfill()
        }
    }

    func verifyTextLength(_ text: String, min minUInt: UInt, max maxUInt: UInt) -> Promise<Void> {
        return Promise<Void> { fulfill, _ in
            let textWithoutWhitespaces = text.trimmingCharacters(in: .whitespaces)
            let trueMin = min(minUInt, maxUInt)
            let trueMax = max(minUInt, maxUInt)

            if textWithoutWhitespaces.characters.count < Int(trueMin) {
                throw VerifiableError.incorrectTextLength(trueMin)

            } else if maxUInt != UInt.max {
                if textWithoutWhitespaces.characters.count > Int(trueMax) {
                    throw VerifiableError.incorrectTextLength(trueMax)
                }
            }

            fulfill()
        }
    }
}
