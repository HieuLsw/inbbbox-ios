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
     Provides logged user's teams.

     - returns: Promise which resolves with teams or nil.
     */
    func provideTeamsOfCurrentUser() -> Promise<[TeamType]?> {

        let query = TeamsQuery()
        return Promise<[TeamType]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (teams: [Team]?) -> Void in
                fulfill(teams.flatMap { $0.map { $0 as TeamType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides logged user's teams.

     - parameter user: User to get teams for.
     
     - returns: Promise which resolves with teams or nil.
    */
    func provideTeamsFor(user: UserType) -> Promise<[UserType]?> {

        let query = TeamsQuery(teamsOfUser: user)
        return Promise<[UserType]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (teams: [User]?) -> Void in
                fulfill(teams.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides next page of teams.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with users or nil.
     */
    func teamsNextPage() -> Promise<[UserType]?> {
        return Promise <[UserType]?> { fulfill, reject in
            firstly {
                nextPageFor(User.self)
            }.then { teams -> Void in
                fulfill(teams.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides team's members.

     - parameter team: Team to get members for.

    - returns: Promise which resolves with users or nil.
    */
    func provideMembersForTeam(_ team: TeamType) -> Promise<[UserType]?> {
        let query = TeamMembersQuery(team: team)
        return provideMembersForQuery(query)
    }
    
    /**
     Provides team's members.
     
     - parameter team: Team to get members for.
     
     - returns: Promise which resolves with users or nil.
     */
    func provideMembersForTeam(_ team: UserType) -> Promise<[UserType]?> {
        let query = TeamMembersQuery(team: team)
        return provideMembersForQuery(query)
    }

    private func provideMembersForQuery(_ query: TeamMembersQuery) -> Promise<[UserType]?> {
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
                nextPageFor(User.self)
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
                previousPageFor(User.self)
            }.then { buckets -> Void in
                fulfill(buckets.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }
}
