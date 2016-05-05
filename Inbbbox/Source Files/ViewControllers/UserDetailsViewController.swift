//
//  UserDetailsViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 14/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PromiseKit

class UserDetailsViewController: TwoLayoutsCollectionViewController {

    private var viewModel: UserDetailsViewModel!

    private var header: UserDetailsHeaderView?

    private var indexPathsNeededImageUpdate = [NSIndexPath]()

    var dismissClosure: (() -> Void)?

    var modalTransitionAnimator: ZFModalTransitionAnimator?

    override var containsHeader: Bool {
        return true
    }

    private var isModal: Bool {
        return self.presentingViewController?.presentedViewController == self ||
                self.tabBarController?.presentingViewController is UITabBarController ||
                self.navigationController?.presentingViewController?.presentedViewController ==
                self.navigationController && (self.navigationController != nil)
    }
}

extension UserDetailsViewController {
    convenience init(user: UserType) {

        self.init(oneColumnLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio,
            twoColumnsLayoutCellHeightToWidthRatio: SimpleShotCollectionViewCell.heightToWidthRatio)

        viewModel = UserDetailsViewModel(user: user)
        viewModel.delegate = self
        title = viewModel.user.name ?? viewModel.user.username
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let collectionView = collectionView else { return }

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerClass(SimpleShotCollectionViewCell.self, type: .Cell)
        collectionView.registerClass(UserDetailsHeaderView.self, type: .Header)

        do {
            // hides bottom border of navigationBar
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        }

        setupBackButton()

        viewModel.downloadInitialItems()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        guard viewModel.shouldShowFollowButton else {
            return
        }

        firstly {
            viewModel.isUserFollowedByMe()
        }.then {
            followed in
            self.header?.userFollowed = followed
        }.always {
            self.header?.stopActivityIndicator()
        }.error {
            error in
            // NGRTodo: provide pop-ups with errors
        }
    }
}

// MARK: Buttons' actions

extension UserDetailsViewController {

    func didTapFollowButton(_: UIButton) {

        if let userFollowed = header?.userFollowed {

            header?.startActivityIndicator()
            firstly {
                userFollowed ? viewModel.unfollowUser() : viewModel.followUser()
            }.then {
                self.header?.userFollowed = !userFollowed
            }.always {
                self.header?.stopActivityIndicator()
            }.error {
                error in
                // NGRTodo: provide pop-ups with errors
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension UserDetailsViewController {

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableClass(SimpleShotCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)
        cell.shotImageView.image = nil
        let cellData = viewModel.shotCollectionViewCellViewData(indexPath)

        indexPathsNeededImageUpdate.append(indexPath)
        lazyLoadImage(cellData.shotImage, forCell: cell, atIndexPath: indexPath)

        cell.gifLabel.hidden = !cellData.animated
        return cell
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if header == nil && kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableClass(UserDetailsHeaderView.self, forIndexPath: indexPath,
                    type: .Header)
            header?.avatarView.imageView.loadImageFromURL(viewModel.user.avatarURL)
            header?.button.addTarget(self, action: #selector(didTapFollowButton(_:)), forControlEvents: .TouchUpInside)
            viewModel.shouldShowFollowButton ? header?.startActivityIndicator() : (header?.shouldShowButton = false)
        }

        return header!
    }
}

// MARK: UICollectionViewDelegate

extension UserDetailsViewController {

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let shotDetailsViewController =
                ShotDetailsViewController(shot: viewModel.shotWithSwappedUser(viewModel.userShots[indexPath.item]))

        modalTransitionAnimator =
                CustomTransitions.pullDownToCloseTransitionForModalViewController(shotDetailsViewController)

        shotDetailsViewController.transitioningDelegate = modalTransitionAnimator
        shotDetailsViewController.modalPresentationStyle = .Custom

        presentViewController(shotDetailsViewController, animated: true, completion: nil)
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

extension UserDetailsViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(error: ErrorType) {
        collectionView?.reloadData()

        if viewModel.userShots.isEmpty {
            let alert = UIAlertController.generalErrorAlertController()
            presentViewController(alert, animated: true, completion: nil)
            alert.view.tintColor = .pinkColor()
        }
    }

    func viewModel(viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        collectionView?.insertItemsAtIndexPaths(indexPaths)
    }

    func viewModel(viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: NSIndexPath) {
        collectionView?.reloadItemsAtIndexPaths([indexPath])
    }
}

// MARK: Private extension

private extension UserDetailsViewController {

    func lazyLoadImage(shotImage: ShotImageType, forCell cell: SimpleShotCollectionViewCell,
                       atIndexPath indexPath: NSIndexPath) {
        let imageLoadingCompletion: UIImage -> Void = {
            [weak self] image in

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
                string: NSLocalizedString("UserDetails.BackButton",
                comment: "Back button, user details"),
                attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(named: "ic-back")
            textAttachment.bounds = CGRect(x: 0, y: -3,
                                    width: textAttachment.image!.size.width, height: textAttachment.image!.size.height)
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
