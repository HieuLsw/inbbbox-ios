//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import CoreData

class ManagedShotsRequester {

    let managedObjectContext: NSManagedObjectContext
    let managedObjectsProvider: ManagedObjectsProvider

    init() {
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.managedObjectContext
        managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: managedObjectContext)
    }


    func likeShot(_ shot: ShotType) -> Promise<Void> {
        let managedShot = managedObjectsProvider.managedShot(shot)
        managedShot.liked = true
        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }

    func unlikeShot(_ shot: ShotType) -> Promise<Void> {
        let managedShot = managedObjectsProvider.managedShot(shot)
        managedShot.liked = false
        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }

    func isShotLikedByMe(_ shot: ShotType) -> Promise<Bool> {
        let managedShot = managedObjectsProvider.managedShot(shot)
        return Promise<Bool>(value: managedShot.liked)
    }

    func userBucketsForShot(_ shot: ShotType) -> Promise<[BucketType]?> {
        let managedShot = managedObjectsProvider.managedShot(shot)
        let buckets = managedShot.buckets?.allObjects as? [BucketType]
        return Promise<[BucketType]?>(value: buckets)
    }
}
