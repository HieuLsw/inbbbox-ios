//
//  ProfileViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 14/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PromiseKit

class ProfileViewController: TwoLayoutsCollectionViewController {

    private var viewModel: ProfileViewModel!

    private var header: ProfileHeaderView?

    private var indexPathsNeededImageUpdate = [NSIndexPath]()

    var dismissClosure: (() -> Void)?

    var modalTransitionAnimator: ZFModalTransitionAnimator?

    override var containsHeader: Bool {
        return true
    }

    func isDisplayingUser(user: UserType) -> Bool {
        if let userDetailsViewModel = viewModel as? UserDetailsViewModel where userDetailsViewModel.user == user {
            return true
        }
        return false
    }

    private var isModal: Bool {
        return self.tabBarController?.presentingViewController is UITabBarController ||
                self.navigationController?.presentingViewController?.presentedViewController ==
                self.navigationController && (self.navigationController != nil)
    }

    /// Initialize view controller to show user's or team's details.
    ///
    /// - Note: According to Dribbble API - Team is a particular case of User,
    ///         so if you want to show team's details - pass it as `UserType` with `accountType = .Team`.
    ///
    /// - parameter user: User to initialize view controller with.
    convenience init(user: UserType) {

        guard let accountType = user.accountType where accountType == .Team else {
            self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
                      twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)
            viewModel = UserDetailsViewModel(user: user)
            viewModel.delegate = self
            title = viewModel.title
            return
        }

        let team = Team(
            identifier: user.identifier,
            name: user.name ?? "",
            username: user.username,
            avatarURL: user.avatarURL,
            createdAt: NSDate()
        )
        self.init(team: team)
    }

    private convenience init(team: TeamType) {

        self.init(oneColumnLayoutCellHeightToWidthRatio: LargeUserCollectionViewCell.heightToWidthRatio,
                  twoColumnsLayoutCellHeightToWidthRatio: SmallUserCollectionViewCell.heightToWidthRatio)

        viewModel = TeamDetailsViewModel(team: team)
        viewModel.delegate = self
        title = viewModel.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let collectionView = collectionView else { return }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .Cell)
        collectionView.registerClass(SmallUserCollectionViewCell.self, type: .Cell)
        collectionView.registerClass(LargeUserCollectionViewCell.self, type: .Cell)
        collectionView.registerClass(ProfileHeaderView.self, type: .Header)

        do { // hides bottom border of navigationBar
            let currentColorMode = ColorModeProvider.current()
            navigationController?.navigationBar.shadowImage = UIImage(color: currentColorMode.navigationBarTint)
            navigationController?.navigationBar.setBackgroundImage(
				UIImage(color: currentColorMode.navigationBarTint),
                forBarMetrics: .Default
			)
        }

        setupBackButton()
        viewModel.downloadInitialItems()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard viewModel.shouldShowFollowButton else { return }

        firstly {
            viewModel.isProfileFollowedByMe()
        }.then { followed in
            self.header?.userFollowed = followed
        }.then { _ in
            self.header?.stopActivityIndicator()
        }
    }
}

// MARK: Buttons' actions

extension ProfileViewController {

    func didTapFollowButton(_: UIButton) {

        if let userFollowed = header?.userFollowed {

            header?.startActivityIndicator()
            firstly {
                userFollowed ? viewModel.unfollowProfile() : viewModel.followProfile()
            }.then {
                self.header?.userFollowed = !userFollowed
            }.always {
                self.header?.stopActivityIndicator()
            }.error { error in
                FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension ProfileViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if let viewModel = viewModel as? UserDetailsViewModel {
            let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self,
                                                           forIndexPath: indexPath, type: .Cell)

            cell.backgroundColor = ColorModeProvider.current().shotViewCellBackground
            cell.shotImageView.image = nil
            let cellData = viewModel.shotCollectionViewCellViewData(indexPath)

            indexPathsNeededImageUpdate.append(indexPath)
            lazyLoadImage(cellData.shotImage, forCell: cell, atIndexPath: indexPath)

            cell.gifLabel.hidden = !cellData.animated
            if !cell.isRegisteredTo3DTouch {
                cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
            }
            return cell
        }

        if let viewModel = viewModel as? TeamDetailsViewModel {
            let cellData = viewModel.userCollectionViewCellViewData(indexPath)

            indexPathsNeededImageUpdate.append(indexPath)

            if collectionView.collectionViewLayout.isKindOfClass(TwoColumnsCollectionViewFlowLayout) {
                let cell = collectionView.dequeueReusableClass(SmallUserCollectionViewCell.self,
                                                               forIndexPath: indexPath, type: .Cell)
                cell.clearImages()
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
                                                               forIndexPath: indexPath, type: .Cell)
                cell.clearImages()
                cell.avatarView.imageView.loadImageFromURL(cellData.avatarURL)
                cell.nameLabel.text = cellData.name
                cell.numberOfShotsLabel.text = cellData.numberOfShots
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

        return UICollectionViewCell()
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if header == nil && kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableClass(ProfileHeaderView.self, forIndexPath: indexPath,
                    type: .Header)
            header?.avatarView.imageView.loadImageFromURL(viewModel.avatarURL)
            header?.button.addTarget(self, action: #selector(didTapFollowButton(_:)), forControlEvents: .TouchUpInside)
            viewModel.shouldShowFollowButton ? header?.startActivityIndicator() : (header?.shouldShowButton = false)
        }

        return header!
    }
}

// MARK: UICollectionViewDelegate

extension ProfileViewController {

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if let viewModel = viewModel as? UserDetailsViewModel {

            let detailsViewController = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
            detailsViewController.shotIndex = indexPath.item
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.userShots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            
            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .Custom

            presentViewController(pageViewController, animated: true, completion: nil)
        }
        if let viewModel = viewModel as? TeamDetailsViewModel {

            let profileViewController = ProfileViewController(user: viewModel.teamMembers[indexPath.item])
            profileViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }

    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell,
                        forItemAtIndexPath indexPath: NSIndexPath) {
        if let index = indexPathsNeededImageUpdate.indexOf(indexPath) {
            indexPathsNeededImageUpdate.removeAtIndex(index)
        }
    }
}

// MARK: BaseCollectionViewViewModelDelegate

extension ProfileViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(error: ErrorType) {
        collectionView?.reloadData()

