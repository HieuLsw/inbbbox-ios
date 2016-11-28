//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class ShotsRequester {

    let apiShotsRequester = APIShotsRequester()
    let managedShotsRequester = ManagedShotsRequester()

    func likeShot(_ shot: ShotType) -> Promise<Void> {
        AnalyticsManager.trackUserActionEvent(.like)
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.likeShot(shot)
        }
        return managedShotsRequester.likeShot(shot)
    }

    func unlikeShot(_ shot: ShotType) -> Promise<Void> {
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.unlikeShot(shot)
        }
        return managedShotsRequester.unlikeShot(shot)
    }

    func isShotLikedByMe(_ shot: ShotType) -> Promise<Bool> {
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.isShotLikedByMe(shot)
        }
        return managedShotsRequester.isShotLikedByMe(shot)
    }

    func userBucketsForShot(_ shot: ShotType) -> Promise<[BucketType]?> {
        if UserStorage.isUserSignedIn {
            return apiShotsRequester.userBucketsForShot(shot)
        }
        return managedShotsRequester.userBucketsForShot(shot)
    }

    func fetchShotDetails(_ shot: ShotType) -> Promise<ShotType> {
        return apiShotsRequester.fetchShotDetailsForShot(shot)
    }
}
