//
//  PageRequest.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 28/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

typealias PageResponse = (json: JSON?, pages: (next: PageableComponent?, previous: PageableComponent?))

struct PageRequest: Requestable, Responsable {

    /// Query used to create page request.
    let query: Query

    // Session for page request.
    let session: NSURLSession

    init(query: Query, urlSession: NSURLSession = NSURLSession.inbbboxDefaultSession()) {
        self.query = query
        session = urlSession
    }

    /// Invoke page request.
    ///
    /// - returns:  Promise which resolves with `PageResponse`
    ///             that contains response as JSON and components for
    ///             next and previous pages.
    func resume() -> Promise<PageResponse> {
        return Promise<PageResponse> { fulfill, reject in

            do {
                try APIRateLimitKeeper.sharedKeeper.verifyRateLimit()
            } catch {
                throw error
            }

            let dataTask = session.dataTaskWithRequest(foundationRequest) { data, response, error in

                if let error = error {
                    reject(error); return
                }

                firstly {
                    self.responseWithData(data, response: response)

                }.then { response -> Void in

                    var next: PageableComponent?
                    var previous: PageableComponent?

                    if let header = response.header {
                        next = PageableComponentSerializer.nextPageableComponentWithSentQuery(self.query,
                                receivedHeader: header)
                        previous = PageableComponentSerializer.previousPageableComponentWithSentQuery(self.query,
                                receivedHeader: header)
                    }

                    fulfill((
                        json: response.json,
                        pages: (
                            next: next,
                            previous: previous)
                    ))

                }.error(reject)
            }

            dataTask.resume()
        }
    }
}
