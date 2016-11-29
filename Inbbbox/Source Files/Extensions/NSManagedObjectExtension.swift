//
//  NSManagedObjectExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    class var entityName: String {
        return String(describing: self)
    }

    func addObject(_ value: NSManagedObject, forKey: String) {
        mutableSetValue(forKey: forKey).add(value)
    }

    func removeObject(_ value: NSManagedObject, forKey: String) {
        mutableSetValue(forKey: forKey).remove(value)
    }
}
