//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit


class ShotsProvider {

    var apiShotsProvider = APIShotsProvider(page: 1, pagination: 30)
    var managedShotsProvider = ManagedShotsProvider()
    var userStorageClass = UserStorage.self

    private var providing: ProviderType?

    /// This enum helps to decide to which Cache insert shots after invoking `nextPage()` method.
    /// - SeeAlso: nextPage()
    private enum ProviderType {
        case likedShots
        case other
    }

    func provideShots() -> Promise<[ShotType]?> {
        return apiShotsProvider.provideShots()
    }

    func provideMyLikedShots() -> Promise<[ShotType]?> {
        if userStorageClass.isUserSignedIn {
            return Promise<[ShotType]?> { fulfill, reject in
                if SharedCache.likedShots.elements.count > 0 {
                    return fulfill(SharedCache.likedShots.elements)
                }

                firstly {
                    providing = .likedShots
                    return Promise(value: Void())
                }.then {
                    self.apiShotsProvider.provideMyLikedShots()
                }.then { shots -> Void in
                    if let shots = shots {
                        SharedCache.likedShots.add(shots.flatMap { $0 as? Shot })
                    }
                    fulfill(shots)
                }.catch(execute: reject)
            }
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
        return Promise<[ShotType]?> { fulfill, reject in
            firstly {
                apiShotsProvider.nextPage()
            }.then { shots -> Void in
                if let providing = self.providing, let shots = shots {
                    switch providing {
                    case .likedShots: SharedCache.likedShots.append(contentsOf: shots.flatMap { $0 as? Shot })
                    default: break
                    }
                }
                fulfill(shots)
            }.catch(execute: reject)
        }
    }

    func previousPage() -> Promise<[ShotType]?> {
        return apiShotsProvider.previousPage()
    }
}
