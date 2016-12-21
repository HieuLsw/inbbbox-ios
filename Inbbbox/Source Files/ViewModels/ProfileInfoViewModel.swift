//
//  ProfileInfoViewModel.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

final class ProfileInfoViewModel {

    private let user: UserType

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

    init(user: UserType) {
        self.user = user
    }

}
