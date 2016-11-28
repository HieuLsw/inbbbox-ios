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
    let title = NSLocalizedString("CenterButtonTabBar.Buckets", comment:"Main view, bottom bar & view title")
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
                self.downloadShots(buckets)
            }
        }.catch { error in
            self.notifyDelegateAboutFailure(error)
        }
    }

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

                if let oldShots = self.bucketsIndexedShots[index], let newShots = shots {
                    bucketShotsShouldBeReloaded = oldShots != newShots
                }

                if let shots = shots {
                    self.bucketsIndexedShots[index] = shots
                } else {
                    self.bucketsIndexedShots[index] = [ShotType]()
                }

                if bucketShotsShouldBeReloaded {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.delegate?.viewModel(self, didLoadShotsForItemAtIndexPath: indexPath)
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
}

extension BucketsViewModel {

    struct BucketCollectionViewCellViewData {
        let name: String
        let numberOfShots: String
        let shotsImagesURLs: [URL]?

        init(bucket: BucketType, shots: [ShotType]?) {
            self.name = bucket.name
            self.numberOfShots = String.localizedStringWithFormat(NSLocalizedString("%d shots",
                    comment: "How many shots in collection?"), bucket.shotsCount)
            if let shots = shots, shots.count > 0 {
                let allShotsImagesURLs = shots.map {
                    $0.shotImage.teaserURL
                }
                self.shotsImagesURLs = Array(Array(Array(repeating: allShotsImagesURLs,
                        count: 4).joined())[0 ... 3]) as [URL]?
            } else {
                self.shotsImagesURLs = nil
            }
        }
    }

}
