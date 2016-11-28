//
//  SimpleShotsCollectionViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 13/04/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import ZFDragableModalTransition
import DZNEmptyDataSet

class SimpleShotsCollectionViewController: TwoLayoutsCollectionViewController {

    var viewModel: SimpleShotsViewModel?
    var modalTransitionAnimator: ZFModalTransitionAnimator?

    private var shouldShowLoadingView = true
    private var indexesToUpdateCellImage = [Int]()
}

// MARK: Lifecycle

extension SimpleShotsCollectionViewController {

    /// Use this `init` to display shots from given bucket.
    ///
    /// - parameter bucket: Bucket to display shots for.
    convenience init(bucket: BucketType) {
        self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
                twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)
        self.viewModel = BucketContentViewModel(bucket: bucket)
    }

    /// Use this `init` to display liked shots.
    convenience init() {
        self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
            twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)
        self.viewModel = LikesViewModel()
    }
}

// MARK: UIViewController

extension SimpleShotsCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.delegate = self
        navigationItem.title = viewModel?.title
        guard let collectionView = collectionView else {
            return
        }
        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .Cell)
        collectionView.emptyDataSetSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.clearViewModelIfNeeded()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.downloadInitialItems()
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension SimpleShotsCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let indexPath = collectionView?.indexPathForItemAtPoint(previewingContext.sourceView.convertPoint(location, toView: collectionView)),
            let cell = collectionView?.cellForItemAtIndexPath(indexPath),
            let viewModel = viewModel
        else { return nil }
        
        previewingContext.sourceRect = cell.contentView.bounds
        
        let detailsViewController = ShotDetailsViewController(shot: viewModel.shots[indexPath.item])
        detailsViewController.customizeFor3DTouch(true)
        detailsViewController.shotIndex = indexPath.item
        
        return detailsViewController
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        
        if let detailsViewController = viewControllerToCommit as? ShotDetailsViewController,
            let viewModel = viewModel {
            detailsViewController.customizeFor3DTouch(false)
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.shots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            modalTransitionAnimator?.behindViewScale = 1
            
            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .Custom
            
            tabBarController?.presentViewController(pageViewController, animated: true, completion: nil)
        }
    }
}

// MARK: UICollectionViewDataSource

extension SimpleShotsCollectionViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.itemsCount
    }

    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self, forIndexPath: indexPath,
                type: .Cell)
        let cellData = viewModel!.shotCollectionViewCellViewData(indexPath)

        indexesToUpdateCellImage.append(indexPath.row)
        lazyLoadImage(cellData.shotImage, atIndexPath: indexPath)
        
        if !cell.isRegisteredTo3DTouch {
            cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
        }

        cell.gifLabel.hidden = !cellData.animated
        return cell
    }

}

// MARK: UICollectionViewDelegate

extension SimpleShotsCollectionViewController {

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
            forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel!.itemsCount - 1 {
            viewModel?.downloadItemsForNextPage()
        }
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let viewModel = viewModel else {
            return
        }

        let initializedFromLikesView: Bool? = viewModel is LikesViewModel ? true : nil
        let detailsViewController = ShotDetailsViewController(shot: viewModel.shots[indexPath.item], isLiked: initializedFromLikesView)
        detailsViewController.shotIndex = indexPath.item
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.shots, initialViewController: detailsViewController, likesData: initializedFromLikesView)
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
        
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
        
        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .Custom

        tabBarController?.presentViewController(pageViewController, animated: true, completion: nil)
    }

    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell,
                                 forItemAtIndexPath indexPath: NSIndexPath) {
        if let index = indexesToUpdateCellImage.indexOf(indexPath.row) {
            indexesToUpdateCellImage.removeAtIndex(index)
        }
    }
}

extension SimpleShotsCollectionViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        shouldShowLoadingView = false
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(error: ErrorType) {
        self.shouldShowLoadingView = false
        collectionView?.reloadData()

        if let viewModel = viewModel where viewModel.shots.isEmpty {
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

extension SimpleShotsCollectionViewController: DZNEmptyDataSetSource {

    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {

        guard let viewModel = viewModel else { return UIView() }

        if shouldShowLoadingView {
            let loadingView = EmptyDataSetLoadingView.newAutoLayoutView()
            loadingView.startAnimating()
            return loadingView
        } else {
            let emptyDataSetView = EmptyDataSetView.newAutoLayoutView()
            let descriptionAttributes = viewModel.emptyCollectionDescriptionAttributes()
            emptyDataSetView.setDescriptionText(
                firstLocalizedString: descriptionAttributes.firstLocalizedString,
                attachmentImage: UIImage(named: descriptionAttributes.attachmentImageName),
                imageOffset: descriptionAttributes.imageOffset,
                lastLocalizedString: descriptionAttributes.lastLocalizedString
            )
            return emptyDataSetView
        }
    }
}

extension SimpleShotsCollectionViewController: ColorModeAdaptable {
    func adaptColorMode(mode: ColorModeType) {
        collectionView?.reloadData()
    }
}

// MARK: Lazy loading of image

private extension SimpleShotsCollectionViewController {

    func lazyLoadImage(shotImage: ShotImageType, atIndexPath indexPath: NSIndexPath) {
        let imageLoadingCompletion: UIImage -> Void = { [weak self] image in

            guard let certainSelf = self where certainSelf.indexesToUpdateCellImage.contains(indexPath.row) else {
                return
            }

            typealias cellType = SimpleShotCollectionViewCell
            if let cell = certainSelf.collectionView?.cellForItemAtIndexPath(indexPath) as? cellType {
                cell.shotImageView.image = nil
                cell.shotImageView.image = image
            }
        }

        LazyImageProvider.lazyLoadImageFromURLs(
            (shotImage.teaserURL, isCurrentLayoutOneColumn ? shotImage.normalURL : nil, nil),
            teaserImageCompletion: imageLoadingCompletion,
            normalImageCompletion: imageLoadingCompletion
        )
    }
}
