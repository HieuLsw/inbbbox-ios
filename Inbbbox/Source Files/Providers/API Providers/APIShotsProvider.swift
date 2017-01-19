//
//  APIShotsProvider.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 22/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

/// Provides interface for dribbble shots API
class APIShotsProvider: PageableProvider {

    /// Used only when using provideShots() method.
    var configuration = APIShotsProviderConfiguration()

    /// Defines source to provide.
    enum SourceType {
        case general, bucket, user, liked
    }

    /// Currently fetched source.
    var currentSourceType: SourceType?

    fileprivate var likesFetched: UInt = 0
    fileprivate var likesToFetch: UInt = 0
    fileprivate var likes = [ShotType]()
    fileprivate var fetchingLikes = false
    fileprivate var lastPageOfLikesReached = false

    /**
     Provides shots with current configuration, pagination and page.

     - returns: Promise which resolves with shots or nil.
     */
    func provideShots() -> Promise<[ShotType]?> {
        resetAnUseSourceType(.general)
        return provideShotsWithQueries(activeQueries)
    }

    /**
     Provides shots for current user.

     - returns: Promise which resolves with shots or nil.
     */
    func provideMyLikedShots() -> Promise<[ShotType]?> {
        return Promise<[ShotType]?> { fulfill, reject in
            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                self.resetAnUseSourceType(.liked)

                let query = ShotsQuery(type: .likedShots)
                return self.provideShotsWithQueries([query], serializationKey: "shot")
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    /**
     Provides liked shots.

     - parameter max: Number of liked shots to fetch.

     - returns: Promise which resolves with liked shots or nil.
     */
    func provideLikedShots(_ max: UInt) -> Promise<[ShotType]?> {
        return Promise<[ShotType]?> {fulfill, reject in
            firstly {
                prepareForFetchingLikes()
            }.then {
                self.fetchLikes(max)
            }.then {
                fulfill(self.likes)
            }.catch { error in
                reject(error)
            }
        }
    }

    /**
     Provides shots for given user.

     - parameter user: User whose shots should be provided.

     - returns: Promise which resolves with shots or nil.
     */
    func provideShotsForUser(_ user: UserType) -> Promise<[ShotType]?> {
        resetAnUseSourceType(.user)

        let query = ShotsQuery(type: .userShots(user))
        return provideShotsWithQueries([query])
    }

    /**
     Provides liked shots for given user.

     - parameter user: User whose liked shots should be provided.

     - returns: Promise which resolves with shots or nil.
     */
    func provideLikedShotsForUser(_ user: UserType) -> Promise<[ShotType]?> {
        resetAnUseSourceType(.liked)

        let query = ShotsQuery(type: .userLikedShots(user))
        return provideShotsWithQueries([query], serializationKey: "shot")
    }

    /**
     Provides shots for given bucket.

     - parameter bucket: Bucket which shots should be provided.

     - returns: Promise which resolves with shots or nil.
     */
    func provideShotsForBucket(_ bucket: BucketType) -> Promise<[ShotType]?> {
        resetAnUseSourceType(.bucket)

        let query = ShotsQuery(type: .bucketShots(bucket))
        return provideShotsWithQueries([query])
    }

    /**
     Provides next page of shots.

     - Warning: You have to use any of provideShots... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with shots or nil.
     */
    func nextPage() -> Promise<[ShotType]?> {
        return fetchPage(nextPageFor(Shot.self))
    }

    /**
     Provides previous page of shots.

     - Warning: You have to use any of provideShots... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with shots or nil.
     */
    func previousPage() -> Promise<[ShotType]?> {
        return fetchPage(previousPageFor(Shot.self))
    }

    /**
     Resets currently used `SourceType`

     - parameter type: `SourceType` to reset
     */
    func resetAnUseSourceType(_ type: SourceType) {
        currentSourceType = type
        resetPages()
    }

    /**
     Sorts given array of T. T have conform to `Sortable` protocol.

     - parameter shots: shots to sort.
     
     - returns: sorted shots.
     */
    func sort<T: Sortable>(_ shots: [T]?) -> [T]? {
        return shots?.unique.sorted { $0.createdAt.compare($1.createdAt as Date) == .orderedDescending }
    }
}

private extension APIShotsProvider {

    var activeQueries: [Query] {
        return configuration.sources.map {
            configuration.queryByConfigurationForQuery(ShotsQuery(type: .list), source: $0)
        }
    }

    func provideShotsWithQueries(_ queries: [Query], serializationKey key: String? = nil) -> Promise<[ShotType]?> {
        return Promise<[ShotType]?> { fulfill, reject in

            firstly {
                firstPageForQueries(queries, withSerializationKey: key)
            }.then {
                self.serialize($0, fulfill)
            }.catch(execute: reject)
        }
    }

    func fetchPage(_ promise: Promise<[Shot]?>) -> Promise<[ShotType]?> {
        return Promise<[ShotType]?> { fulfill, reject in

            if currentSourceType == nil {
                throw PageableProviderError.behaviourUndefined
            }

            firstly {
                promise
            }.then {
                self.serialize($0, fulfill)
            }.catch(execute: reject)
        }
    }

    func serialize(_ shots: [Shot]?, _ fulfill: @escaping ([ShotType]?) -> Void) {
        fulfill(sort(shots).flatMap { $0.map { $0 as ShotType } })
    }

    func prepareForFetchingLikes() -> Promise<Void> {
        likes.removeAll()
        likesFetched = 0
        likesToFetch = 0
        lastPageOfLikesReached = false
        return Promise<Void>(value: Void())
    }

    func fetchLikes(_ max: UInt) -> Promise<Void> {
        likesToFetch = max
        return Promise<Void> { fulfill, reject in
            firstly {
                fetchSingleBatch()
            }.then {
                if self.likesFetched == self.likesToFetch || self.lastPageOfLikesReached {
                    self.fetchingLikes = false
                    fulfill()
                    return Promise<Void>(value: Void())
                }
                return self.fetchLikes(self.likesToFetch)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func fetchSingleBatch() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            firstly {
                if !fetchingLikes {
                    fetchingLikes = true
                    return provideMyLikedShots()
                } else {
                    return nextPage()
                }
            }.then { (shots: [ShotType]?) -> Void in
                if let shots = shots {
                    self.likesFetched += UInt((shots.count))
                    self.likes.append(contentsOf: shots)
                    fulfill()
                }
            }.catch { error in
                if let lastPage = error as? PageableProviderError, lastPage == .didReachLastPage {
                    self.lastPageOfLikesReached = true
                    return fulfill()
                }
                return reject(error)
            }
        }
    }
}
