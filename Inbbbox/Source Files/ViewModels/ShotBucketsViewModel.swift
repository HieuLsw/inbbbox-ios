//
//  ShotBucketsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

class ShotBucketsViewModel {

    var itemsCount: Int {

        var counter = Int(0)

        counter += buckets.count
        counter += 2  // for action buttons and gap before

        return counter
    }

    var attributedShotTitleForHeader: NSAttributedString {
        return ShotDetailsFormatter.attributedStringForHeaderWithLinkRangeFromShot(shot).attributedString
    }

    var userLinkRange: NSRange {
        return ShotDetailsFormatter.attributedStringForHeaderWithLinkRangeFromShot(shot).userLinkRange ??
            NSRange(location: 0, length: 0)
    }

    var teamLinkRange: NSRange {
        return ShotDetailsFormatter.attributedStringForHeaderWithLinkRangeFromShot(shot).teamLinkRange ??
            NSRange(location: 0, length: 0)
    }

    var titleForHeader: String {
        switch shotBucketsViewControllerMode {
        case .AddToBucket:
            return NSLocalizedString("ShotBucketsViewModel.AddToBucket",
                    comment: "Allows user to add shot to bucket")
        case .RemoveFromBucket:
            return NSLocalizedString("ShotBucketsViewModel.RemoveFromBucket",
                    comment: "Allows user to remove shot from bucket")
        }
    }

    var titleForActionItem: String {
        switch shotBucketsViewControllerMode {
        case .AddToBucket:
            return NSLocalizedString("ShotBucketsViewModel.NewBucket",
                    comment: "Allows user to create new bucket")
        case .RemoveFromBucket:
            return NSLocalizedString("ShotBucketsViewModel.RemoveFromSelectedBuckets",
                    comment: "Allows user to remove from multiple backets")
        }
    }

    let shot: ShotType
    let shotBucketsViewControllerMode: ShotBucketsViewControllerMode

    var userProvider = APIUsersProvider()
    var bucketsProvider = BucketsProvider()
    var bucketsRequester = BucketsRequester()
    var shotsRequester = APIShotsRequester()

    private(set) var buckets = [BucketType]()
    private(set) var selectedBucketsIndexes = [Int]()

    init(shot: ShotType, mode: ShotBucketsViewControllerMode) {
        self.shot = shot
        shotBucketsViewControllerMode = mode
    }

    func loadBuckets() -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in

            switch shotBucketsViewControllerMode {

            case .AddToBucket:
                firstly {
                    bucketsProvider.provideMyBuckets()
                }.then {
                    buckets in
                    self.buckets = buckets ?? []
                }.then(fulfill).error(reject)

            case .RemoveFromBucket:
                firstly {
                    shotsRequester.userBucketsForShot(shot)
                }.then {
                    buckets in
                    self.buckets = buckets ?? []
                }.then(fulfill).error(reject)
            }
        }
    }

    func createBucket(name: String, description: NSAttributedString? = nil) -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in
            firstly {
                bucketsRequester.postBucket(name, description: description)
            }.then {
                bucket in
                self.buckets.append(bucket)
            }.then(fulfill).error(reject)
        }
    }

    func addShotToBucketAtIndex(index: Int) -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in

            firstly {
                bucketsRequester.addShot(shot, toBucket: buckets[index])
            }.then(fulfill).error(reject)
        }
    }

    func removeShotFromSelectedBuckets() -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in

            var bucketsToRemoveShot = [BucketType]()
            selectedBucketsIndexes.forEach {
                bucketsToRemoveShot.append(buckets[$0])
            }

            when(bucketsToRemoveShot.map {
                bucketsRequester.removeShot(shot, fromBucket: $0)
            }).then(fulfill).error(reject)
        }
    }

    func selectBucketAtIndex(index: Int) -> Bool {
        toggleBucketSelectionAtIndex(index)
        return selectedBucketsIndexes.contains(index)
    }

    func bucketShouldBeSelectedAtIndex(index: Int) -> Bool {
        return selectedBucketsIndexes.contains(index)
    }

    func showBottomSeparatorForBucketAtIndex(index: Int) -> Bool {
        return index != buckets.count - 1
    }

    func isSeparatorAtIndex(index: Int) -> Bool {
        return index == itemsCount - 2
    }

    func isActionItemAtIndex(index: Int) -> Bool {
        return index == itemsCount - 1
    }

    func indexForRemoveFromSelectedBucketsActionItem() -> Int {
        return itemsCount - 1
    }

    func displayableDataForBucketAtIndex(index: Int) -> (bucketName: String, shotsCountText: String) {
        let bucket = buckets[index]
        return (
        bucketName: bucket.name,
                shotsCountText: bucket.shotsCount == 1 ? "\(bucket.shotsCount) shot" : "\(bucket.shotsCount) shots"
        )
    }
}

// MARK: URL - User handling

extension ShotBucketsViewModel: URLToUserProvider, UserToURLProvider {

    func userForURL(url: NSURL) -> UserType? {
        return shot.user.identifier == url.absoluteString ? shot.user : nil
    }

    func userForId(identifier: String) -> Promise<UserType> {
        return userProvider.provideUser(identifier)
    }
}

private extension ShotBucketsViewModel {

    func toggleBucketSelectionAtIndex(index: Int) {
        if let elementIndex = selectedBucketsIndexes.indexOf(index) {
            selectedBucketsIndexes.removeAtIndex(elementIndex)
        } else {
            selectedBucketsIndexes.append(index)
        }
    }
}
