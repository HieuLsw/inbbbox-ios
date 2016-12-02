//
//  APIBucketsRequester.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

/// Provides interface for dribbble buckets update, delete and create API
class APIBucketsRequester: Verifiable {

    /**
     Creates new bucket.

     - Requires: Authenticated user.

     - parameter name: Bucket's name.
     - parameter description: Bucket's description.

     - returns: Promise which resolves with newly created bucket.
     */
    func postBucket(_ name: String, description: NSAttributedString?) -> Promise<BucketType> {
        let query = CreateBucketQuery(name: name, description: description)
        return sendCreateBucketQuery(query, verifyTextLength: name)
    }

    /**
     Adds shot to given bucket.

     - Requires: Authenticated user.
     - Warning:  Authenticated user has to be owner of bucket.

     - parameter shot:   Shot which should be added to bucket.
     - parameter bucket: Bucket which should contain bucket.

     - returns: Promise which resolves with void.
     */
    func addShot(_ shot: ShotType, toBucket bucket: BucketType) -> Promise<Void> {

        let query = AddToBucketQuery(shot: shot, bucket: bucket)
        return sendBucketQuery(query)
    }

    /**
     Removes shot from given bucket.

     - Requires: Authenticated user.
     - Warning:  Authenticated user has to be owner of bucket.

     - parameter shot:   Shot which should be added to bucket.
     - parameter bucket: Bucket which should contain bucket.

     - returns: Promise which resolves with void.
     */
    func removeShot(_ shot: ShotType, fromBucket bucket: BucketType) -> Promise<Void> {

        let query = RemoveFromBucketQuery(shot: shot, bucket: bucket)
        return sendBucketQuery(query)
    }
}

private extension APIBucketsRequester {

    func sendBucketQuery(_ query: Query) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                Request(query: query).resume()
            }.then { _ -> Void in
                fulfill()
            }.catch(execute: reject)
        }
    }

    func sendCreateBucketQuery(_ query: Query, verifyTextLength text: String) -> Promise<BucketType> {
        return Promise<BucketType> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                self.verifyTextLength(text, min: 1, max: UInt.max)
            }.then {
                Request(query: query).resume()
            }.then { json -> Void in

                guard let json = json else {
                    throw ResponseError.unexpectedResponse
                }
                fulfill(Bucket.map(json))

            }.catch(execute: reject)
        }
    }
}
