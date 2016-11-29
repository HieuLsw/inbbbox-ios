//
//  ManagedBucket.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import CoreData

class ManagedBucket: NSManagedObject {

    @NSManaged var mngd_identifier: String
    @NSManaged var mngd_name: String
    @NSManaged var mngd_htmlDescription: NSAttributedString?
    @NSManaged var mngd_shotsCount: UInt
    @NSManaged var mngd_createdAt: Date
    @NSManaged var mngd_owner: ManagedUser

    @NSManaged var shots: NSSet?

    func addShot(_ shot: ManagedShot) {
        addObject(shot, forKey: "shots")
    }
}

extension ManagedBucket: BucketType {
    var identifier: String { return mngd_identifier }
    var name: String { return mngd_name }
    var attributedDescription: NSAttributedString? { return mngd_htmlDescription }
    var shotsCount: UInt { return mngd_shotsCount}
    var createdAt: Date { return mngd_createdAt }
    var owner: UserType { return mngd_owner }
}
