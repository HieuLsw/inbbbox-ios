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
        return apiTeamsProvider.provideTeamsOfCurrentUser()
    }

    func nextPage() -> Promise<[TeamType]?> {
        return apiTeamsProvider.teamsNextPage()
    }

    func provideTeamFor(user: UserType) -> Promise<[TeamType]?> {
        return apiTeamsProvider.provideTeamsFor(user: user)
    }
}
