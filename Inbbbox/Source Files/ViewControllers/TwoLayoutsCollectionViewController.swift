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
            return collectionView!.collectionViewLayout.isKind(of: OneColumnCollectionViewFlowLayout.self)
        }
    }

    var containsHeader: Bool {
        return false
    }

    fileprivate var oneColumnLayoutButton: UIBarButtonItem?
    fileprivate var twoColumnsLayoutButton: UIBarButtonItem?

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
                style: .plain, target: self, action: #selector(didTapOneColumnLayoutButton(_:)))
        twoColumnsLayoutButton = UIBarButtonItem(image: UIImage(named: "ic-gridview-active"),
                style: .plain, target: self, action: #selector(didTapTwoColumnsLayoutButton(_:)))
        navigationItem.rightBarButtonItems = [oneColumnLayoutButton!, twoColumnsLayoutButton!]
    }

    func updateBarButtons(_ layout: UICollectionViewLayout) {
        oneColumnLayoutButton?.tintColor =
                !isCurrentLayoutOneColumn ? UIColor.white.withAlphaComponent(0.35) : UIColor.white
        twoColumnsLayoutButton?.tintColor =
                isCurrentLayoutOneColumn ? UIColor.white.withAlphaComponent(0.35) : UIColor.white
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
        if collectionView.collectionViewLayout.isKind(of: OneColumnCollectionViewFlowLayout.self) {
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
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        scrollToTop(collectionView)
        updateBarButtons(collectionView.collectionViewLayout)
    }

    func scrollToTop(_ collectionView: UICollectionView) {
        if collectionView.numberOfItems(inSection: 0) > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
}
