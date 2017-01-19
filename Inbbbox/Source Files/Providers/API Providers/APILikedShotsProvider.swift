//
//  APILikedShotsProvider.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

final class APILikedShotsProvider: APIShotsProvider {

    /**
     Provides liked shots for current user.

     - returns: Promise which resolves with shots, of type `LikedShot` or nil.
     */
    func provideLikedShots() -> Promise<[LikedShot]?> {
        return Promise<[LikedShot]?> { fulfill, reject in
            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                self.resetAnUseSourceType(.liked)

                let query = ShotsQuery(type: .likedShots)
                return self.provideShotsWithQueries([query])
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    /**
     Provides next page of shots.

     - Warning: You have to use any of provideShots... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with shots of type `LikedShot` or nil.
     */
    func nextPageForLikes() -> Promise<[LikedShot]?> {
        return fetchPageForLikes(nextPageFor(LikedShot.self))
    }
}

fileprivate extension APILikedShotsProvider {

    func provideShotsWithQueries(_ queries: [Query], serializationKey key: String? = nil) -> Promise<[LikedShot]?> {
        return Promise<[LikedShot]?> { fulfill, reject in

            firstly {
                firstPageForQueries(queries, withSerializationKey: key)
            }.then {
                self.serialize($0, fulfill)
            }.catch(execute: reject)
        }
    }

    func fetchPageForLikes(_ promise: Promise<[LikedShot]?>) -> Promise<[LikedShot]?> {
        return Promise<[LikedShot]?> { fulfill, reject in

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

    func serialize(_ shots: [LikedShot]?, _ fulfill: @escaping ([LikedShot]?) -> Void) {
        fulfill(sort(shots).flatMap { $0.map { $0 as LikedShot } })
    }
}
