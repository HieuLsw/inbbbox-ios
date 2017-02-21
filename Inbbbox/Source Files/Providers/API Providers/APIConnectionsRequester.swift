//
//  APIConnectionsRequester.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

/// Provides interface for dribbble followers and followees update, delete, create API
class APIConnectionsRequester: Verifiable {

    /// Adds authenticated user to given user followers.
    ///
    /// - Requires: Authenticated user.
    /// - Note:     Following errors may occur:
    ///     - You cannot follow yourself.
    ///     - You have been blocked from following this member at their request.
    ///     - You have reached the maximum number of follows allowed.
    ///
    /// - parameter user: User to follow.
    ///
    /// - returns: Promise which resolves with void.
    func followUser(_ user: UserType) -> Promise<Void> {
        AnalyticsManager.trackUserActionEvent(.follow)

        let query = FollowUserQuery(user: user)
        return sendConnectionQuery(query)
    }


    /// Adds authenticated user to given team followers.
    ///
    /// - Requires: Authenticated user.
    /// - Note:     Following errors may occur:
    ///     - You cannot follow yourself.
    ///     - You have been blocked from following this member at their request.
    ///     - You have reached the maximum number of follows allowed.
    ///
    /// - parameter team: Team to follow.
    ///
    /// - returns: Promise which resolves with void.
    func followTeam(_ team: TeamType) -> Promise<Void> {

        let query = FollowUserQuery(team: team)
        return sendConnectionQuery(query)
    }


    /// Removes authenticated user to given user followers.
    ///
    /// - Requires: Authenticated user.
    /// - Warning:  Authenticated user has to follow given user first.
    ///
    /// - parameter user: User to unfollow.
    ///
    /// - returns: Promise which resolves with void.
    func unfollowUser(_ user: UserType) -> Promise<Void> {

        let query = UnfollowUserQuery(user: user)
        return sendConnectionQuery(query)
    }

    /// Removes authenticated user to given team followers.
    ///
    /// - Requires: Authenticated user.
    /// - Warning:  Authenticated user has to follow given team first.
    ///
    /// - parameter team: Team to unfollow.
    ///
    /// - returns: Promise which resolves with void.
    func unfollowTeam(_ team: TeamType) -> Promise<Void> {

        let query = UnfollowUserQuery(team: team)
        return sendConnectionQuery(query)
    }

    /// Checks whether user is followed by authenticated user or not.
    ///
    /// - Requires: Authenticated user.
    ///
    /// - parameter user: User to check.
    ///
    /// - returns: Promise which resolves with true (if current user follows given user) or false (if doesn't).
    func isUserFollowedByMe(_ user: UserType) -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in

            let query = UserFollowedByMeQuery(user: user)

            firstly {
                sendConnectionQuery(query)
            }.then { _ in
                fulfill(true)
            }.catch { error in
                // According to API documentation, when response.code is 404,
                // then user is not followed by authenticated user.
                (error as NSError).code == 404 ? fulfill(false) : reject(error)
            }
        }
    }

    /// Checks whether team is followed by authenticated user or not.
    ///
    /// - Requires: Authenticated user.
    ///
    /// - parameter team: Team to check.
    ///
    /// - returns: Promise which resolves with true (if current user follows given team) or false (if doesn't).
    func isTeamFollowedByMe(_ team: TeamType) -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in

            let query = UserFollowedByMeQuery(team: team)

            firstly {
                sendConnectionQuery(query)
            }.then { _ in
                fulfill(true)
            }.catch { error in
                // According to API documentation, when response.code is 404,
                // then team is not followed by authenticated user.
                (error as NSError).code == 404 ? fulfill(false) : reject(error)
            }
        }
    }
}

private extension APIConnectionsRequester {

    func sendConnectionQuery(_ query: Query) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                Request(query: query).resume()
            }.then { _ -> Void in
                fulfill()
            }.catch(execute: reject)
        }
    }
}
