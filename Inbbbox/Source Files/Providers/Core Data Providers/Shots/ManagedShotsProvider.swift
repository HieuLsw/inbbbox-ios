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
