//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol ShotsAnimatorDelegate: class {
    func collectionViewForShotsAnimator(animator: ShotsAnimator) -> UICollectionView?

    func itemsForShotsAnimator(animator: ShotsAnimator) -> [ShotType]
}

class ShotsAnimator {

    weak var delegate: ShotsAnimatorDelegate?
    var visibleItems = [ShotType]()
    var asyncWrapper = AsyncWrapper()

//    Interface

    func startAnimationWithCompletion(completion: (() -> Void)?) {
        guard let collectionView = delegate?.collectionViewForShotsAnimator(self),
                items = delegate?.itemsForShotsAnimator(self) where items.count != 0 else {
            completion?()
            return
        }

        let interval = 0.1
        addItems(items, collectionView: collectionView, interval: interval) {
            self.asyncWrapper.main(after: 1.0) {
                self.deleteItemsWithoutFirstItem(items,
                                 collectionView: collectionView,
                                       interval: interval,
                                     completion: completion)
            }
        }
    }

//    MARK: - Helpers

    private func addItems(items: [ShotType], collectionView: UICollectionView,
                    interval: Double, completion: (() -> Void)?) {
        let addItemAnimation = {
            let newItemIndex = self.visibleItems.count
            let newItem = items[newItemIndex]
            self.visibleItems.append(newItem)
            collectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: newItemIndex,
                                                              inSection: 0)])
        }

        updateItems(items, collectionView: collectionView, interval: interval,
                animation: addItemAnimation, completion: completion)
    }

    private func deleteItemsWithoutFirstItem(items: [ShotType], collectionView: UICollectionView,
            interval: Double, completion: (() -> Void)?) {
        var reversedItemsWithoutFirstItem = items
        reversedItemsWithoutFirstItem.removeFirst()

        let removeItemAnimation = {
            let lastItemIndex = self.visibleItems.count - 1
            self.visibleItems.removeLast()
            collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: lastItemIndex,
                                                              inSection: 0)])
        }

        updateItems(reversedItemsWithoutFirstItem, collectionView: collectionView,
                interval: interval, animation: removeItemAnimation, completion: completion)
    }

    private func updateItems(items: [ShotType], collectionView: UICollectionView,
            interval: Double, animation: () -> Void, completion: (() -> Void)?) {
        for (index, _ ) in items.enumerate() {
            var updateAnimation = animation
            if index == items.endIndex - 1 {
                let batchUpdatesCompletion: (Bool -> Void) = { _ in
                    completion?()
                }
                updateAnimation = {
                    collectionView.performBatchUpdates(animation,
                                           completion: batchUpdatesCompletion)
                }
            }
            asyncWrapper.main(after: Double(index + 1) * interval, block: updateAnimation)
        }
    }
}
