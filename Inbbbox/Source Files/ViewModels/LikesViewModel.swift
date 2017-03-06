//
//  LikesViewModel.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 29.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit


class LikesViewModel: SimpleShotsViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    let title = Localized("LikesViewModel.Title", comment:"Title of Likes screen")
    var shots = [ShotType]()
    fileprivate let shotsProvider = ShotsProvider()
    fileprivate var userMode: UserMode

    var itemsCount: Int {
        return shots.count
    }

    init() {
        userMode = UserStorage.isUserSignedIn ? .loggedUser : .demoUser
    }

    func downloadInitialItems() {
        firstly {
            shotsProvider.provideMyLikedShots()
        }.then { shots -> Void in
            if let shots = shots?.map({ $0.shot }) {

                firstly {
                    self.removeShotsFromBlockedUsers(shots)
                }.then { filteredShots -> Void in
                    if let filteredShots = filteredShots,
                        filteredShots != self.shots || filteredShots.count == 0 {
                        self.shots = filteredShots
                    }
                }.then {
                    self.delegate?.viewModelDidLoadInitialItems()
                }.catch { _ in }
            }
        }.catch { error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        guard UserStorage.isUserSignedIn else {
            return
        }
        firstly {
            shotsProvider.nextPageForLikedShots()
        }.then { shots -> Void in
            if let shots = shots?.map({ $0.shot }), shots.count > 0 {
                let indexes = shots.enumerated().map { index, _ in
                    return index + self.shots.count
                }
                self.shots.append(contentsOf: shots)
                let indexPaths = indexes.map {
                    IndexPath(row:($0), section: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }
    }
    
    func downloadItem(at index: Int) { /* empty */ }
    
    func emptyCollectionDescriptionAttributes() -> EmptyCollectionViewDescription {
        let description = EmptyCollectionViewDescription(
            firstLocalizedString: Localized("LikesCollectionView.EmptyData.FirstLocalizedString",
                comment: "LikesCollectionView, empty data set view"),
            attachmentImageName: "ic-like-emptystate",
            imageOffset: CGPoint(x: 0, y: -2),
            lastLocalizedString: Localized("LikesCollectionView.EmptyData.LastLocalizedString",
                comment: "LikesCollectionView, empty data set view")
        )
        return description
    }

    func shotCollectionViewCellViewData(_ indexPath: IndexPath) -> (shotImage: ShotImageType, animated: Bool) {
        let shotImage = shots[indexPath.row].shotImage
        let animated = shots[indexPath.row].animated
        return (shotImage, animated)
    }

    func clearViewModelIfNeeded() {
        let currentUserMode = UserStorage.isUserSignedIn ? UserMode.loggedUser : .demoUser
        if userMode != currentUserMode {
            shots = []
            userMode = currentUserMode
            delegate?.viewModelDidLoadInitialItems()
        }
    }

    func removeShotsFromBlockedUsers(_ shots: [ShotType]) -> Promise<[ShotType]?> {
        return Promise<[ShotType]?> { fulfill, reject in

            firstly {
                UsersProvider().provideBlockedUsers()
            }.then { users -> Void in
                if let blockedUsers = users {
                    let filteredShots = shots.filter({ (shot) -> Bool in
                        let authors = blockedUsers.filter { $0.identifier == shot.user.identifier }
                        return authors.count == 0
                    })
                    fulfill(filteredShots)
                }
            }.catch(execute: reject)
        }
    }
}
