//
//  ManagedProjectsProvider.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/22/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import CoreData

class ManagedProjectsProvider {

    let managedObjectContext: NSManagedObjectContext
    let managedObjectsProvider: ManagedObjectsProvider

    init() {
        managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.managedObjectContext
        managedObjectsProvider = ManagedObjectsProvider(managedObjectContext: managedObjectContext)
    }

    func provideProjectsForShot(_ shot: ShotType) -> Promise<[ProjectType]?> {
        return Promise<[ProjectType]?> { fulfill, reject in
            let managedShot = managedObjectsProvider.managedShot(shot)
            let managedProjects = managedShot.projects?.allObjects as? [ManagedProject]
            fulfill(managedProjects)
        }
    }
}
