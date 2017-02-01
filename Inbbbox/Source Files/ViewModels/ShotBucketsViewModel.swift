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
        if didDownloadBuckets {
            counter += 2  // for action buttons and gap before
        }

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
        case .addToBucket:
            return Localized("ShotBucketsViewModel.AddToBucket",
                    comment: "Allows user to add shot to bucket")
        case .removeFromBucket:
            return Localized("ShotBucketsViewModel.RemoveFromBucket",
                    comment: "Allows user to remove shot from bucket")
        }
    }

    var titleForActionItem: String {
        switch shotBucketsViewControllerMode {
        case .addToBucket:
            return Localized("ShotBucketsViewModel.NewBucket",
                    comment: "Allows user to create new bucket")
        case .removeFromBucket:
            return Localized("ShotBucketsViewModel.RemoveFromSelectedBuckets",
                    comment: "Allows user to remove from multiple backets")
        }
    }

    let shot: ShotType
    let shotBucketsViewControllerMode: ShotBucketsViewControllerMode

    var userProvider = APIUsersProvider()
    var bucketsProvider = BucketsProvider()
    var bucketsRequester = BucketsRequester()
    var shotsRequester = APIShotsRequester()

    fileprivate(set) var buckets = [BucketType]()
    fileprivate(set) var selectedBucketsIndexes = [Int]()
    fileprivate var didDownloadBuckets = false

    init(shot: ShotType, mode: ShotBucketsViewControllerMode) {
        self.shot = shot
        shotBucketsViewControllerMode = mode
    }

    func loadBuckets() -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in

            switch shotBucketsViewControllerMode {

            case .addToBucket:
                firstly {
                    bucketsProvider.provideMyBuckets()
                }.then { buckets in
                    self.buckets = buckets ?? []
                }.then {
                    self.didDownloadBuckets = true
                }.then(execute: fulfill).catch(execute: reject)

            case .removeFromBucket:
                firstly {
                    shotsRequester.userBucketsForShot(shot)
                }.then {
                    buckets in
                    self.buckets = buckets ?? []
                }.then { _ in
                    self.didDownloadBuckets = true
                }.then(execute: fulfill).catch(execute: reject)
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

    func addShotToBucketAtIndex(_ index: Int) -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in

            firstly {
                bucketsRequester.addShot(shot, toBucket: buckets[index])
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func removeShotFromSelectedBuckets() -> Promise<Void> {
        return Promise<Void> {
            fulfill, reject in

            var bucketsToRemoveShot = [BucketType]()
            selectedBucketsIndexes.forEach {
                bucketsToRemoveShot.append(buckets[$0])
            }

            when(fulfilled: bucketsToRemoveShot.map {
                bucketsRequester.removeShot(shot, fromBucket: $0)
            }).then(execute: fulfill).catch(execute: reject)
        }
    }

    func selectBucketAtIndex(_ index: Int) -> Bool {
        toggleBucketSelectionAtIndex(index)
        return selectedBucketsIndexes.contains(index)
    }

    func bucketShouldBeSelectedAtIndex(_ index: Int) -> Bool {
        return selectedBucketsIndexes.contains(index)
    }

    func showBottomSeparatorForBucketAtIndex(_ index: Int) -> Bool {
        return index != buckets.count - 1
    }

    func isSeparatorAtIndex(_ index: Int) -> Bool {
        return index == itemsCount - 2
    }

    func isActionItemAtIndex(_ index: Int) -> Bool {
        return index == itemsCount - 1
    }

    func indexForRemoveFromSelectedBucketsActionItem() -> Int {
        return itemsCount - 1
    }

    func displayableDataForBucketAtIndex(_ index: Int) -> (bucketName: String, shotsCountText: String) {
        let bucket = buckets[index]
        let localizedString = Localized("%d shots", comment: "How many shots in collection?")
        let shotsCountText = String.localizedStringWithFormat(localizedString, bucket.shotsCount)

        return (bucketName: bucket.name, shotsCountText: shotsCountText)
    }
}

// MARK: URL - User handling

extension ShotBucketsViewModel: URLToUserProvider, UserToURLProvider {

    func userForURL(_ url: URL) -> UserType? {
        return shot.user.identifier == url.absoluteString ? shot.user : nil
    }

    func userForId(_ identifier: String) -> Promise<UserType> {
        return userProvider.provideUser(identifier)
    }
}

private extension ShotBucketsViewModel {

    func toggleBucketSelectionAtIndex(_ index: Int) {
        if let elementIndex = selectedBucketsIndexes.index(of: index) {
            selectedBucketsIndexes.remove(at: elementIndex)
        } else {
            selectedBucketsIndexes.append(index)
        }
    }
}
