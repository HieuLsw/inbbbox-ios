//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class InitialShotsCollectionViewLayout: UICollectionViewLayout {

//    MARK: - UICollectionViewLayout

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }
        return collectionView.bounds.size
    }

    override func layoutAttributesForElements(in rect: CGRect)
                    -> [UICollectionViewLayoutAttributes]? {
        return indexPathsOfItemsInRect(rect).map {
            self.layoutAttributesForItem(at: $0)!
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath)
                    -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if let collectionView = collectionView {
            let spacings = CollectionViewLayoutSpacings()
            let fixedLeftMargin = CGFloat(28)
            let fixedRightMargin = CGFloat(27)
            let indexMultiplier = CGFloat(indexPath.item)
            let calculatedItemWidth = round(collectionView.bounds.width) -
                    (fixedLeftMargin + fixedRightMargin) * (indexMultiplier + 1)

            let calculatedItemHeight: CGFloat
            if Settings.Customization.ShowAuthor {
                calculatedItemHeight = calculatedItemWidth * spacings.biggerShotHeightToWidthRatio
            } else {
                calculatedItemHeight = calculatedItemWidth * spacings.smallerShotHeightToWidthRatio
            }

            layoutAttributes.size = CGSize(width: calculatedItemWidth, height: calculatedItemHeight)
            layoutAttributes.center = CGPoint(x: collectionView.center.x,
                    y: collectionView.center.y +
                    spacings.initialShotsLayoutBottomCellOffset * indexMultiplier)
            layoutAttributes.zIndex = -indexPath.row
        }

        return layoutAttributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        var boundsChanged = true
        if let collectionView = collectionView {
            let oldBounds = collectionView.bounds
            boundsChanged = !oldBounds.size.equalTo(newBounds.size)
        }
        return boundsChanged
    }

    override func initialLayoutAttributesForAppearingItem(at indexPath: IndexPath)
                    -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = layoutAttributesForItem(at: indexPath)
        if let collectionView = collectionView, let layoutAttributes = layoutAttributes {
            layoutAttributes.center = collectionView.center
            layoutAttributes.alpha = 0
        }
        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingItem(at indexPath: IndexPath)
                    -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = layoutAttributesForItem(at: indexPath)
        if let collectionView = collectionView, let layoutAttributes = layoutAttributes {
            layoutAttributes.center = CGPoint(x: collectionView.bounds.midX,
                    y: collectionView.bounds.maxY + layoutAttributes.bounds.maxY)
            layoutAttributes.alpha = 0
        }
        return layoutAttributes
    }

//    MARK: - Helpers

    fileprivate func indexPathsOfItemsInRect(_ rect: CGRect) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        if let collectionView = collectionView {
            for itemIndex in 0 ..< collectionView.numberOfItems(inSection: 0) {
                indexPaths.append(IndexPath(item: itemIndex, section: 0))
            }
        }
        return indexPaths
    }

}
