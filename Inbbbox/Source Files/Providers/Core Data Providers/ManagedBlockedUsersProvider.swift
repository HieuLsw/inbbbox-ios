//
//  ManagedBlockedUsersProvider.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import PromiseKit
import CoreData

class ManagedBlockedUsersProvider {

    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as? AppDelegate)!.managedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func provideBlockedUsers() -> Promise<[UserType]?> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedBlockedUser.entityName)

        return Promise<[UserType]?> { fulfill, reject in
            do {
                if let managedBlockedUsers = try managedObjectContext.fetch(fetchRequest) as? [ManagedBlockedUser] {
                    fulfill(managedBlockedUsers.map { $0 as UserType })
                }
            } catch {
                reject(error)
            }
        }
    }
}
