//
//  TeamsProvider.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PromiseKit

class TeamsProvider {

    let apiTeamsProvider = APITeamsProvider()

    func provideMyTeams() -> Promise<[TeamType]?> {
        assert(UserStorage.isUserSignedIn, "Cannot provide teams when user is not signed in")
        return apiTeamsProvider.provideTeamsOfCurrentUser()
    }

    func nextPage() -> Promise<[TeamType]?> {
        assert(UserStorage.isUserSignedIn, "Cannot provide teams for next page when user is not signed in")
        return apiTeamsProvider.teamsNextPage()
    }
}
