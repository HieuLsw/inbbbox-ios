//
//  ManagedShot.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import CoreData

class ManagedShot: NSManagedObject {

    @NSManaged var mngd_identifier: String
    @NSManaged var mngd_title: String
    @NSManaged var mngd_htmlDescription: NSAttributedString?
    @NSManaged var mngd_user: ManagedUser
    @NSManaged var mngd_shotImage: ManagedShotImage
    @NSManaged var mngd_createdAt: Date
    @NSManaged var mngd_animated: Bool
    @NSManaged var mngd_likesCount: UInt
    @NSManaged var mngd_viewsCount: UInt
    @NSManaged var mngd_commentsCount: UInt
    @NSManaged var mngd_bucketsCount: UInt
    @NSManaged var mngd_team: ManagedTeam?
    @NSManaged var mngd_attachmentsCount: UInt
    @NSManaged var mngd_htmlUrl: String

    @NSManaged var liked: Bool
    @NSManaged var projects: NSSet?
    @NSManaged var buckets: NSSet?

    func addBucket(_ bucket: ManagedBucket) {
        addObject(bucket, forKey: "buckets")
    }
}

extension ManagedShot: ShotType {

    var identifier: String { return mngd_identifier }
    var title: String { return mngd_title }
    var attributedDescription: NSAttributedString? { return mngd_htmlDescription }
    var user: UserType { return mngd_user }
    var shotImage: ShotImageType { return mngd_shotImage }
    var createdAt: Date { return mngd_createdAt }
    var animated: Bool { return mngd_animated }
    var likesCount: UInt { return mngd_likesCount }
    var viewsCount: UInt { return mngd_viewsCount }
    var commentsCount: UInt { return mngd_commentsCount }
    var bucketsCount: UInt { return mngd_bucketsCount }
    var team: TeamType? { return mngd_team }
    var attachmentsCount: UInt { return mngd_attachmentsCount }
    var htmlUrl: String { return mngd_htmlUrl }
}
