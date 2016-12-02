//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol ShotsAnimatorDelegate: class {
    func collectionViewForShotsAnimator(_ animator: ShotsAnimator) -> UICollectionView?

    func itemsForShotsAnimator(_ animator: ShotsAnimator) -> [ShotType]
}

class ShotsAnimator {

    weak var delegate: ShotsAnimatorDelegate?
    var visibleItems = [ShotType]()
    var asyncWrapper = AsyncWrapper()

//    Interface

    func startAnimationWithCompletion(_ completion: (() -> Void)?) {
        guard let collectionView = delegate?.collectionViewForShotsAnimator(self),
                let items = delegate?.itemsForShotsAnimator(self), items.count != 0 else {
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

    fileprivate func addItems(_ items: [ShotType], collectionView: UICollectionView,
                    interval: Double, completion: (() -> Void)?) {
        let addItemAnimation = {
            let newItemIndex = self.visibleItems.count
            let newItem = items[newItemIndex]
            self.visibleItems.append(newItem)
            collectionView.insertItems(at: [IndexPath(item: newItemIndex,
                                                              section: 0)])
        }

        updateItems(items, collectionView: collectionView, interval: interval,
                animation: addItemAnimation, completion: completion)
    }

    fileprivate func deleteItemsWithoutFirstItem(_ items: [ShotType], collectionView: UICollectionView,
            interval: Double, completion: (() -> Void)?) {
        var reversedItemsWithoutFirstItem = items
        reversedItemsWithoutFirstItem.removeFirst()

        let removeItemAnimation = {
            let lastItemIndex = self.visibleItems.count - 1
            self.visibleItems.removeLast()
            collectionView.deleteItems(at: [IndexPath(item: lastItemIndex,
                                                              section: 0)])
        }

        updateItems(reversedItemsWithoutFirstItem, collectionView: collectionView,
                interval: interval, animation: removeItemAnimation, completion: completion)
    }

    fileprivate func updateItems(_ items: [ShotType], collectionView: UICollectionView,
            interval: Double, animation: @escaping () -> Void, completion: (() -> Void)?) {
        for (index, _ ) in items.enumerated() {
            var updateAnimation = animation
            if index == items.endIndex - 1 {
                let batchUpdatesCompletion: ((Bool) -> Void) = { _ in
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
