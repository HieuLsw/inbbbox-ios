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

    func provideTeams(forUser user: UserType) -> Promise<[UserType]?> {
        return apiTeamsProvider.provideTeams(forUser: user)
    }
    
    func provideMembers(forTeam team: TeamType) -> Promise<[UserType]?> {
        return apiTeamsProvider.provideMembers(forTeam: team)
    }
    
    func provideMembers(forTeam team: UserType) -> Promise<[UserType]?> {
        return apiTeamsProvider.provideMembers(forTeam: team)
    }
}
