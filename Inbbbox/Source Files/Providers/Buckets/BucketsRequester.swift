//
//  BucketsRequester.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/23/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class BucketsRequester {
    let apiBucketsRequester = APIBucketsRequester()
    let managedBucketsRequester = ManagedBucketsRequester()

    func postBucket(_ name: String, description: NSAttributedString?) -> Promise<BucketType> {
        if UserStorage.isUserSignedIn {
            return apiBucketsRequester.postBucket(name, description: description)
        }
        return managedBucketsRequester.addBucket(name, description: description)
    }

    func addShot(_ shot: ShotType, toBucket bucket: BucketType) -> Promise<Void> {
        AnalyticsManager.trackUserActionEvent(.addToBucket)
        if UserStorage.isUserSignedIn {
            return apiBucketsRequester.addShot(shot, toBucket: bucket)
        }
        return managedBucketsRequester.addShot(shot, toBucket: bucket)
    }

    func removeShot(_ shot: ShotType, fromBucket bucket: BucketType) -> Promise<Void> {
        if UserStorage.isUserSignedIn {
            return apiBucketsRequester.removeShot(shot, fromBucket: bucket)
        }
        return managedBucketsRequester.removeShot(shot, fromBucket: bucket)
    }
}
