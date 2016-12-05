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
import PeekPop

class SimpleShotsCollectionViewController: TwoLayoutsCollectionViewController {

    var viewModel: SimpleShotsViewModel?
    var modalTransitionAnimator: ZFModalTransitionAnimator?

    fileprivate var shouldShowLoadingView = true
    fileprivate var indexesToUpdateCellImage = [Int]()
    fileprivate var peekPop: PeekPop?
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
        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .cell)
        collectionView.emptyDataSetSource = self
        peekPop = PeekPop(viewController: self)
        _ = peekPop?.registerForPreviewingWithDelegate(self, sourceView: collectionView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.clearViewModelIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.downloadInitialItems()
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension SimpleShotsCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let indexPath = collectionView?.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView?.cellForItem(at: indexPath),
            let viewModel = viewModel
        else { return nil }
        
        previewingContext.sourceRect = cell.contentView.bounds
        
        let detailsViewController = ShotDetailsViewController(shot: viewModel.shots[indexPath.item])
        detailsViewController.customizeFor3DTouch(true)
        detailsViewController.shotIndex = indexPath.item
        
        return detailsViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        if let detailsViewController = viewControllerToCommit as? ShotDetailsViewController,
            let viewModel = viewModel {
            detailsViewController.customizeFor3DTouch(false)
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.shots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            modalTransitionAnimator?.behindViewScale = 1
            
            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .custom
            
            tabBarController?.present(pageViewController, animated: true, completion: nil)
        }
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension SimpleShotsCollectionViewController: PeekPopPreviewingDelegate {
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard
            let indexPath = collectionView?.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView?.cellForItem(at: indexPath),
            let viewModel = viewModel
            else { return nil }

        previewingContext.sourceRect = cell.contentView.bounds

        let detailsViewController = ShotDetailsViewController(shot: viewModel.shots[indexPath.item])
        detailsViewController.customizeFor3DTouch(true)
        detailsViewController.shotIndex = indexPath.item

        return detailsViewController
    }

    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {

        if let detailsViewController = viewControllerToCommit as? ShotDetailsViewController,
            let viewModel = viewModel {
            detailsViewController.customizeFor3DTouch(false)
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.shots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            modalTransitionAnimator?.behindViewScale = 1

            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .custom

            tabBarController?.present(pageViewController, animated: true, completion: nil)
        }
    }
}

// MARK: UICollectionViewDataSource

extension SimpleShotsCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self, forIndexPath: indexPath,
                type: .cell)
        let cellData = viewModel!.shotCollectionViewCellViewData(indexPath)

        indexesToUpdateCellImage.append(indexPath.row)
        lazyLoadImage(cellData.shotImage, atIndexPath: indexPath)
        
        if !cell.isRegisteredTo3DTouch {
            cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
        }

        cell.gifLabel.isHidden = !cellData.animated
        return cell
    }

}

// MARK: UICollectionViewDelegate

extension SimpleShotsCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
            forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel!.itemsCount - 1) {
            viewModel?.downloadItemsForNextPage()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
        pageViewController.modalPresentationStyle = .custom

        tabBarController?.present(pageViewController, animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if let index = indexesToUpdateCellImage.index(of: indexPath.row) {
            indexesToUpdateCellImage.remove(at: index)
        }
    }
}

extension SimpleShotsCollectionViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        shouldShowLoadingView = false
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        self.shouldShowLoadingView = false
        collectionView?.reloadData()

        if let viewModel = viewModel, viewModel.shots.isEmpty {
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

extension SimpleShotsCollectionViewController: DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {

        guard let viewModel = viewModel else { return UIView() }

        if shouldShowLoadingView {
            let loadingView = EmptyDataSetLoadingView.newAutoLayout()
            loadingView.startAnimating()
            return loadingView
        } else {
            let emptyDataSetView = EmptyDataSetView.newAutoLayout()
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
    func adaptColorMode(_ mode: ColorModeType) {
        collectionView?.reloadData()
    }
}

// MARK: Lazy loading of image

private extension SimpleShotsCollectionViewController {

    func lazyLoadImage(_ shotImage: ShotImageType, atIndexPath indexPath: IndexPath) {
        let imageLoadingCompletion: (UIImage) -> Void = { [weak self] image in

            guard let certainSelf = self, certainSelf.indexesToUpdateCellImage.contains(indexPath.row) else {
                return
            }

            typealias cellType = SimpleShotCollectionViewCell
            if let cell = certainSelf.collectionView?.cellForItem(at: indexPath) as? cellType {
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
