//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit


class ShotsProvider {

    var apiShotsProvider = APIShotsProvider()
    var managedShotsProvider = ManagedShotsProvider()
    var userStorageClass = UserStorage.self

    func provideShots() -> Promise<[ShotType]?> {
        return apiShotsProvider.provideShots()
    }

    func provideMyLikedShots() -> Promise<[ShotType]?> {
        if userStorageClass.isUserSignedIn {
            return apiShotsProvider.provideMyLikedShots()
        }
        return managedShotsProvider.provideMyLikedShots()
    }

    func provideShotsForUser(_ user: UserType) -> Promise<[ShotType]?> {
        return apiShotsProvider.provideShotsForUser(user)
    }

    func provideLikedShotsForUser(_ user: UserType) -> Promise<[ShotType]?> {
        assert(userStorageClass.isUserSignedIn, "Cannot provide shots for user when user is not signed in")
        return Promise<[ShotType]?> { fulfill, reject in
            firstly {
                apiShotsProvider.provideLikedShotsForUser(user)
            }.then { shots -> Void in
                let shotsSorted = shots?.sorted {
                    return $0.createdAt.compare($1.createdAt) == ComparisonResult.orderedAscending
                }
                fulfill(shotsSorted)
            }.catch(execute: reject)
        }

    }

    func provideShotsForBucket(_ bucket: BucketType) -> Promise<[ShotType]?> {
        if userStorageClass.isUserSignedIn {
            return apiShotsProvider.provideShotsForBucket(bucket)
        }
        return managedShotsProvider.provideShotsForBucket(bucket)
    }

    func nextPage() -> Promise<[ShotType]?> {
        return apiShotsProvider.nextPage()
    }

    func previousPage() -> Promise<[ShotType]?> {
        return apiShotsProvider.previousPage()
    }
}
