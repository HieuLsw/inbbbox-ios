//
//  Requestable.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 11/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

/// Defines how Requestable type should behave
protocol Requestable {
    var query: Query { get }
    var foundationRequest: URLRequest { get }
}

// MARK: - Common implementation for Requestable
extension Requestable {

    /// Foundation request based on query.
    var foundationRequest: URLRequest {

        let queryItems = query.parameters.queryItems

        var components = URLComponents()
        components.scheme = query.service.scheme
        components.host = query.service.host
        components.path = query.service.version + query.path

        if queryItems.count > 0 {
            components.queryItems = queryItems as [URLQueryItem]?
        }

        // Intentionally force unwrapping optional to get crash when problem occur
        let mutableRequest = NSMutableURLRequest(url: components.url!)
        mutableRequest.httpMethod = query.method.rawValue
        mutableRequest.httpBody = query.parameters.body as Data?

        if mutableRequest.httpBody != nil {
            mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        query.service.authorizeRequest(mutableRequest)
        guard let immutableRequest = mutableRequest.copy() as? URLRequest else {
            return URLRequest(url: components.url!)
        }
        return immutableRequest
    }
}
