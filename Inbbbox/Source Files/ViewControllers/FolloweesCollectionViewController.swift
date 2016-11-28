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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FolloweesCollectionViewController: TwoLayoutsCollectionViewController {

    // MARK: - Lifecycle

    fileprivate let viewModel = FolloweesViewModel()
    fileprivate var shouldShowLoadingView = true
    fileprivate var indexPathsNeededImageUpdate = [IndexPath]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let collectionView = collectionView else {
            return
        }
        collectionView.registerClass(SmallUserCollectionViewCell.self, type: .cell)
        collectionView.registerClass(LargeUserCollectionViewCell.self, type: .cell)
        collectionView.emptyDataSetSource = self
        viewModel.delegate = self
        navigationItem.title = viewModel.title
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.clearViewModelIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.downloadInitialItems()
        AnalyticsManager.trackScreen(.FolloweesView)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellData = viewModel.followeeCollectionViewCellViewData(indexPath)

        indexPathsNeededImageUpdate.append(indexPath)

        if collectionView.collectionViewLayout.isKind(of: TwoColumnsCollectionViewFlowLayout.self) {
            let cell = collectionView.dequeueReusableClass(SmallUserCollectionViewCell.self,
                    forIndexPath: indexPath, type: .cell)
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
                    forIndexPath: indexPath, type: .cell)
            cell.clearImages()
            cell.avatarView.imageView.loadImageFromURL(cellData.avatarURL)
            cell.nameLabel.text = cellData.name
            cell.numberOfShotsLabel.text = cellData.numberOfShots
            cell.shotImageView.backgroundColor = ColorModeProvider.current().shotViewCellBackground
            if let shotImage = cellData.firstShotImage {

                let imageLoadingCompletion: (UIImage) -> Void = { [weak self] image in

                    guard let certainSelf = self, certainSelf.indexPathsNeededImageUpdate.contains(indexPath) else { return }

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

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.itemsCount - 1) {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profileViewController = ProfileViewController(user: viewModel.followees[indexPath.item])
        profileViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if let index = indexPathsNeededImageUpdate.index(of: indexPath) {
            indexPathsNeededImageUpdate.remove(at: index)
        }
    }
}

extension FolloweesCollectionViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        shouldShowLoadingView = false
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        self.shouldShowLoadingView = false
        collectionView?.reloadData()

        if viewModel.followees.isEmpty {
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(_ error: Error) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        collectionView?.insertItems(at: indexPaths)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }
}

extension FolloweesCollectionViewController: DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {

        if shouldShowLoadingView {
            let loadingView = EmptyDataSetLoadingView.newAutoLayout()
            loadingView.startAnimating()
            return loadingView
        } else {
            let emptyDataSetView = EmptyDataSetView.newAutoLayout()
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
    func adaptColorMode(_ mode: ColorModeType) {
        collectionView?.reloadData()
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension FolloweesCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let indexPath = collectionView?.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView?.cellForItem(at: indexPath)
        else { return nil }
        
        previewingContext.sourceRect = cell.contentView.bounds
        
        
        let profileViewController = ProfileViewController(user: viewModel.followees[indexPath.item])
        profileViewController.hidesBottomBarWhenPushed = true
        
        return profileViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}
