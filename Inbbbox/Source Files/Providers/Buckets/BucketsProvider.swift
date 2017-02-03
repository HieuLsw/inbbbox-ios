//
//  BucketsProvider.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/23/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class BucketsProvider {
    let apiBucketsProvider = APIBucketsProvider()
    let managedBucketsProvider = ManagedBucketsProvider()

    func provideMyBuckets() -> Promise<[BucketType]?> {
        if UserStorage.isUserSignedIn {
            return apiBucketsProvider.provideMyBuckets()
        }
        return managedBucketsProvider.provideMyBuckets()
    }

    func provideBuckets(forUser user: UserType) -> Promise<[BucketType]?> {
        assert(UserStorage.isUserSignedIn, "Cannot provide buckets when user is not signed in")
        return apiBucketsProvider.provideBucketsForUser(user)
    }

    func provideBuckets(forUsers users: [UserType]) -> Promise<[BucketType]?> {
        assert(UserStorage.isUserSignedIn, "Cannot provide buckets when user is not signed in")
        return apiBucketsProvider.provideBucketsForUsers(users)
    }

    func nextPage() -> Promise<[BucketType]?> {
        assert(UserStorage.isUserSignedIn, "Cannot provide buckets for next page when user is not signed in")
        return apiBucketsProvider.nextPage()
    }

    func previousPage() -> Promise<[BucketType]?> {
        assert(UserStorage.isUserSignedIn, "Cannot provide buckets for previous page when user is not signed in")
        return apiBucketsProvider.previousPage()
    }
}
