//
//  ManagedBucketsProvider.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/23/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import CoreData

class ManagedBucketsProvider {

    let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.managedObjectContext

    func provideMyBuckets() -> Promise<[BucketType]?> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedBucket.entityName)

        return Promise<[BucketType]?> { fulfill, reject in
            do {
                if let managedBuckets = try managedObjectContext.fetch(fetchRequest) as? [ManagedBucket] {
                    fulfill(managedBuckets.map { $0 as BucketType })
                }
            } catch {
                reject(error)
            }
        }
    }
}
