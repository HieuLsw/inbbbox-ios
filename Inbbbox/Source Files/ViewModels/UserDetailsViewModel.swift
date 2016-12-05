//
//  UserDetailsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 14/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class UserDetailsViewModel: ProfileViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?

    var title: String {
        return user.name ?? user.username
    }

    var avatarURL: NSURL? {
        return user.avatarURL
    }

    var collectionIsEmpty: Bool {
        return userShots.isEmpty
    }

    var shouldShowFollowButton: Bool {
        if let currentUser = UserStorage.currentUser where currentUser.identifier != user.identifier {
            return true
        }
        return false
    }

    var itemsCount: Int {
        return userShots.count
    }

    var userShots = [ShotType]()
    var connectionsRequester = APIConnectionsRequester()

    private(set) var user: UserType
    private let shotsProvider = ShotsProvider()

    init(user: UserType) {
        self.user = user
    }

    // MARK: Shots section

    func downloadInitialItems() {
        firstly {
            shotsProvider.provideShotsForUser(user)
        }.then { shots -> Void in
            if let shots = shots where shots != self.userShots {
                self.userShots = shots
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.error { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        firstly {
            shotsProvider.nextPage()
        }.then { shots -> Void in
            if let shots = shots where shots.count > 0 {
                let indexes = shots.enumerate().map { index, _ in
                    return index + self.userShots.count
                }
                self.userShots.appendContentsOf(shots)
                let indexPaths = indexes.map {
                    NSIndexPath(forRow:($0), inSection: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.error { error in
            self.notifyDelegateAboutFailure(error)
        }
    }

    // MARK: Users section

    func isProfileFollowedByMe() -> Promise<Bool> {

        return Promise<Bool> { fulfill, reject in

            firstly {
                connectionsRequester.isUserFollowedByMe(user)
            }.then { followed in
                fulfill(followed)
            }.error(reject)
        }
    }

    func followProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.followUser(user)
            }.then(fulfill).error(reject)
        }
    }

    func unfollowProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.unfollowUser(user)
            }.then(fulfill).error(reject)
        }
    }

    // MARK: Cell data section

    func shotCollectionViewCellViewData(indexPath: NSIndexPath) -> (shotImage: ShotImageType, animated: Bool) {
        let shotImage = userShots[indexPath.row].shotImage
        let animated = userShots[indexPath.row].animated
        return (shotImage, animated)
    }
}

// MARK: Helpers

extension UserDetailsViewModel {

    func shotWithSwappedUser(shot: ShotType) -> ShotType {
        return Shot(
            identifier: shot.identifier,
            title: shot.title,
            attributedDescription: shot.attributedDescription,
            user: user,
            shotImage: shot.shotImage,
            createdAt: shot.createdAt,
            animated: shot.animated,
            likesCount: shot.likesCount,
            viewsCount: shot.viewsCount,
            commentsCount: shot.commentsCount,
            bucketsCount: shot.bucketsCount,
            team: shot.team,
            attachmentsCount: shot.attachmentsCount
        )
    }
}
