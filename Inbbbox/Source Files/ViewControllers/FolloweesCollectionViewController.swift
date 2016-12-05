//
//  FolloweesCollectionViewController.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 27.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import DZNEmptyDataSet

class FolloweesCollectionViewController: TwoLayoutsCollectionViewController {

    // MARK: - Lifecycle

    private let viewModel = FolloweesViewModel()
    private var shouldShowLoadingView = true
    private var indexPathsNeededImageUpdate = [NSIndexPath]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else {
            return
        }
        collectionView.registerClass(SmallUserCollectionViewCell.self, type: .Cell)
        collectionView.registerClass(LargeUserCollectionViewCell.self, type: .Cell)
        collectionView.emptyDataSetSource = self
        viewModel.delegate = self
        navigationItem.title = viewModel.title
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.clearViewModelIfNeeded()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.downloadInitialItems()
        AnalyticsManager.trackScreen(.FolloweesView)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cellData = viewModel.followeeCollectionViewCellViewData(indexPath)

        indexPathsNeededImageUpdate.append(indexPath)

        if collectionView.collectionViewLayout.isKindOfClass(TwoColumnsCollectionViewFlowLayout) {
            let cell = collectionView.dequeueReusableClass(SmallUserCollectionViewCell.self,
                    forIndexPath: indexPath, type: .Cell)
            cell.clearImages()
            cell.avatarView.imageView.loadImageFromURL(cellData.avatarURL)
            cell.nameLabel.text = cellData.name
            cell.numberOfShotsLabel.text = cellData.numberOfShots
            cell.updateImageViewsWith(ColorModeProvider.current().shotViewCellBackground)
            if cellData.shotsImagesURLs?.count > 0 {
                cell.firstShotImageView.loadImageFromURL(cellData.shotsImagesURLs![0])
                cell.secondShotImageView.loadImageFromURL(cellData.shotsImagesURLs![1])
                cell.thirdShotImageView.loadImageFromURL(cellData.shotsImagesURLs![2])
                cell.fourthShotImageView.loadImageFromURL(cellData.shotsImagesURLs![3])
            }
            if !cell.isRegisteredTo3DTouch {
                cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableClass(LargeUserCollectionViewCell.self,
                    forIndexPath: indexPath, type: .Cell)
            cell.clearImages()
            cell.avatarView.imageView.loadImageFromURL(cellData.avatarURL)
            cell.nameLabel.text = cellData.name
            cell.numberOfShotsLabel.text = cellData.numberOfShots
            cell.shotImageView.backgroundColor = ColorModeProvider.current().shotViewCellBackground
            if let shotImage = cellData.firstShotImage {

                let imageLoadingCompletion: UIImage -> Void = { [weak self] image in

                    guard let certainSelf = self
                            where certainSelf.indexPathsNeededImageUpdate.contains(indexPath) else { return }

                    cell.shotImageView.image = image
                }
                LazyImageProvider.lazyLoadImageFromURLs(
                    (shotImage.teaserURL, isCurrentLayoutOneColumn ? shotImage.normalURL : nil, nil),
                    teaserImageCompletion: imageLoadingCompletion,
                    normalImageCompletion: imageLoadingCompletion
                )
            }
            if !cell.isRegisteredTo3DTouch {
                cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
            }
            return cell
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
                                 forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let profileViewController = ProfileViewController(user: viewModel.followees[indexPath.item])
        profileViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }

    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell,
                                 forItemAtIndexPath indexPath: NSIndexPath) {
        if let index = indexPathsNeededImageUpdate.indexOf(indexPath) {
            indexPathsNeededImageUpdate.removeAtIndex(index)
        }
    }
}

extension FolloweesCollectionViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        shouldShowLoadingView = false
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(error: ErrorType) {
        self.shouldShowLoadingView = false
        collectionView?.reloadData()

        if viewModel.followees.isEmpty {
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(error: ErrorType) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }

    func viewModel(viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        collectionView?.insertItemsAtIndexPaths(indexPaths)
    }

    func viewModel(viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: NSIndexPath) {
        collectionView?.reloadItemsAtIndexPaths([indexPath])
    }
}

extension FolloweesCollectionViewController: DZNEmptyDataSetSource {

    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {

        if shouldShowLoadingView {
            let loadingView = EmptyDataSetLoadingView.newAutoLayoutView()
            loadingView.startAnimating()
            return loadingView
        } else {
            let emptyDataSetView = EmptyDataSetView.newAutoLayoutView()
            emptyDataSetView.setDescriptionText(
                firstLocalizedString: NSLocalizedString("FolloweesCollectionView.EmptyData.FirstLocalizedString",
                        comment: "FolloweesCollectionView, empty data set view"),
                attachmentImage: UIImage(named: "ic-following-emptystate"),
                imageOffset: CGPoint(x: 0, y: -3),
                lastLocalizedString: NSLocalizedString("FolloweesCollectionView.EmptyData.LastLocalizedString",
                        comment: "FolloweesCollectionView, empty data set view")
            )
            return emptyDataSetView
        }
    }
}

extension FolloweesCollectionViewController: ColorModeAdaptable {
    func adaptColorMode(mode: ColorModeType) {
        collectionView?.reloadData()
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension FolloweesCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let indexPath = collectionView?.indexPathForItemAtPoint(previewingContext.sourceView.convertPoint(location, toView: collectionView)),
            let cell = collectionView?.cellForItemAtIndexPath(indexPath)
        else { return nil }
        
        previewingContext.sourceRect = cell.contentView.bounds
        
        
        let profileViewController = ProfileViewController(user: viewModel.followees[indexPath.item])
        profileViewController.hidesBottomBarWhenPushed = true
        
        return profileViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
