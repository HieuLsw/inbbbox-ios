//
//  ProfileShotsOrMembersViewController.swift
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

class ProfileShotsOrMembersViewController: TwoLayoutsCollectionViewController, Support3DTouch, TriggeringHeaderUpdate {

    var shouldHideHeader: (() -> Void)?
    var shouldShowHeader: (() -> Void)?
    var didLoadTeamMembers: ((Int) -> Void)?
    var dismissClosure: (() -> Void)?

    var modalTransitionAnimator: ZFModalTransitionAnimator?

    internal var peekPop: PeekPop?
    internal var didCheckedSupport3DForOlderDevices = false

    override var containsHeader: Bool {
        return false
    }

    fileprivate var viewModel: ProfileShotsOrMembersViewModel!

    fileprivate var indexPathsNeededImageUpdate = [IndexPath]()

    /// Initialize view controller to show user's shots or team's members.
    ///
    /// - Note: According to Dribbble API - Team is a particular case of User,
    ///         so if you want to show team's details - pass it as `UserType` with `accountType = .Team`.
    ///
    /// - parameter user: User to initialize view controller with.
    convenience init(user: UserType) {

        guard let accountType = user.accountType, accountType == .Team else {
            self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
                      twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)
            viewModel = UserDetailsViewModel(user: user)
            viewModel.delegate = self
            return
        }

        let team = Team(
            identifier: user.identifier,
            name: user.name ?? "",
            username: user.username,
            avatarURL: user.avatarURL,
            createdAt: Date(),
            followersCount: user.followersCount,
            followingsCount: user.followingsCount,
            bio: user.bio,
            location: user.location
        )
        self.init(team: team)
    }

    fileprivate convenience init(team: TeamType) {

        self.init(oneColumnLayoutCellHeightToWidthRatio: LargeUserCollectionViewCell.heightToWidthRatio,
                  twoColumnsLayoutCellHeightToWidthRatio: SmallUserCollectionViewCell.heightToWidthRatio)

        viewModel = TeamDetailsViewModel(team: team)
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

        viewModel.downloadInitialItems()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addSupport3DForOlderDevicesIfNeeded(with: self, viewController: self, sourceView: collectionView!)
    }
}

// MARK: UIScrollViewDelegate

extension ProfileShotsOrMembersViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            shouldShowHeader?()
        }
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            scrollView.contentOffset.y <= 0 ? shouldShowHeader?() : shouldHideHeader?()
        }
    }
}

// MARK: UICollectionViewDataSource

extension ProfileShotsOrMembersViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let cell = prepareUserCell(at: indexPath, in: collectionView) {
            return cell
        } else if let cell = prepareTeamCell(at: indexPath, in: collectionView) {
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

// MARK: UICollectionViewDelegate

extension ProfileShotsOrMembersViewController {

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if let viewModel = viewModel as? UserDetailsViewModel {

            let detailsViewController = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
            detailsViewController.shotIndex = indexPath.item
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.userShots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            
            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .custom

            present(pageViewController, animated: true, completion: nil)
        }
        if let viewModel = viewModel as? TeamDetailsViewModel {

            let profileViewController = ProfileViewController(user: viewModel.teamMembers[indexPath.item])
            profileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        switch viewModel {
        case is UserDetailsViewModel:
            if indexPath.row == viewModel.itemsCount - 1 {
                (viewModel as! UserDetailsViewModel).downloadItemsForNextPage()
            }
        case is TeamDetailsViewModel:
            (viewModel as! TeamDetailsViewModel).downloadItem(at: indexPath.row)
        default:
            break
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

extension ProfileShotsOrMembersViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        if let viewModel = viewModel as? TeamDetailsViewModel {
            didLoadTeamMembers?(viewModel.teamMembers.count)
        }
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        collectionView?.reloadData()

        if viewModel.collectionIsEmpty {
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

// MARK: Private extension

private extension ProfileShotsOrMembersViewController {

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

    func prepareUserCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell? {

        guard let viewModel = viewModel as? UserDetailsViewModel else { return nil }

        let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self,
                                                       forIndexPath: indexPath, type: .cell)

        cell.backgroundColor = ColorModeProvider.current().shotViewCellBackground
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

    func prepareTeamCell(at indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell? {

        guard let viewModel = viewModel as? TeamDetailsViewModel else { return nil }

        let cellData = viewModel.userCollectionViewCellViewData(indexPath)

        indexPathsNeededImageUpdate.append(indexPath)

        if collectionView.collectionViewLayout.isKind(of: TwoColumnsCollectionViewFlowLayout.self) {
            let cell = collectionView.dequeueReusableClass(SmallUserCollectionViewCell.self,
                                                           forIndexPath: indexPath, type: .cell)
            cell.avatarView.imageView.loadImageFromURL(cellData.avatarURL)
            cell.nameLabel.text = cellData.name
            cell.numberOfShotsLabel.text = cellData.numberOfShots
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
            cell.avatarView.imageView.loadImageFromURL(cellData.avatarURL)
            cell.nameLabel.text = cellData.name
            cell.numberOfShotsLabel.text = cellData.numberOfShots
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
}

// MARK: UIViewControllerPreviewingDelegate

extension ProfileShotsOrMembersViewController: UIViewControllerPreviewingDelegate {

    fileprivate func peekPopPresent(viewController: UIViewController) {
        if let viewModel = viewModel as? UserDetailsViewModel, let detailsViewController = viewController as? ShotDetailsViewController {
            detailsViewController.customizeFor3DTouch(false)
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.userShots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            modalTransitionAnimator?.behindViewScale = 1

            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .custom

            present(pageViewController, animated: true, completion: nil)
        } else if (viewModel is TeamDetailsViewModel) {
            navigationController?.pushViewController(viewController, animated: true)
        }

    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard
            let collectionView = collectionView,
            let indexPath = collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView.cellForItem(at: indexPath)
            else { return nil }

        if let viewModel = viewModel as? UserDetailsViewModel {
            previewingContext.sourceRect = cell.contentView.bounds
            let controller = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
            controller.customizeFor3DTouch(true)
            controller.shotIndex = indexPath.item

            return controller
        } else if let viewModel = viewModel as? TeamDetailsViewModel, collectionView.collectionViewLayout is TwoColumnsCollectionViewFlowLayout {
            previewingContext.sourceRect = cell.contentView.bounds
            return ProfileViewController(user: viewModel.teamMembers[indexPath.item])
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}

// MARK: PeekPopPreviewingDelegate

extension ProfileShotsOrMembersViewController: PeekPopPreviewingDelegate {

    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let collectionView = collectionView,
            let indexPath = collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView.cellForItem(at: indexPath)
            else { return nil }

        if let viewModel = viewModel as? UserDetailsViewModel {
            let controller = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
            controller.customizeFor3DTouch(true)
            controller.shotIndex = indexPath.item
            previewingContext.sourceRect = cell.frame
            return controller
        } else if let viewModel = viewModel as? TeamDetailsViewModel, collectionView.collectionViewLayout is TwoColumnsCollectionViewFlowLayout {
            previewingContext.sourceRect = UIView.extendedFrame(forFrame: cell.frame)
            return ProfileViewController(user: viewModel.teamMembers[indexPath.item])
        }
        return nil
    }

    func previewingContext(_ previewingContext: PreviewingContext, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}
