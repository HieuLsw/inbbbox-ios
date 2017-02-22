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

    func nextPage() -> Promise<[UserType]?> {
        return apiTeamsProvider.teamsNextPage()
    }

    func provideTeamFor(user: UserType) -> Promise<[UserType]?> {
        return apiTeamsProvider.provideTeamsFor(user: user)
    }
    
    func provideMembersForTeam(_ team: TeamType) -> Promise<[UserType]?> {
        return apiTeamsProvider.provideMembersForTeam(team)
    }
    
    func provideMembersForTeam(_ team: UserType) -> Promise<[UserType]?> {
        return apiTeamsProvider.provideMembersForTeam(team)
    }
}
