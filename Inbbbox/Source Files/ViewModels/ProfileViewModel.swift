//
//  ProfileViewModel.swift
//  Inbbbox
//
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

    var backgroundImage: UIImage? {
        return UIImage(named: ColorModeProvider.current().profileHeaderViewBackgroundImageName)
    }

    var menu: [ProfileMenuItem] {
        return [
            .shots,
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
}

extension ProfileViewModel {

    /// Returns value that should be shown in menu item's badge.
    ///
    /// - Parameter item: Menu item to get badge's value for.
    /// - Returns: Badge's value.
    func badge(forMenuItem item: ProfileMenuItem) -> Int {
        switch item {
        case .shots: return Int(user.shotsCount)
        case .info: return 0
        case .projects: return Int(user.projectsCount)
        case .buckets: return Int(user.bucketsCount)
        }
    }

    /// Indicates if current profile is followed by logged in user.
    ///
    /// - Returns: Promise that resolves positively when profile is followed.
    func isProfileFollowedByMe() -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in

            firstly {
                connectionsRequester.isUserFollowedByMe(user)
            }.then { followed in
                fulfill(followed)
            }.catch(execute: reject)
        }
    }

    /// Requests to follow current profile.
    ///
    /// - Returns: Promise that resolves positively when requesting succeds.
    func followProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.followUser(user)
            }.then {
                self.vibrate(feedbackType: .success)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    /// Requests to unfollow current profile.
    ///
    /// - Returns: Promise that resolves positively when requesting succeds.
    func unfollowProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.unfollowUser(user)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }
}
