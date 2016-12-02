//
//  ManagedProject.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/18/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import CoreData

class ManagedProject: NSManagedObject {
    @NSManaged var mngd_identifier: String
    @NSManaged var mngd_name: String?
    @NSManaged var mngd_htmlDescription: NSAttributedString?
    @NSManaged var mngd_createdAt: Date
    @NSManaged var mngd_shotsCount: UInt
}

extension ManagedProject: ProjectType {
    var identifier: String { return mngd_identifier }
    var name: String? { return mngd_name }
    var attributedDescription: NSAttributedString? { return mngd_htmlDescription }
    var createdAt: Date { return mngd_createdAt }
    var shotsCount: UInt { return mngd_shotsCount }
}
