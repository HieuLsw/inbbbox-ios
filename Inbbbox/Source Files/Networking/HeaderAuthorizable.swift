//
//  HeaderAuthorizable.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 11/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct HTTPHeader {
    typealias Name = String
    typealias Value = String

    let name: Name
    let value: Value
}

/// Use this protocol to authorize with header
protocol HeaderAuthorizable {
    func authorizationHeader(_ token: String) -> HTTPHeader
}

extension HeaderAuthorizable {

    /// Provides authorization's header.
    ///
    /// - parameter token: Token used to authorize request.
    ///
    /// - returns: Header that should be attached to authorized request.
    func authorizationHeader(_ token: String) -> HTTPHeader {
        return HTTPHeader(name: "Authorization", value: "Bearer " + token)
    }
}
