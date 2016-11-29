//
//  AutoScrollableShotsView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 28/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class AutoScrollableShotsView: UIView {

    fileprivate var didSetConstraints = false
    fileprivate(set) var collectionViews = [UICollectionView]()

    init(numberOfColumns: Int) {
        super.init(frame: CGRect.zero)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        repeat {

            let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
            collectionView.isUserInteractionEnabled = false
            collectionView.configureForAutoLayout()
            addSubview(collectionView)

            collectionViews.append(collectionView)

        } while collectionViews.count < numberOfColumns

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(numberOfColumns:) instead")
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(numberOfColumns:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            let viewsToDistribute = collectionViews as NSArray
            viewsToDistribute.autoDistributeViews(along: .horizontal, alignedTo: .horizontal,
                    withFixedSpacing: 0, insetSpacing: false)

            for collectionView in collectionViews {
                collectionView.autoPinEdge(toSuperviewEdge: .top)
                collectionView.autoPinEdge(toSuperviewEdge: .bottom)
            }
        }

        super.updateConstraints()
    }
}
