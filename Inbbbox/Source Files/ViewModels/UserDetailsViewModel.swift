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

    var avatarURL: URL? {
        return user.avatarURL as URL?
    }

    var collectionIsEmpty: Bool {
        return userShots.isEmpty
    }

    var shouldShowFollowButton: Bool {
        if let currentUser = UserStorage.currentUser, currentUser.identifier != user.identifier {
            return true
        }
        return false
    }

    var itemsCount: Int {
        return userShots.count
    }

    var userShots = [ShotType]()
    var connectionsRequester = APIConnectionsRequester()

    fileprivate(set) var user: UserType
    fileprivate let shotsProvider = ShotsProvider()

    init(user: UserType) {
        self.user = user
    }

    // MARK: Shots section

    func downloadInitialItems() {
        firstly {
            shotsProvider.provideShotsForUser(user)
        }.then { shots -> Void in
            if let shots = shots, shots != self.userShots {
                self.userShots = shots
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        firstly {
            shotsProvider.nextPage()
        }.then { shots -> Void in
            if let shots = shots, shots.count > 0 {
                let indexes = shots.enumerated().map { index, _ in
                    return index + self.userShots.count
                }
                self.userShots.append(contentsOf: shots)
                let indexPaths = indexes.map {
                    IndexPath(row:($0), section: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.catch { error in
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
            }.catch(execute: reject)
        }
    }

    func followProfile() -> Promise<Void> {

        return Promise<Void> { fulfill, reject in

            firstly {
                connectionsRequester.followUser(user)
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

    // MARK: Cell data section

    func shotCollectionViewCellViewData(_ indexPath: IndexPath) -> (shotImage: ShotImageType, animated: Bool) {
        let shotImage = userShots[indexPath.row].shotImage
        let animated = userShots[indexPath.row].animated
        return (shotImage, animated)
    }
}

// MARK: Helpers

extension UserDetailsViewModel {

    func shotWithSwappedUser(_ shot: ShotType) -> ShotType {
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
            attachmentsCount: shot.attachmentsCount,
            htmlUrl: shot.htmlUrl
        )
    }
}
