//
//  APIBucketsProvider.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 27/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

/// Provides interface for dribbble buckets read API
class APIBucketsProvider: PageableProvider {

    /**
     Provides authenticated user’s buckets.

     - Requires: Authenticated user.

     - returns: Promise which resolves with buckets or nil.
     */
    func provideMyBuckets() -> Promise<[BucketType]?> {

        let query = BucketQuery()
        return provideBucketsWithQueries([query], authentizationRequired: true)
    }

    /**
     Provides a given user’s buckets.

     - parameter user: User for who buckets should be provided.

     - returns: Promise which resolves with buckets or nil.
     */
    func provideBucketsForUser(_ user: UserType) -> Promise<[BucketType]?> {
        return provideBucketsForUsers([user])
    }

    /**
     Provides a given users' buckets.

     - parameter users: Array of users for whose buckets should be provided.

     - returns: Promise which resolves with buckets or nil.
     */
    func provideBucketsForUsers(_ users: [UserType]) -> Promise<[BucketType]?> {

        let queries = users.map { BucketQuery(user: $0) } as [Query]
        return provideBucketsWithQueries(queries, authentizationRequired: false)
    }

    /**
     Provides next page of buckets.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with buckets or nil.
     */
    func nextPage() -> Promise<[BucketType]?> {
        return Promise <[BucketType]?> { fulfill, reject in
            firstly {
                nextPageFor(Bucket)
            }.then { buckets -> Void in
                fulfill(buckets.flatMap { $0.map { $0 as BucketType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides previous page of buckets.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with buckets or nil.
     */
    func previousPage() -> Promise<[BucketType]?> {
        return Promise <[BucketType]?> { fulfill, reject in
            firstly {
                previousPageFor(Bucket)
            }.then { buckets -> Void in
                fulfill(buckets.flatMap { $0.map { $0 as BucketType } })
            }.catch(execute: reject)
        }
    }
}

private extension APIBucketsProvider {

    func provideBucketsWithQueries(_ queries: [Query], authentizationRequired: Bool) -> Promise<[BucketType]?> {
        return Promise<[BucketType]?> { fulfill, reject in
            firstly {
                verifyAuthenticationStatus(authentizationRequired)
            }.then {
                self.firstPageForQueries(queries, withSerializationKey: nil)
            }.then {  (buckets: [Bucket]?) -> Void in
               fulfill(buckets.flatMap { $0.map { $0 as BucketType } })
            }.catch(execute: reject)
        }
    }
}
