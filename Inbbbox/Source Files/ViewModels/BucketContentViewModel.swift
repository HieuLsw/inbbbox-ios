//
//  BucketContentViewModel.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 15.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit


class BucketContentViewModel: SimpleShotsViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    var shots = [ShotType]()
    fileprivate let shotsProvider = ShotsProvider()
    fileprivate var userMode: UserMode
    fileprivate var bucket: BucketType

    var itemsCount: Int {
        return shots.count
    }

    var title: String {
        return bucket.name
    }

    init(bucket: BucketType) {
        userMode = UserStorage.isUserSignedIn ? .loggedUser : .demoUser
        self.bucket = bucket
    }

    func downloadInitialItems() {
        firstly {
            shotsProvider.provideShotsForBucket(self.bucket)
        }.then { shots -> Void in
            if let shots = shots {
                firstly {
                    self.removeShotsFromBlockedUsers(shots)
                }.then { filteredShots -> Void in
                    if let filteredShots = filteredShots, filteredShots != self.shots || filteredShots.count == 0 {
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
            shotsProvider.nextPage()
        }.then { shots -> Void in
            if let shots = shots, shots.count > 0 {
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
            firstLocalizedString: Localized("BucketContent.EmptyData.FirstLocalizedString",
                comment: "BucketContentCollectionView, empty data set view"),
            attachmentImageName: ColorModeProvider.current().emptyBucketImageName,
            imageOffset: CGPoint(x: 0, y: -4),
            lastLocalizedString: Localized("BucketContent.EmptyData.LastLocalizedString",
                comment: "BucketContentCollectionView, empty data set view")
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
