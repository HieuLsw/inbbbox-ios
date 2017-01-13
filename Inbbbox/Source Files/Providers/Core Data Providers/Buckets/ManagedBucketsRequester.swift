//
//  ManagedBucketsRequester.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/23/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import CoreData
import SwiftyJSON

class ManagedBucketsRequester {

    let managedObjectContext: NSManagedObjectContext
    let managedObjectsProvider: ManagedObjectsProvider

    init(managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.managedObjectContext) {
        self.managedObjectContext = managedObjectContext
        managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: managedObjectContext)
    }

    func addBucket(_ name: String, description: NSAttributedString?) -> Promise<BucketType> {

        let bucket = Bucket(
            identifier: ProcessInfo.processInfo.globallyUniqueString.replacingOccurrences(of: "-", with: ""),
            name: name,
            attributedDescription: description,
            shotsCount: 0,
            createdAt: Date(),
            owner: User(json: guestJSON)
        )


        let managedBucket = managedObjectsProvider.managedBucket(bucket)

        return Promise<BucketType> { fulfill, reject in
            do {
                try managedObjectContext.save()
                fulfill(managedBucket)
            } catch {
                reject(error)
            }
        }
    }

    func addShot(_ shot: ShotType, toBucket bucket: BucketType) -> Promise<Void> {
        let managedBucket = managedObjectsProvider.managedBucket(bucket)
        let managedShot = managedObjectsProvider.managedShot(shot)
        if let _ = managedBucket.shots {
            managedBucket.addShot(managedShot)
        } else {
            managedBucket.shots = NSSet(object: managedShot)
        }
        managedBucket.mngd_shotsCount += 1
        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }

    func removeShot(_ shot: ShotType, fromBucket bucket: BucketType) -> Promise<Void> {

        let managedBucket = managedObjectsProvider.managedBucket(bucket)
        let managedShot = managedObjectsProvider.managedShot(shot)
        if let managedShots = managedBucket.shots {
            let mutableShots = NSMutableSet(set: managedShots)
            mutableShots.remove(managedShot)
            managedBucket.shots = mutableShots.copy() as? NSSet
            managedBucket.mngd_shotsCount -= 1
        }
        return Promise<Void> { fulfill, reject in
            do {
                fulfill(try managedObjectContext.save())
            } catch {
                reject(error)
            }
        }
    }
}

var guestJSON: JSON {
    let guestDictionary = [
        "id" : "guest.identifier",
        "name" : "guest.name",
        "username" : "guest.username",
        "avatar_url" : "guest.avatar.url",
        "shots_count" : 0,
        "param_to_omit" : "guest.param",
        "type" : "User"
    ] as [String : Any]
    return JSON(guestDictionary)
}
