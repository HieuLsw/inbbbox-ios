//
//  APITeamsProvider.swift
//  Inbbbox
//
//  Created by Peter Bruz on 10/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

/// Provides interface for dribbble teams read API
class APITeamsProvider: PageableProvider {

    /**
     Provides team's members.

     - parameter team: Team to get members for.

     - returns: Promise which resolves with users or nil.
     */
    func provideMembersForTeam(_ team: TeamType) -> Promise<[UserType]?> {

        let query = TeamMembersQuery(team: team)
        return Promise<[UserType]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (users: [User]?) -> Void in
                fulfill(users.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides next page of team's members.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with users or nil.
     */
    func nextPage() -> Promise<[UserType]?> {
        return Promise <[UserType]?> { fulfill, reject in
            firstly {
                nextPageFor(User)
            }.then { buckets -> Void in
                fulfill(buckets.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides previous page of team's members.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with users or nil.
     */
    func previousPage() -> Promise<[UserType]?> {
        return Promise <[UserType]?> { fulfill, reject in
            firstly {
                previousPageFor(User)
            }.then { buckets -> Void in
                fulfill(buckets.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }
}
