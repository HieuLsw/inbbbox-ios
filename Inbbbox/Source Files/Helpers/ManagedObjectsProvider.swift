//
//  ManagedObjectsProvider.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/18/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import CoreData

struct ManagedObjectsProvider {

    let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    func managedShot(_ shot: ShotType) -> ManagedShot {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedShot.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_identifier == %@", shot.identifier)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        if let managedShot = firstFetchedObject as? ManagedShot {
            return managedShot
        }

        let managedShotEntity = NSEntityDescription.entity(forEntityName: ManagedShot.entityName,
                                          in: managedObjectContext)!
        let managedShot = ManagedShot(entity: managedShotEntity,
              insertInto: managedObjectContext)
        managedShot.mngd_identifier = shot.identifier
        managedShot.mngd_title = shot.title
        managedShot.mngd_htmlDescription = shot.attributedDescription
        managedShot.mngd_user = managedUser(shot.user)
        managedShot.mngd_shotImage = managedShotImage(shot.shotImage)
        managedShot.mngd_createdAt = shot.createdAt
        managedShot.mngd_animated = shot.animated
        managedShot.mngd_likesCount = shot.likesCount
        managedShot.mngd_viewsCount = shot.viewsCount
        managedShot.mngd_commentsCount = shot.commentsCount
        managedShot.mngd_bucketsCount = shot.bucketsCount
        managedShot.mngd_htmlUrl = shot.htmlUrl
        if let team = shot.team {
            managedShot.mngd_team = managedTeam(team)
        }
        return managedShot
    }

    func managedUser(_ user: UserType) -> ManagedUser {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedUser.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_identifier == %@", user.identifier)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        if let managedUser = firstFetchedObject as? ManagedUser {
            return managedUser
        }

        let managedUserEntity = NSEntityDescription.entity(forEntityName: ManagedUser.entityName,
                                          in: managedObjectContext)!
        let managedUser = ManagedUser(entity: managedUserEntity,
              insertInto: managedObjectContext)
        managedUser.mngd_identifier = user.identifier
        managedUser.mngd_name = user.name
        managedUser.mngd_username = user.username
        managedUser.mngd_avatarURL = user.avatarURL?.absoluteString
        managedUser.mngd_shotsCount = user.shotsCount
        managedUser.mngd_accountType = user.accountType?.rawValue
        managedUser.mngd_followersCount = user.followersCount
        managedUser.mngd_followingsCount = user.followingsCount
        managedUser.mngd_projectsCount = user.projectsCount
        managedUser.mngd_bucketsCount = user.bucketsCount
        managedUser.mngd_bio = user.bio
        managedUser.mngd_location = user.location
        return managedUser
    }

    func managedTeam(_ team: TeamType) -> ManagedTeam {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedTeam.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_identifier == %@", team.identifier)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        if let managedTeam = firstFetchedObject as? ManagedTeam {
            return managedTeam
        }

        let managedTeamEntity = NSEntityDescription.entity(forEntityName: ManagedTeam.entityName,
                                          in: managedObjectContext)!
        let managedTeam = ManagedTeam(entity: managedTeamEntity,
              insertInto: managedObjectContext)
        managedTeam.mngd_identifier = team.identifier
        managedTeam.mngd_name = team.name
        managedTeam.mngd_username = team.username
        managedTeam.mngd_avatarURL = team.avatarURL?.absoluteString
        managedTeam.mngd_createdAt = team.createdAt
        return managedTeam
    }

    func managedShotImage(_ shotImage: ShotImageType) -> ManagedShotImage {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedShotImage.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_normalURL == %@",
                shotImage.normalURL.absoluteString)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        if let managedShotImage = firstFetchedObject as? ManagedShotImage {
            return managedShotImage
        }
        let managedShotImageEntity = NSEntityDescription.entity(forEntityName: ManagedShotImage.entityName,
                                               in: managedObjectContext)!
        let managedShotImage = ManagedShotImage(entity: managedShotImageEntity,
                        insertInto: managedObjectContext)
        managedShotImage.mngd_hidpiURL = shotImage.hidpiURL?.absoluteString
        managedShotImage.mngd_normalURL = shotImage.normalURL.absoluteString
        managedShotImage.mngd_teaserURL = shotImage.teaserURL.absoluteString
        return managedShotImage
    }

    func managedBucket(_ bucket: BucketType) -> ManagedBucket {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedBucket.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_identifier == %@", bucket.identifier)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        if let managedBucket = firstFetchedObject as? ManagedBucket {
            return managedBucket
        }
        let managedBucketEntity = NSEntityDescription.entity(forEntityName: ManagedBucket.entityName,
                                            in: managedObjectContext)!
        let managedBucket = ManagedBucket(entity: managedBucketEntity,
                  insertInto: managedObjectContext)
        managedBucket.mngd_identifier = bucket.identifier
        managedBucket.mngd_name = bucket.name
        managedBucket.mngd_htmlDescription = bucket.attributedDescription
        managedBucket.mngd_shotsCount = bucket.shotsCount
        managedBucket.mngd_createdAt = bucket.createdAt
        return managedBucket
    }

    func managedProject(_ project: ProjectType) -> ManagedProject {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedProject.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_identifier == %@", project.identifier)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        if let managedProject = firstFetchedObject as? ManagedProject {
            return managedProject
        }
        let managedProjectEntity = NSEntityDescription.entity(forEntityName: ManagedProject.entityName,
                                             in: managedObjectContext)!
        let managedProject = ManagedProject(entity: managedProjectEntity,
                    insertInto: managedObjectContext)
        managedProject.mngd_identifier = project.identifier
        managedProject.mngd_name = project.name
        managedProject.mngd_htmlDescription = project.attributedDescription
        managedProject.mngd_createdAt = project.createdAt
        managedProject.mngd_shotsCount = project.shotsCount
        return managedProject
    }

    func managedBlockedUser(_ user: UserType) -> ManagedBlockedUser? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedBlockedUser.entityName)
        fetchRequest.predicate = NSPredicate(format: "mngd_identifier == %@", user.identifier)

        let firstFetchedObject = try? managedObjectContext.fetch(fetchRequest).first
        return firstFetchedObject as? ManagedBlockedUser
    }
}
