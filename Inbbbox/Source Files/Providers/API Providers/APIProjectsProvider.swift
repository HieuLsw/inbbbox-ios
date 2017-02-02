//
//  APIProjectsProvider.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

/// Provides interface for dribbble projects API
class APIProjectsProvider: PageableProvider {

    /**
     Provides projects for given shot.

     - parameter shot: Shot which projects should be provided.

     - returns: Promise which resolves with projects or nil.
     Theoretically should return 1 project only.
     */
    func provideProjectsForShot(_ shot: ShotType) -> Promise<[ProjectType]?> {

        let query = ProjectsQuery(shot: shot)

        return Promise<[ProjectType]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (projects: [Project]?) -> Void in
                fulfill(projects.flatMap { $0.map { $0 as ProjectType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides projects for given user.

     - parameter user: User whos projects should be provided.

     - returns: Promise which resolves with projects or nil.
     */
    func provideProjectsForUser(_ user: UserType) -> Promise<[ProjectType]?> {

        let query = ProjectsQuery(user: user)

        return Promise<[ProjectType]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (projects: [Project]?) -> Void in
                fulfill(projects.flatMap { $0.map { $0 as ProjectType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides next page of projects.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with projects or nil.
     */
    func nextPage() -> Promise<[ProjectType]?> {
        return Promise <[ProjectType]?> { fulfill, reject in
            firstly {
                nextPageFor(Project.self)
            }.then { projects -> Void in
                fulfill(projects.flatMap { $0.map { $0 as ProjectType } })
            }.catch(execute: reject)
        }
    }
}
