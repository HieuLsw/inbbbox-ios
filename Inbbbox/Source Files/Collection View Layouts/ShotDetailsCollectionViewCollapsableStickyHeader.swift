//
//  ShotDetailsCollectionViewCollapsableStickyHeader.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotDetailsCollectionCollapsableViewStickyHeader: UICollectionViewFlowLayout {

    var collapsableHeight: CGFloat!

    override init() {
        super.init()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }

    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        var superAttributes = super.layoutAttributesForElementsInRect(rect)

        guard let collectionView = collectionView else {
            return superAttributes
        }

        let currentOffsetY = collectionView.contentOffset.y
        let minY = -collectionView.contentInset.top
        let deltaY = CGFloat(fabsf(Float(currentOffsetY - minY)))

        if currentOffsetY <= minY {
            return superAttributes
        }

        let headerElements = superAttributes!.filter {
            if let elemedKind = $0.representedElementKind {
                return elemedKind == UICollectionElementKindSectionHeader
            }
            return false
        }

        // gain header attributes from current header elements or create new one if not found.
        let headerAtributes: UICollectionViewLayoutAttributes = {

            if let attributes = headerElements.first {
                return attributes
            }

            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: NSIndexPath(forItem: 0, inSection:
                0))
            superAttributes?.append(attributes)

            return attributes
        }()

        // calculate frame depend on current or created header attributes.
        let frame: CGRect

        if let headerAtributes = headerElements.first {
            frame = {
                var frame = headerAtributes.frame
                frame.origin.y = frame.origin.y + deltaY
                frame.size.height = max(headerAtributes.size.height - currentOffsetY, collapsableHeight)

                return frame
            }()

        } else {
            frame = CGRect(x: 0, y: currentOffsetY, width: collectionView.frame.size.width, height: collapsableHeight)
        }

        headerAtributes.zIndex = 64
        headerAtributes.frame = frame

        return superAttributes
    }
}

private extension ShotDetailsCollectionCollapsableViewStickyHeader {

    func setupLayout() {
        sectionInset = UIEdgeInsetsZero
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
}
