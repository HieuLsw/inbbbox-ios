//
//  ProfileShotsViewController.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PromiseKit
import PeekPop

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

class ProfileShotsViewController: TwoLayoutsCollectionViewController, Support3DTouch, ContainingScrollableView {

    var dismissClosure: (() -> Void)?

    var modalTransitionAnimator: ZFModalTransitionAnimator?

    var scrollableView: UIScrollView {
        return collectionView!
    }

    var scrollContentOffset: (() -> CGPoint)?
    var didLayoutSubviews = false

    internal var peekPop: PeekPop?
    internal var didCheckedSupport3DForOlderDevices = false

    override var containsHeader: Bool {
        return false
    }

    fileprivate var viewModel: ProfileShotsViewModel!

    fileprivate var indexPathsNeededImageUpdate = [IndexPath]()

    /// Initialize view controller to show user's shots.
    ///
    /// - Note: According to Dribbble API - Team is a particular case of User,
    ///         so if you want to show team's shots - pass it as `UserType` with `accountType = .Team`.
    ///
    /// - parameter user: User to initialize view controller with.
    convenience init(user: UserType) {

        self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
                  twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)
        viewModel = ProfileShotsViewModel(user: user)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let collectionView = collectionView else { return }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .cell)
        collectionView.registerClass(SmallUserCollectionViewCell.self, type: .cell)
        collectionView.registerClass(LargeUserCollectionViewCell.self, type: .cell)
        collectionView.registerClass(ProfileHeaderView.self, type: .header)
        collectionView.updateInsets(top: ProfileView.headerInitialHeight)

        viewModel.downloadInitialItems()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didLayoutSubviews = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let collectionView = collectionView else { return }

        if viewModel.itemsCount == 0 {
            collectionView.updateInsets(bottom: collectionView.frame.height)
        }

        if let offset = scrollContentOffset?() {
            collectionView.contentOffset = offset
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let collectionView = collectionView {
            addSupport3DForOlderDevicesIfNeeded(with: self, viewController: self, sourceView: collectionView)
        }
    }
}

// MARK: UICollectionViewDataSource

extension ProfileShotsViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        return prepareUserCell(at: indexPath, in: collectionView)
    }
}

// MARK: UICollectionViewDelegate

extension ProfileShotsViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let detailsViewController = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
        detailsViewController.shotIndex = indexPath.item
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.userShots, initialViewController: detailsViewController)
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)

        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)

        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .custom

        present(pageViewController, animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {

        if indexPath.row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let index = indexPathsNeededImageUpdate.index(of: indexPath) {
            indexPathsNeededImageUpdate.remove(at: index)
        }
    }
}

// MARK: BaseCollectionViewViewModelDelegate

extension ProfileShotsViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
        self.adjustCollectionView()
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        collectionView?.reloadData()
        collectionView?.layoutIfNeeded()
        if let offset = self.scrollContentOffset?() {
            self.collectionView?.contentOffset = offset
        }

        if viewModel.collectionIsEmpty {
            guard let visibleViewController = navigationController?.visibleViewController else { return }
            FlashMessage.sharedInstance.showNotification(inViewController: visibleViewController, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(_ error: Error) {
        guard let visibleViewController = navigationController?.visibleViewController else { return }
        FlashMessage.sharedInstance.showNotification(inViewController: visibleViewController, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        collectionView?.insertItems(at: indexPaths)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }
}

// MARK: Private extension

private extension ProfileShotsViewController {

    func lazyLoadImage(_ shotImage: ShotImageType, forCell cell: SimpleShotCollectionViewCell,
                       atIndexPath indexPath: IndexPath) {
        let imageLoadingCompletion: (UIImage) -> Void = { [weak self] image in

            guard let certainSelf = self, certainSelf.indexPathsNeededImageUpdate.contains(indexPath) else {
                return
            }

            cell.shotImageView.image = image
        }
        LazyImageProvider.lazyLoadImageFromURLs(
            (shotImage.teaserURL, isCurrentLayoutOneColumn ? shotImage.normalURL : nil, nil),
            teaserImageCompletion: imageLoadingCompletion,
            normalImageCompletion: imageLoadingCompletion
        )
    }

    func prepareUserCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self, forIndexPath: indexPath, type: .cell)

        cell.contentView.backgroundColor = ColorModeProvider.current().shotViewCellBackground
        cell.shotImageView.image = nil
        let cellData = viewModel.shotCollectionViewCellViewData(indexPath)

        indexPathsNeededImageUpdate.append(indexPath)
        lazyLoadImage(cellData.shotImage, forCell: cell, atIndexPath: indexPath)

        cell.gifLabel.isHidden = !cellData.animated
        if !cell.isRegisteredTo3DTouch {
            cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
        }
        return cell
    }

    func adjustCollectionView() {
        guard let collectionView = collectionView else { return }
        if viewModel.itemsCount == 0 {
            collectionView.updateInsets(bottom: collectionView.frame.height)
        } else {
            if collectionView.contentSize.height < collectionView.frame.height {
                collectionView.updateInsets(bottom: collectionView.frame.height - collectionView.contentSize.height)
            } else {
                collectionView.updateInsets(bottom: 0)
            }
        }
        guard let offset = self.scrollContentOffset?() else { return }
        collectionView.contentOffset = offset
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension ProfileShotsViewController: UIViewControllerPreviewingDelegate {

    fileprivate func peekPopPresent(viewController: UIViewController) {
        if let detailsViewController = viewController as? ShotDetailsViewController {
            detailsViewController.customizeFor3DTouch(false)
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.userShots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            modalTransitionAnimator?.behindViewScale = 1

            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .custom

            present(pageViewController, animated: true, completion: nil)
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard
            let collectionView = collectionView,
            let indexPath = collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView.cellForItem(at: indexPath)
        else { return nil }

        previewingContext.sourceRect = cell.contentView.bounds
        let controller = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
        controller.customizeFor3DTouch(true)
        controller.shotIndex = indexPath.item

        return controller
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}

// MARK: PeekPopPreviewingDelegate

extension ProfileShotsViewController: PeekPopPreviewingDelegate {

    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let collectionView = collectionView,
            let indexPath = collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView.cellForItem(at: indexPath)
        else { return nil }

        let controller = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
        controller.customizeFor3DTouch(true)
        controller.shotIndex = indexPath.item
        previewingContext.sourceRect = cell.frame
        return controller
    }

    func previewingContext(_ previewingContext: PreviewingContext, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}
