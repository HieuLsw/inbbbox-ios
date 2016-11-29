//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotsCollectionViewFlowLayout: UICollectionViewFlowLayout {

//    Mark: - UICollectionViewLayout

    let spacings = CollectionViewLayoutSpacings()

    override func prepare() {
        if let collectionView = collectionView {
            let fixedLeftMargin = CGFloat(28)
            let fixedRightMargin = CGFloat(27)
            let calculatedItemWidth = round(collectionView.bounds.width) - fixedLeftMargin - fixedRightMargin

            let bigger = spacings.biggerShotHeightToWidthRatio
            let smaller = spacings.smallerShotHeightToWidthRatio
            let heightToWidthRatio: CGFloat = Settings.Customization.ShowAuthor ? bigger : smaller

            let calculatedItemHeight = calculatedItemWidth * heightToWidthRatio
            let calculatedVerticalSpacing = round(collectionView.bounds.height / 2 - calculatedItemHeight / 2)
            itemSize = CGSize(width: calculatedItemWidth, height: calculatedItemHeight)
            minimumLineSpacing = CGFloat(collectionView.bounds.height - calculatedItemHeight)
            sectionInset = UIEdgeInsets(top: calculatedVerticalSpacing,
                                        left: 0,
                                        bottom: calculatedVerticalSpacing,
                                        right: 0)
        }
    }
}
