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
}
