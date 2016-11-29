//
//  AutoScrollableShotsDataSource.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 28/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class AutoScrollableShotsDataSource: NSObject {

    fileprivate typealias AutoScrollableImageContent = (image: UIImage,
                            isDuplicateForExtendedContent: Bool)
    fileprivate var content: [AutoScrollableImageContent]!

    fileprivate(set) var extendedScrollableItemsCount = 0
    var itemSize: CGSize {
        return CGSize(width: collectionView.bounds.width,
                     height: collectionView.bounds.width)
    }
    let collectionView: UICollectionView

    init(collectionView: UICollectionView, content: [UIImage]) {
        self.collectionView = collectionView
        self.content = content.map { ($0, false) }

        super.init()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(AutoScrollableCollectionViewCell.self, type: .cell)
        prepareExtendedContentToDisplayWithOffset(0)
    }

    @available(*, unavailable, message: "Use init(collectionView:content:) instead")
    override init() {
        fatalError("init() has not been implemented")
    }

    /// Prepares itself for animation and reloads collectionView.
    func prepareForAnimation() {
        extendedScrollableItemsCount = Int(ceil(collectionView.bounds.height /
             itemSize.height))
        prepareExtendedContentToDisplayWithOffset(extendedScrollableItemsCount)
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension AutoScrollableShotsDataSource: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(AutoScrollableCollectionViewCell.self,
                                         forIndexPath: indexPath,
                                                 type: .cell)

        cell.imageView.image = content[indexPath.row].image

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
            numberOfItemsInSection section: Int) -> Int {
        return content.count
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension AutoScrollableShotsDataSource: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}

// MARK: Private

private extension AutoScrollableShotsDataSource {

    func prepareExtendedContentToDisplayWithOffset(_ offset: Int) {

        let images = content.filter { !$0.isDuplicateForExtendedContent }

        var extendedContent = [AutoScrollableImageContent]()

        for index in 0..<(images.count + 2 * offset) {

            let indexSubscript: Int
            var isDuplicateForExtendedContent = true

            if index < offset {
                indexSubscript = images.count - offset + index

            } else if index > images.count + offset - 1 {
                indexSubscript = index - images.count - offset

            } else {
                isDuplicateForExtendedContent = false
                indexSubscript = index - offset
            }

            extendedContent.append((images[indexSubscript].image, isDuplicateForExtendedContent))
        }

        content = extendedContent
    }
}
