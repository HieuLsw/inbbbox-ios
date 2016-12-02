//
//  APIShotsRequester.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

/// Provides interface for dribbble shots update, delete and create API
class APIShotsRequester: Verifiable {

    /**
     Likes given shot.

     - Requires: Authenticated user.

     - parameter shot: Shot to like.

     - returns: Promise which resolves with void.
     */
    func likeShot(_ shot: ShotType) -> Promise<Void> {
        let query = LikeQuery(shot: shot)
        return sendShotQuery(query)
    }

    /**
     Unlikes given shot.

     - Requires: Authenticated user.
     - Warning:  Authenticated user has to previously like the shot.

     - parameter shot: Shot to unlike.

     - returns: Promise which resolves with void.
     */
    func unlikeShot(_ shot: ShotType) -> Promise<Void> {

        let query = UnlikeQuery(shot: shot)
        return sendShotQuery(query)
    }

    /**
     Checks whether shot is liked by authenticated user or not.

     - Requires: Authenticated user.

     - parameter shot: Shot to check.

     - returns: Promise which resolves with true (if user likes shot) or false (if don't)
     */
    func isShotLikedByMe(_ shot: ShotType) -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in

            let query = ShotLikedByMeQuery(shot: shot)

            firstly {
                sendShotQuery(query)
            }.then { _ in
                fulfill(true)
            }.catch { error in
                // According to API documentation, when response.code is 404,
                // then shot is not liked by authenticated user.
                (error as NSError).code == 404 ? fulfill(false) : reject(error)
            }
        }
    }

    /**
     Get buckets where owner is current user and contain given shot.

     - Requires: Authenticated user.

     - parameter shot: Shot to check.

     - returns: Promise which resolves with collection of Buckets
     */
    func userBucketsForShot(_ shot: ShotType) -> Promise<[BucketType]?> {

        return Promise<[BucketType]?> { fulfill, reject in

            let query = BucketsForShotQuery(shot: shot)

            firstly {
                sendShotQueryForRespone(query)
            }.then { json -> Void in
                let values = (json?.arrayValue.map({ return Bucket.map($0) as BucketType}))!.filter({ bucket -> Bool in
                    return bucket.owner.identifier == (UserStorage.currentUser?.identifier)!
                })
                fulfill(values)
            }.catch(execute: reject)
        }
    }

    /**
     Get shot details for a given shot in case we need updated data

     - Requires: Authenticated user.

     - parameter shot: Shot to check.

     - returns: Updated shot details
     */
    func fetchShotDetailsForShot(_ shot: ShotType) -> Promise<ShotType> {

        return Promise<ShotType> { fulfill, reject in

            let query = ShotDetailsQuery(shot: shot)
            firstly {
                sendShotQueryForRespone(query)
            }.then { json -> Void in

                guard let json = json else {
                    throw AuthenticatorError.unableToFetchUser
                }
                fulfill(Shot.map(json) as ShotType)

            }.catch(execute: reject)
        }
    }
}

private extension APIShotsRequester {

    func sendShotQuery(_ query: Query) -> Promise<Void> {
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

    func sendShotQueryForRespone(_ query: Query) -> Promise<JSON?> {
        return Promise<JSON?> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                Request(query: query).resume()
            }.then { json -> Void in
                fulfill(json)
            }.catch(execute: reject)
        }
    }
}
