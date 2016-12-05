//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class ShotsRequester {

    let apiShotsRequester = APIShotsRequester()
    let managedShotsRequester = ManagedShotsRequester()

    func likeShot(shot: ShotType) -> Promise<Void> {
        AnalyticsManager.trackUserActionEvent(.Like)
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.likeShot(shot)
        }
        return managedShotsRequester.likeShot(shot)
    }

    func unlikeShot(shot: ShotType) -> Promise<Void> {
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.unlikeShot(shot)
        }
        return managedShotsRequester.unlikeShot(shot)
    }

    func isShotLikedByMe(shot: ShotType) -> Promise<Bool> {
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.isShotLikedByMe(shot)
        }
        return managedShotsRequester.isShotLikedByMe(shot)
    }

    func userBucketsForShot(shot: ShotType) -> Promise<[BucketType]!> {
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.userBucketsForShot(shot)
        }
        return managedShotsRequester.userBucketsForShot(shot)
    }

    func fetchShotDetails(shot: ShotType) -> Promise<ShotType> {
        return apiShotsRequester.fetchShotDetailsForShot(shot)
    }
}
