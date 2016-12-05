//
//  TwoLayoutsCollectionViewController.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 28.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class TwoLayoutsCollectionViewController: UICollectionViewController {

    // MARK: - Lifecycle

    var oneColumnLayoutCellHeightToWidthRatio = CGFloat(1)
    var twoColumnsLayoutCellHeightToWidthRatio = CGFloat(1)

    var isCurrentLayoutOneColumn: Bool {
        get {
            return collectionView!.collectionViewLayout.isKindOfClass(OneColumnCollectionViewFlowLayout)
        }
    }

    var containsHeader: Bool {
        return false
    }

    private var oneColumnLayoutButton: UIBarButtonItem?
    private var twoColumnsLayoutButton: UIBarButtonItem?

    convenience init(oneColumnLayoutCellHeightToWidthRatio: CGFloat, twoColumnsLayoutCellHeightToWidthRatio: CGFloat) {
        let flowLayout = TwoColumnsCollectionViewFlowLayout()
        flowLayout.itemHeightToWidthRatio = twoColumnsLayoutCellHeightToWidthRatio
        self.init(collectionViewLayout: flowLayout)
        flowLayout.containsHeader = containsHeader
        self.oneColumnLayoutCellHeightToWidthRatio = oneColumnLayoutCellHeightToWidthRatio
        self.twoColumnsLayoutCellHeightToWidthRatio = twoColumnsLayoutCellHeightToWidthRatio
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else {
            return
        }
        setupBarButtons()
        updateBarButtons(collectionView.collectionViewLayout)
    }

    // MARK: Configuration

    func setupBarButtons() {
        oneColumnLayoutButton = UIBarButtonItem(image: UIImage(named: "ic-listview"),
                style: .Plain, target: self, action: #selector(didTapOneColumnLayoutButton(_:)))
        twoColumnsLayoutButton = UIBarButtonItem(image: UIImage(named: "ic-gridview-active"),
                style: .Plain, target: self, action: #selector(didTapTwoColumnsLayoutButton(_:)))
        navigationItem.rightBarButtonItems = [oneColumnLayoutButton!, twoColumnsLayoutButton!]
    }

    func updateBarButtons(layout: UICollectionViewLayout) {
        oneColumnLayoutButton?.tintColor =
                !isCurrentLayoutOneColumn ? UIColor.whiteColor().colorWithAlphaComponent(0.35) : UIColor.whiteColor()
        twoColumnsLayoutButton?.tintColor =
                isCurrentLayoutOneColumn ? UIColor.whiteColor().colorWithAlphaComponent(0.35) : UIColor.whiteColor()
    }

    // MARK: Actions:

    func didTapOneColumnLayoutButton(_: UIBarButtonItem) {
        if !isCurrentLayoutOneColumn {
            changeLayout()
        }
    }

    func didTapTwoColumnsLayoutButton(_: UIBarButtonItem) {
        if isCurrentLayoutOneColumn {
            changeLayout()
        }
    }

    // Mark: Changing layout

    func changeLayout() {
        guard let collectionView = collectionView else {
            return
        }
        if collectionView.collectionViewLayout.isKindOfClass(OneColumnCollectionViewFlowLayout) {
            let flowLayout = TwoColumnsCollectionViewFlowLayout()
            flowLayout.itemHeightToWidthRatio = twoColumnsLayoutCellHeightToWidthRatio
            flowLayout.containsHeader = containsHeader
            collectionView.setCollectionViewLayout(flowLayout, animated: false)
        } else {
            let flowLayout = OneColumnCollectionViewFlowLayout()
            flowLayout.itemHeightToWidthRatio = oneColumnLayoutCellHeightToWidthRatio
            flowLayout.containsHeader = containsHeader
            collectionView.setCollectionViewLayout(flowLayout, animated: false)
        }
        /*
         Hack for ticket: https://netguru.atlassian.net/browse/IOS-441
         reloadData() was not always causing refreshing visible cells, this do the work
         */
        collectionView.reloadItemsAtIndexPaths(collectionView.indexPathsForVisibleItems())
        scrollToTop(collectionView)
        updateBarButtons(collectionView.collectionViewLayout)
    }

    func scrollToTop(collectionView: UICollectionView) {
        if collectionView.numberOfItemsInSection(0) > 0 {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
        }
    }
}
