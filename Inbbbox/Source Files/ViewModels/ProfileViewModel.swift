//
//  ProfileViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/01/2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

final class ProfileViewModel: Vibratable {

    var title: String {
        return user.name ?? user.username
    }

    var avatarURL: URL? {
        return user.avatarURL as URL?
    }

    var shouldShowFollowButton: Bool {
        if let currentUser = UserStorage.currentUser, currentUser.identifier != user.identifier {
            return true
        }
        return false
    }

    var menu: [ProfileMenuItem] {
        return [
            user.accountType == .Team ? .team : .shots,
            .info,
            .projects,
            .buckets
        ]
    }

    var connectionsRequester = APIConnectionsRequester()
    fileprivate(set) var user: UserType

    init(user: UserType) {
        self.user = user
    }

    func badge(forMenuItem item: ProfileMenuItem) -> Int {
        switch item {
        case .shots: return Int(user.shotsCount)
        case .team: return 0
        case .info: return 0
        case .projects: return Int(user.projectsCount)
        case .buckets: return Int(user.bucketsCount)
        }
    }

    func isProfileFollowedByMe() -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in

            firstly {
                connectionsRequester.isUserFollowedByMe(user)
                }.then { followed in
                    fulfill(followed)
                }.catch(execute: reject)
        }
    }

    func followProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.followUser(user)
                }.then {
                    self.vibrate(feedbackType: .success)
                }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func unfollowProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.unfollowUser(user)
                }.then(execute: fulfill).catch(execute: reject)
        }
    }
}
