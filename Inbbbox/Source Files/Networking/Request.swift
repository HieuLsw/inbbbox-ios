//
//  Request.swift
//  Inbbbox
//
//  Created by Radoslaw Szeja on 14/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

/// Requestable value type
struct Request: Requestable, Responsable {

    /// Query used to create request.
    let query: Query

    // Session for request.
    let session: URLSession

    init(query: Query, urlSession: URLSession = URLSession.inbbboxDefaultSession()) {
        self.query = query
        session = urlSession
    }

    /// Invoke request.
    ///
    /// - returns: Promise which resolves with data converted to JSON or *nil*
    func resume() -> Promise<JSON?> {
        return Promise<JSON?> { fulfill, reject in

            do {
                try APIRateLimitKeeper.sharedKeeper.verifyRateLimit()
            } catch {
                throw error
            }

            let dataTask = session.dataTask(with: foundationRequest as URLRequest) { data, response, error in

                if let error = error {
                    reject(error)

                } else {
                    firstly {
                        self.responseWithData(data, response: response)

                    }.then { response -> Void in
                        fulfill(response.json)

                    }.catch(execute: reject)
                }
            }

            dataTask.resume()
        }
    }
}
