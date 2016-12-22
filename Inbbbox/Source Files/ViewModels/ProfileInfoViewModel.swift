//
//  ProfileInfoViewModel.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PromiseKit

final class ProfileInfoViewModel: BaseCollectionViewViewModel {

    private let userProvider = APIUsersProvider()
    private let teamsProvider = TeamsProvider()
    private var user: UserType
    private var teams = [TeamType]()

    weak var delegate: BaseCollectionViewViewModelDelegate?

    var itemsCount: Int {
        return teams.count
    }

    var shotsCount: String {
        return String(user.shotsCount)
    }

    var followersCount: String {
        return String(user.followersCount)
    }

    var followingsCount: String {
        return String(user.followingsCount)
    }

    var location: String {
        return user.location
    }

    var bio: String {
        return user.bio
    }

    var shouldHideLocation: Bool {
        return user.location.characters.count == 0
    }

    var shouldHideTeams: Bool {
        return itemsCount == 0
    }

    var isTeamsEmpty: Bool {
        return teams.isEmpty
    }

    init(user: UserType) {
        self.user = user
    }

    func refreshUserData() {
        firstly {
            userProvider.provideUser(user.identifier)
        }.then { user in
            self.user = user
        }.then { _ in
            self.delegate?.viewModelDidLoadInitialItems()
        }.catch { _ in }
    }

    func downloadInitialItems() {
        firstly {
            teamsProvider.provideMyTeams()
        }.then { teams -> Void in
            if let teams = teams {
                self.teams = teams
            }
            self.delegate?.viewModelDidLoadInitialItems()
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        // no-op
    }

    func team(forIndex index: Int) -> TeamType {
        return teams[index]
    }

}
