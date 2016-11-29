//
//  CoreDataHelper.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import CoreData

func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let modelPath = Bundle.main.path(forResource: "StoreData", ofType: "momd")
    
    let managedObjectModel = NSManagedObjectModel(contentsOf: URL(fileURLWithPath: modelPath!))!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
        // This class is only used for tesing. No need to elevate error here, test will fail.
    }
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}
