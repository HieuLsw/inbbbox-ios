//
//  ProfileBucketsViewModel.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class ProfileBucketsViewModel: ProfileProjectsOrBucketsViewModel {

    weak var delegate: BaseCollectionViewViewModelDelegate?
    var buckets = [BucketType]()
    var bucketsIndexedShots = [Int: [ShotType]]()

    fileprivate let bucketsProvider = BucketsProvider()
    fileprivate let bucketsRequester = BucketsRequester()
    fileprivate let shotsProvider = ShotsProvider()
    fileprivate var user: UserType

    var itemsCount: Int {
        return buckets.count
    }

    init(user: UserType) {
        self.user = user
    }

    func downloadInitialItems() {
        firstly {
            bucketsProvider.provideBuckets(forUser: user)
        }.then { buckets -> Void in
            var bucketsShouldBeReloaded = true
            if let buckets = buckets {
                if buckets == self.buckets && buckets.count != 0 {
                    bucketsShouldBeReloaded = false
                }
                self.buckets = buckets
                self.downloadShots(forBuckets: buckets)
            }
            if bucketsShouldBeReloaded {
                self.delegate?.viewModelDidLoadInitialItems()
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
            bucketsProvider.nextPage()
        }.then { buckets -> Void in
            if let buckets = buckets, buckets.count > 0 {
                let indexes = buckets.enumerated().map { index, _ in
                    return index + self.buckets.count
                }
                self.buckets.append(contentsOf: buckets)
                let indexPaths = indexes.map { IndexPath(row: ($0), section: 0) }
                self.delegate?.viewModel(self, didLoadItemsAtIndexPaths: indexPaths)
            }
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }
    }

    func downloadItem(at index: Int) { /* empty */ }

    func downloadShots(forBuckets buckets: [BucketType]) {
        for bucket in buckets {
            firstly {
                shotsProvider.provideShotsForBucket(bucket)
            }.then { shots -> Void in
                var bucketShotsShouldBeReloaded = true
                guard let index = self.buckets.index(where: { $0.identifier == bucket.identifier }) else { return }
                firstly {
                    self.removeShotsFromBlockedUsers(shots)
                }.then { filteredShots -> Void in
                    if let oldShots = self.bucketsIndexedShots[index], let newShots = filteredShots {
                        bucketShotsShouldBeReloaded = oldShots != newShots
                    }
                    self.bucketsIndexedShots[index] = filteredShots ?? [ShotType]()
                    if bucketShotsShouldBeReloaded {
                        let indexPath = IndexPath(row: index, section: 0)
                        self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
                    }
                }.catch { error in
                    self.notifyDelegateAboutFailure(error)
                }
            }.catch { error in
                self.notifyDelegateAboutFailure(error)
            }
        }
    }

    func bucketTableViewCellViewData(_ indexPath: IndexPath) -> ProfileBucketTableViewCellViewData {
        return ProfileBucketTableViewCellViewData(bucket: buckets[indexPath.row], shots: bucketsIndexedShots[indexPath.row])
    }

    func clearViewModelIfNeeded() {
        buckets = []
        delegate?.viewModelDidLoadInitialItems()
    }

    func removeShotsFromBlockedUsers(_ shots: [ShotType]?) -> Promise<[ShotType]?> {
        return Promise<[ShotType]?> { fulfill, reject in

            guard let shots = shots else {
                fulfill(nil)
                return
            }

            firstly {
                UsersProvider().provideBlockedUsers()
            }.then { users -> Void in
                if let blockedUsers = users {
                    let filteredShots = shots.filter({ (shot) -> Bool in
                        let authors = blockedUsers.filter { $0.identifier == shot.user.identifier }
                        return authors.count == 0
                    })
                    fulfill(filteredShots)
                } else {
                    fulfill(shots)
                }
            }.catch(execute: reject)
        }
    }
}

extension ProfileBucketsViewModel {

    struct ProfileBucketTableViewCellViewData {
        let name: String
        let numberOfShots: String
        let shots: [ShotType]?

        init(bucket: BucketType, shots: [ShotType]?) {
            self.name = bucket.name
            if let shots = shots {
                self.numberOfShots = String(format: "%d", shots.count)
                self.shots = shots
            } else {
                self.numberOfShots = "0"
                self.shots = nil
            }
        }
    }
}