        if viewModel.collectionIsEmpty {
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

// MARK: Private extension

private extension ProfileViewController {

    func lazyLoadImage(shotImage: ShotImageType, forCell cell: SimpleShotCollectionViewCell,
                       atIndexPath indexPath: NSIndexPath) {
        let imageLoadingCompletion: UIImage -> Void = { [weak self] image in

            guard let certainSelf = self where certainSelf.indexPathsNeededImageUpdate.contains(indexPath) else {
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

    func setupBackButton() {
        if isModal {
            let attributedString = NSMutableAttributedString(
                string: NSLocalizedString("Profile.BackButton",
                comment: "Back button, user details"),
                attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            let textAttachment = NSTextAttachment()
            if let image = UIImage(named: "ic-back") {
                textAttachment.image = image
                textAttachment.bounds = CGRect(x: 0, y: -3, width: image.size.width, height: image.size.height)
            }
            let attributedStringWithImage = NSAttributedString(attachment: textAttachment)
            attributedString.replaceCharactersInRange(NSRange(location: 0, length: 0),
                                                      withAttributedString: attributedStringWithImage)

            let backButton = UIButton()
            backButton.setAttributedTitle(attributedString, forState: .Normal)
            backButton.addTarget(self, action: #selector(didTapLeftBarButtonItem), forControlEvents: .TouchUpInside)
            backButton.sizeToFit()

            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }

    dynamic func didTapLeftBarButtonItem() {
        dismissClosure?()
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension ProfileViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItemAtPoint(previewingContext.sourceView.convertPoint(location, toView: collectionView)) else { return nil }
        
        if let viewModel = viewModel as? UserDetailsViewModel {
            guard let cell = collectionView?.cellForItemAtIndexPath(indexPath) else { return nil }
            
            previewingContext.sourceRect = cell.contentView.bounds
            
            let controller = ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))
            controller.customizeFor3DTouch(true)
            controller.shotIndex = indexPath.item
            
            return controller
        } else if let viewModel = viewModel as? TeamDetailsViewModel {
            if let collectionView = collectionView where
                collectionView.collectionViewLayout.isKindOfClass(TwoColumnsCollectionViewFlowLayout) {
                guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return nil }
                previewingContext.sourceRect = cell.contentView.bounds
            } else {
                guard let cell = collectionView?.cellForItemAtIndexPath(indexPath) else { return nil }
                previewingContext.sourceRect = cell.contentView.bounds
            }
            
            return ProfileViewController(user: viewModel.teamMembers[indexPath.item])
        }
        
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        if let viewModel = viewModel as? UserDetailsViewModel,
            let detailsViewController = viewControllerToCommit as? ShotDetailsViewController {
            detailsViewController.customizeFor3DTouch(false)
            let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: viewModel.userShots, initialViewController: detailsViewController)
            let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
            modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
            modalTransitionAnimator?.behindViewScale = 1
            
            pageViewController.transitioningDelegate = modalTransitionAnimator
            pageViewController.modalPresentationStyle = .Custom
            
            presentViewController(pageViewController, animated: true, completion: nil)
        } else if (viewModel as? TeamDetailsViewModel) != nil {
            navigationController?.pushViewController(viewControllerToCommit, animated: true)
        }
    }
}
