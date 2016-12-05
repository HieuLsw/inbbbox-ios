//
//  CoreDataHelper.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import CoreData

func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let modelPath = NSBundle.mainBundle().pathForResource("StoreData", ofType: "momd")
    
    let managedObjectModel = NSManagedObjectModel(contentsOfURL: NSURL(fileURLWithPath: modelPath!))!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do {
        try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    } catch {
        // This class is only used for tesing. No need to elevate error here, test will fail.
    }
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}
