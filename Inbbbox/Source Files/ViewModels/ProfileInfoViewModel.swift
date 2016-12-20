//
//  ProfileInfoViewModel.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

class ProfileInfoViewModel {

    private let user: UserType

    var shotsAmount: String {
        return String(user.shotsCount)
    }

    init(user: UserType) {
        self.user = user
    }

}
