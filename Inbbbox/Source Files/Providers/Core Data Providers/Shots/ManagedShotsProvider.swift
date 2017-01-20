//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import CoreData

class ManagedShotsProvider {

    var managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.managedObjectContext

    func provideMyLikedShots() -> Promise<[ShotType]?> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedShot.entityName)
        fetchRequest.predicate = NSPredicate(format: "liked == true")

        return Promise<[ShotType]?> { fulfill, reject in
            do {
                if let managedShots = try managedObjectContext.fetch(fetchRequest) as? [ManagedShot] {
                    fulfill(managedShots.map { $0 as ShotType })
                }
            } catch {
                reject(error)
            }
        }
    }

    func provideManagedLikedShots() -> Promise<[LikedShot]?> {
        return Promise<[LikedShot]?> { fulfill, reject in
            firstly {
                provideMyLikedShots()
            }.then { managedShots -> Void in
                if let shots = managedShots{
                    return fulfill(shots.map { LikedShot(likeIdentifier: $0.identifier, createdAt: Date(), shot: $0) })
                }
                fulfill(nil)
            }.catch(execute: reject)
        }
    }

    func provideShotsForBucket(_ bucket: BucketType) -> Promise<[ShotType]?> {

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedShot.entityName)
        fetchRequest.predicate = NSPredicate(format: "ANY buckets.mngd_identifier == %@", bucket.identifier)

        return Promise<[ShotType]?> { fulfill, reject in
            do {
                if let managedShots = try managedObjectContext.fetch(fetchRequest) as? [ManagedShot] {
                    fulfill(managedShots.map { $0 as ShotType })
                }
            } catch {
                reject(error)
            }
        }
    }
}
