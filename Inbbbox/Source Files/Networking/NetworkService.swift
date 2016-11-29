//
//  NetworkService.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 11/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Protocol describing network service.
protocol NetworkService {

    /// Scheme of network service.
    var scheme: String { get }

    /// Host of network service.
    var host: String { get }

    /// Version of network service.
    var version: String { get }

    /// Authorize given request.
    ///
    /// - parameter request: Request to authorize.
    func authorizeRequest(_ request: NSMutableURLRequest)
}
