//
//  BucketsViewModel.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 24.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit


class BucketsViewModel: BaseCollectionViewViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    let title = Localized("CenterButtonTabBar.Buckets", comment:"Main view, bottom bar & view title")
    var buckets = [BucketType]()
    var bucketsIndexedShots = [Int: [ShotType]]()
    fileprivate let bucketsProvider = BucketsProvider()
    fileprivate let bucketsRequester = BucketsRequester()
    fileprivate let shotsProvider = ShotsProvider()
    fileprivate var userMode: UserMode

    var itemsCount: Int {
        return buckets.count
    }

    init() {
        userMode = UserStorage.isUserSignedIn ? .loggedUser : .demoUser
    }

    func downloadInitialItems() {
        firstly {
            bucketsProvider.provideMyBuckets()
        }.then {
            buckets -> Void in
            var bucketsShouldBeReloaded = true
            if let buckets = buckets {
                if buckets == self.buckets && buckets.count != 0 {
                    bucketsShouldBeReloaded = false
                }
                self.buckets = buckets
                self.downloadShots(buckets)
            }
            if bucketsShouldBeReloaded {
                self.delegate?.viewModelDidLoadInitialItems()
            }
        }.catch {
            error in
            self.delegate?.viewModelDidFailToLoadInitialItems(error)
        }
    }

    func downloadItemsForNextPage() {
        guard UserStorage.isUserSignedIn else {
            return
        }
        firstly {
            bucketsProvider.nextPage()
        }.then {
            buckets -> Void in
            if let buckets = buckets, buckets.count > 0 {
                let indexes = buckets.enumerated().map {
                    index, _ in
                    return index + self.buckets.count
                }
                self.buckets.append(contentsOf: buckets)
                let indexPaths = indexes.map {
                    IndexPath(row: ($0), section: 0)
                }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }
    }

    func downloadItem(at index: Int) { /* empty */ }

    func downloadShots(_ buckets: [BucketType]) {
        for bucket in buckets {
            firstly {
                shotsProvider.provideShotsForBucket(bucket)
            }.then {
                shots -> Void in
                var bucketShotsShouldBeReloaded = true
                var indexOfBucket: Int?
                for (index, item) in self.buckets.enumerated() {
                    if item.identifier == bucket.identifier {
                        indexOfBucket = index
                        break
                    }
                }
                guard let index = indexOfBucket else {
                    return
                }
                if let unwrappedShots = shots {
                    firstly {
                        self.removeShotsFromBlockedUsers(unwrappedShots)
                    }.then { filteredShots -> Void in
                        if let oldShots = self.bucketsIndexedShots[index],
                            let newShots = filteredShots {
                            bucketShotsShouldBeReloaded = oldShots != newShots
                        }

                        if let shots = filteredShots {
                            self.bucketsIndexedShots[index] = shots
                        } else {
                            self.bucketsIndexedShots[index] = [ShotType]()
                        }

                        if bucketShotsShouldBeReloaded {
                            let indexPath = IndexPath(row: index, section: 0)
                            self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
                        }
                    }.catch { _ in }
                }
            }.catch { error in
                self.notifyDelegateAboutFailure(error)
            }
        }
    }

    func createBucket(_ name: String, description: NSAttributedString? = nil) -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in
            firstly {
                bucketsRequester.postBucket(name, description: description)
            }.then {
                bucket in
                self.buckets.append(bucket)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func bucketCollectionViewCellViewData(_ indexPath: IndexPath) -> BucketCollectionViewCellViewData {
        return BucketCollectionViewCellViewData(bucket: buckets[indexPath.row],
                shots: bucketsIndexedShots[indexPath.row])
    }

    func clearViewModelIfNeeded() {
        let currentUserMode = UserStorage.isUserSignedIn ? UserMode.loggedUser : .demoUser
        if userMode != currentUserMode {
            buckets = []
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

extension BucketsViewModel {

    struct BucketCollectionViewCellViewData {
        let name: String
        let numberOfShots: String
        let shotsImagesURLs: [URL]?

        init(bucket: BucketType, shots: [ShotType]?) {
            name = bucket.name
            if let shots = shots, shots.count > 0 {
                numberOfShots = String.localizedStringWithFormat(Localized("%d shots", comment: "How many shots in collection?"), shots.count)
                let allShotsImagesURLs = shots.map {
                    $0.shotImage.teaserURL
                }

                if allShotsImagesURLs.count >= 4 {
                    shotsImagesURLs = Array(allShotsImagesURLs.prefix(4))
                } else {
                    let repeatedValues = Array(repeating: allShotsImagesURLs, count: 4).flatMap{$0}
                    shotsImagesURLs = Array(repeatedValues.prefix(4))
                }
            } else {
                shotsImagesURLs = nil
                numberOfShots = String.localizedStringWithFormat(Localized("%d shots", comment: "How many shots in collection?"), 0)
            }
        }
    }

}
