//
//  APIConnectionsProvider.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 26/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

typealias Followee = UserType
typealias Follower = UserType

private let followerSerializationKey = "follower"
private let followeeSerializationKey = "followee"

/// Provides interface for dribbble followers and followees read API
class APIConnectionsProvider: PageableProvider {

    /**
     Provides a list the authenticated user’s followers.

     - Requires: Authenticated user.

     - returns: Promise which resolves with followers or nil.
     */
    func provideMyFollowers() -> Promise<[Follower]?> {

        let query = FollowersQuery()
        return provideUsersWithQueries([query], serializationKey: followerSerializationKey,
                authentizationRequired: true)
    }

    /**
    Provides a list who the authenticated user is following.

    - Requires: Authenticated user.

    - returns: Promise which resolves with followees or nil.
    */
    func provideMyFollowees() -> Promise<[Followee]?> {

        let query = FolloweesQuery()
        return provideUsersWithQueries([query], serializationKey: followeeSerializationKey,
                authentizationRequired: true)
    }

    /**
     Provides a given user’s followers list.

     - parameter user: User for who followers list should be provided.

     - returns: Promise which resolves with followers or nil.
     */
    func provideFollowersForUser(_ user: UserType) -> Promise<[Follower]?> {
        return provideFollowersForUsers([user])
    }

    /**
     Provides a given users' followers list.

     - parameter users: Users for whose followers list should be provided.

     - returns: Promise which resolves with followers or nil.
     */
    func provideFollowersForUsers(_ users: [UserType]) -> Promise<[Follower]?> {

        let queries = users.map { FollowersQuery(followersOfUser: $0) } as [Query]
        return provideUsersWithQueries(queries, serializationKey: followerSerializationKey,
                authentizationRequired: false)
    }

    /**
     Provides a list who given user is following.

     - parameter user: User for who followees list should be provided.

     - returns: Promise which resolves with followees or nil.
     */
    func provideFolloweesForUser(_ user: UserType) -> Promise<[Followee]?> {
        return provideFolloweesForUsers([user])
    }

    /**
     Provides a list who given users are following.

     - parameter users: Users for whose followees list should be provided.

     - returns: Promise which resolves with followees or nil.
     */
    func provideFolloweesForUsers(_ users: [UserType]) -> Promise<[Followee]?> {

        let queries = users.map { FolloweesQuery(followeesOfUser: $0) } as [Query]
        return provideUsersWithQueries(queries, serializationKey: followeeSerializationKey,
                authentizationRequired: false)
    }

    /**
     Provides next page of followees / followers.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with shots or nil.
     */
    func nextPage() -> Promise<[UserType]?> {
        return fetchPage(nextPageFor(User.self))
    }

    /**
     Provides previous page of followees / followers.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with shots or nil.
     */
    func previousPage() -> Promise<[UserType]?> {
        return fetchPage(previousPageFor(User.self))
    }
}

private extension APIConnectionsProvider {

    func provideUsersWithQueries(_ queries: [Query], serializationKey key: String? = nil,
                                 authentizationRequired: Bool) -> Promise<[UserType]?> {
        return Promise<[UserType]?> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(authentizationRequired)
            }.then {
                self.firstPageForQueries(queries, withSerializationKey: key)
            }.then { (users: [User]?) -> Void in
                fulfill(users.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }

    func fetchPage(_ promise: Promise<[User]?>) -> Promise<[UserType]?> {
        return Promise<[UserType]?> { fulfill, reject in

            firstly {
                promise
            }.then { (users: [User]?) -> Void in
                fulfill(users.flatMap { $0.map { $0 as UserType } })
            }.catch(execute: reject)
        }
    }
}
