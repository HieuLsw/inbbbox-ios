//
//  ProjectsProvider.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class ProjectsProvider {

    let apiProjectsProvider = APIProjectsProvider()
    let managedProjectsProvider = ManagedProjectsProvider()

    func provideProjectsForShot(_ shot: ShotType) -> Promise<[ProjectType]?> {
        if UserStorage.isUserSignedIn {
            return apiProjectsProvider.provideProjectsForShot(shot)
        }
        return managedProjectsProvider.provideProjectsForShot(shot)
    }

    func provideProjects(forUser user: UserType) -> Promise<[ProjectType]?> {
        return apiProjectsProvider.provideProjectsForUser(user)
    }

    func nextPage() -> Promise<[ProjectType]?> {
        return apiProjectsProvider.nextPage()
    }
}
