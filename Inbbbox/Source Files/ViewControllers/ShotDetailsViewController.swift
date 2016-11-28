//
//  ShotDetailsViewController.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import ZFDragableModalTransition
import ImageViewer
import MessageUI

final class ShotDetailsViewController: UIViewController {

    var shouldScrollToMostRecentMessage = false
    var shouldShowKeyboardAtStart = false
    var shotIndex = 0

    var shotDetailsView: ShotDetailsView! {
        return view as? ShotDetailsView
    }

    let viewModel: ShotDetailsViewModel

    private(set) var header: ShotDetailsHeaderView?
    private var footer: ShotDetailsFooterView?
    private(set) var scroller = ScrollViewAutoScroller()
    private(set) var operationalCell: ShotDetailsOperationCollectionViewCell?
    private var onceTokenForShouldScrollToMessagesOnOpen = dispatch_once_t(0)
    private var modalTransitionAnimator: ZFModalTransitionAnimator?
    
    var willDismissDetailsCompletionHandler: (Int -> Void)?
    var updatedShotInfo: ((ShotType) -> ())?

    /// Initialize ShotDetailsViewController.
    ///
    /// - parameter shot:   Shot to display.
    /// - parameter isLked: Nil if status unknown, ViewModel will fetch it.
    init(shot: ShotType, isLiked: Bool? = nil) {
        self.viewModel = ShotDetailsViewModel(shot: shot, isLiked: isLiked)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message = "Use init(shot:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable, message = "Use init(shot:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ShotDetailsView(frame: CGRect.zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scroller.scrollView = shotDetailsView.collectionView

        shotDetailsView.topLayoutGuideOffset = UIApplication.sharedApplication().statusBarFrame.size.height
        shotDetailsView.collectionView.delegate = self
        shotDetailsView.collectionView.dataSource = self
        shotDetailsView.collectionView.registerClass(ShotDetailsCommentCollectionViewCell.self, type: .Cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsOperationCollectionViewCell.self, type: .Cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsDescriptionCollectionViewCell.self, type: .Cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsDummySpaceCollectionViewCell.self, type: .Cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsFooterView.self, type: .Footer)
        shotDetailsView.collectionView.registerClass(ShotDetailsHeaderView.self, type: .Header)
        shotDetailsView.commentComposerView.delegate = self
        shotDetailsView.keyboardResizableView.delegate = self
        shotDetailsView.shouldShowCommentComposerView = viewModel.isCommentingAvailable

        firstly {
            viewModel.loadAttachments()
        }.then {
            self.header?.setNeedsDisplay()
            return self.viewModel.loadAllComments()
        }.then { () -> Void in
            self.grayOutFooterIfNeeded()
            self.shotDetailsView.collectionView.reloadData()
            self.scroller.scrollToBottomAnimated(true)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = shotDetailsView.collectionView.collectionViewLayout as?
                ShotDetailsCollectionCollapsableHeader {
            layout.collapsableHeight = heightForCollapsedCollectionViewHeader
            layout.invalidateLayout()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        dispatch_once(&onceTokenForShouldScrollToMessagesOnOpen) {
            if self.shouldScrollToMostRecentMessage {
                self.viewModel.isCommentingAvailable ? self.shotDetailsView.commentComposerView.makeActive() :
                        self.scroller.scrollToBottomAnimated(true)
            }
            if self.shouldShowKeyboardAtStart && self.viewModel.isCommentingAvailable {
                AsyncWrapper().main {
                    self.shotDetailsView.commentComposerView.textField.becomeFirstResponder()
                }
            }
        }

        AnalyticsManager.trackScreen(.ShotDetailsView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        willDismissDetailsCompletionHandler?(shotIndex)
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if fabs(velocity.y) > 2.0 { //2.0 is considered fast scroll which means user intends to dismiss the keyboard
            view.endEditing(true)
        }
    }
}

// MARK: UICollectionViewDataSource

extension ShotDetailsViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if viewModel.isShotOperationIndex(indexPath.row) {
            let cell = collectionView.dequeueReusableClass(ShotDetailsOperationCollectionViewCell.self,
                    forIndexPath: indexPath, type: .Cell)
            operationalCell = cell

            let likeSelectableView = cell.operationView.likeSelectableView
            let bucketSelectableView = cell.operationView.bucketSelectableView

            likeSelectableView.tapHandler = { [weak self] in
                self?.likeSelectableViewDidTap(likeSelectableView)
            }

            bucketSelectableView.tapHandler = { [weak self] in
                self?.bucketSelectableViewDidTap(bucketSelectableView)
            }

            setLikeStateInSelectableView(likeSelectableView)
            setBucketStatusInSelectableView(bucketSelectableView)

            setLikesCountForLabel(cell.operationView.likeCounterLabel)
            setBucketsCountForLabel(cell.operationView.bucketCounterLabel)

            return cell

        } else if viewModel.isDescriptionIndex(indexPath.row) {
            let cell = collectionView.dequeueReusableClass(ShotDetailsDescriptionCollectionViewCell.self,
                    forIndexPath: indexPath, type: .Cell)

            if let description = viewModel.attributedShotDescription {
                cell.setDescriptionLabelAttributedText(description)
            }
            cell.delegate = self

            return cell

        } else if viewModel.shouldDisplaySeparatorAtIndex(indexPath.row) {
            return collectionView.dequeueReusableClass(ShotDetailsDummySpaceCollectionViewCell.self,
                    forIndexPath: indexPath, type: .Cell)

        } else {
            let cell = collectionView.dequeueReusableClass(ShotDetailsCommentCollectionViewCell.self,
                    forIndexPath: indexPath, type: .Cell)

            let data = viewModel.displayableDataForCommentAtIndex(indexPath.row)
            cell.likedByMe = data.likedByMe
            cell.authorLabel.setText(data.author)
            if let comment = data.comment {
                cell.setCommentLabelAttributedText(comment)
            }
            let user = viewModel.userForCommentAtIndex(indexPath.row)
            if let url = viewModel.urlForUser(user) {
                cell.setLinkInAuthorLabel(url, delegate: self)
            }
            cell.dateLabel.attributedText = data.date
            cell.avatarView.imageView.loadImageFromURL(data.avatarURL,
                                                    placeholderImage: UIImage(named: "ic-comments-nopicture"))
            cell.likesCountLabel.attributedText = data.likesCount
            cell.deleteActionHandler = { [weak self] in
                self?.deleteComment(atIndexPath: indexPath)
            }
            cell.reportActionHandler = { [weak self] in
                self?.reportComment(atIndexPath: indexPath)
            }
            cell.likeActionHandler = { [weak self] in
                self?.likeComment(atIndexPath: indexPath)
            }
            cell.unlikeActionHandler = { [weak self] in
                self?.unlikeComment(atIndexPath: indexPath)
            }
            cell.avatarView.delegate = self
            cell.delegate = self

            return cell
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionFooter {

            footer = collectionView.dequeueReusableClass(ShotDetailsFooterView.self, forIndexPath: indexPath,
                    type: .Footer)
            viewModel.isFetchingComments ? footer?.startAnimating() : footer?.stopAnimating()
            grayOutFooterIfNeeded()

            return footer!
        }

        if kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableClass(ShotDetailsHeaderView.self, forIndexPath: indexPath,
                    type: .Header)
            if viewModel.shot.animated {
                if let url = viewModel.shot.shotImage.hidpiURL {
                    header?.setAnimatedImageWithUrl(url)
                } else {
                    header?.setAnimatedImageWithUrl(viewModel.shot.shotImage.normalURL)
                }
            } else {
                header?.setImageWithShotImage(viewModel.shot.shotImage)
            }

            header?.maxHeight = sizeForExpandedCollectionViewHeader(collectionView).height
            header?.minHeight = heightForCollapsedCollectionViewHeader

            header?.setAttributedTitle(viewModel.attributedShotTitleForHeader)
            if let url = viewModel.urlForUser(viewModel.shot.user) {
                header?.setLinkInTitle(url, range: viewModel.userLinkRange, delegate: self)
            }
            if let team = viewModel.shot.team, url = viewModel.urlForTeam(team) {
                header?.setLinkInTitle(url, range: viewModel.teamLinkRange, delegate: self)
            }
            let placeholderAvatar = UIImage(named: "ic-author-mugshot-nopicture")
            header?.avatarView.imageView.loadImageFromURL(viewModel.shot.user.avatarURL,
                                                          placeholderImage: placeholderAvatar)
            header?.closeButtonView.closeButton.addTarget(self, action: #selector(closeButtonDidTap(_:)),
            forControlEvents: .TouchUpInside)
            header?.avatarView.delegate = self

            header?.imageDidTap = { [weak self] in
                self?.presentShotFullscreen()
            }
            
            header?.showAttachments = viewModel.shot.attachmentsCount != 0
            header?.attachments = viewModel.attachments
            header?.attachmentDidTap = { [weak self] cell, attachment in
                self?.header?.selectedAttachment = attachment
                self?.presentFullScreenAttachment(cell)
            }
        }

        return header!
    }
}

// MARK: UICollectionViewDelegate

extension ShotDetailsViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShotDetailsCommentCollectionViewCell {
            hideUnusedCommentEditingViews()
            let isOwner = viewModel.isCurrentUserOwnerOfCommentAtIndex(indexPath.row)
            cell.showEditView(true, forActionType: isOwner ? EditActionType.Editing : .Reporting)
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        if viewModel.isShotOperationIndex(indexPath.row) {
            return collectionView.sizeForAutoSizingCell(ShotDetailsOperationCollectionViewCell.self, textToBound: nil)

        } else if viewModel.isDescriptionIndex(indexPath.row) {
            let text = viewModel.attributedShotDescription
            return collectionView.sizeForAutoSizingCell(ShotDetailsDescriptionCollectionViewCell.self,
                    textToBound: [text])

        } else if viewModel.shouldDisplaySeparatorAtIndex(indexPath.row) {
            return collectionView.sizeForAutoSizingCell(ShotDetailsDummySpaceCollectionViewCell.self, textToBound: nil)

        } else {
            let data = viewModel.displayableDataForCommentAtIndex(indexPath.row)
            let text = [data.author, data.comment, data.date]
            return collectionView.sizeForAutoSizingCell(ShotDetailsCommentCollectionViewCell.self, textToBound: text)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension ShotDetailsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sizeForExpandedCollectionViewHeader(collectionView)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat = viewModel.isFetchingComments ? 64 : ShotDetailsFooterView.minimumRequiredHeight
        return CGSize(width: CGRectGetWidth(collectionView.frame), height: height)
    }
}

// MARK: Public extension

extension ShotDetailsViewController {

    func animateHeader(start start: Bool) {
        start ? header?.imageView.startAnimating() : header?.imageView.stopAnimating()
    }

    func hideUnusedCommentEditingViews() {
        shotDetailsView.collectionView.visibleCells().forEach {
            if let commentCell = $0 as? ShotDetailsCommentCollectionViewCell {
                commentCell.showEditView(false)
            }
        }
    }

    func presentProfileViewControllerForUser(user: UserType) {

        if let profileController = (self.presentingViewController as? UINavigationController)?.topViewController
                    as? ProfileViewController where profileController.isDisplayingUser(user) {
            animateHeader(start: false)
            dismissViewControllerAnimated(true, completion: nil)
            return
        }

        let profileViewController = ProfileViewController(user: user)
        let navigationController = UINavigationController(rootViewController: profileViewController)

        animateHeader(start: false)
        profileViewController.dismissClosure = { [weak self] in
            self?.animateHeader(start: true)
        }
        presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func customizeFor3DTouch(hidden: Bool) {
        shotDetailsView.customizeFor3DTouch(hidden)
    }
}

// MARK: Private extension

private extension ShotDetailsViewController {

    func refreshWithShot(shot: ShotType) {
    
        if let operationalCell = self.operationalCell {
            operationalCell.operationView.likeCounterLabel.text = "\(shot.likesCount)"
            operationalCell.operationView.bucketCounterLabel.text = "\(shot.bucketsCount)"
        }
        self.updatedShotInfo?(shot)
    }

    func refreshLikesBucketsCounter() {

        firstly {
            self.viewModel.checkDetailOfShot()
        }.then { shot in
            self.refreshWithShot(shot)
        }
    }

    func setLikeStateInSelectableView(view: ActivityIndicatorSelectableView) {
        handleSelectableViewStatus(view) {
            self.viewModel.checkLikeStatusOfShot()
        }
    }

    func setBucketStatusInSelectableView(view: ActivityIndicatorSelectableView) {
        handleSelectableViewStatus(view) {
            self.viewModel.checkShotAffiliationToUserBuckets()
        }
    }
    
    func setLikesCountForLabel(label: UILabel) {
        label.text = "\(viewModel.shot.likesCount)"
    }

    func setBucketsCountForLabel(label: UILabel) {
        label.text = "\(viewModel.shot.bucketsCount)"
    }

    func handleSelectableViewStatus(view: ActivityIndicatorSelectableView, withAction action: (() -> Promise<Bool>)) {

        view.startAnimating()

        firstly {
            action()
        }.then { selected in
            view.selected = selected
        }.always {
            view.stopAnimating()
        }
    }

    func likeSelectableViewDidTap(view: ActivityIndicatorSelectableView) {
        
        view.startAnimating()

        firstly {
            viewModel.performLikeOperation()
        }.then { isShotLikedByUser in
            view.selected = isShotLikedByUser
        }.always {
            self.refreshLikesBucketsCounter()
            view.stopAnimating()
        }
    }

    func bucketSelectableViewDidTap(view: ActivityIndicatorSelectableView) {

        view.startAnimating()

        firstly {
            viewModel.removeShotFromBucketIfExistsInExactlyOneBucket()
        }.then { result -> Void in
            if let bucketNumber = result.bucketsNumber where !result.removed {
                let mode: ShotBucketsViewControllerMode = bucketNumber == 0 ? .AddToBucket : .RemoveFromBucket
                self.presentShotBucketsViewControllerWithMode(mode, onModalCompletion: {
                    self.refreshLikesBucketsCounter()
                })
            } else {
                self.refreshLikesBucketsCounter()
                view.selected = false
            }
        }.always {
            view.stopAnimating()
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketProcessingFailed, canBeDismissedByUser: true)
        }
    }

    var heightForCollapsedCollectionViewHeader: CGFloat {

        let margin = CGFloat(20)
        let maxWidth = abs((shotDetailsView.collectionView.frame.size.width ?? 0) -
                (header?.availableWidthForTitle ?? 0))
        let height = viewModel.attributedShotTitleForHeader.boundingHeightUsingAvailableWidth(maxWidth) + 2 * margin

        return max(70, height)
    }

    func sizeForExpandedCollectionViewHeader(collectionView: UICollectionView) -> CGSize {
        let dribbbleImageRatio = CGFloat(0.75)
        return CGSize(
            width: floor(collectionView.bounds.width),
            height: ceil(collectionView.bounds.width * dribbbleImageRatio + heightForCollapsedCollectionViewHeader) + viewModel.attachmentContainerHeight()
        )
    }

    func deleteComment(atIndexPath indexPath: NSIndexPath) {
        let isAllowedToDisplaySeparator = viewModel.isAllowedToDisplaySeparator
        firstly {
            viewModel.deleteCommentAtIndex(indexPath.item)
        }.then { () -> Void in
            var indexPaths = [indexPath]
            if isAllowedToDisplaySeparator != self.viewModel.isAllowedToDisplaySeparator {
                indexPaths.append(NSIndexPath(forItem: indexPath.item - 1, inSection: 0))
            }
            self.shotDetailsView.collectionView.deleteItemsAtIndexPaths(indexPaths)
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.deleteCommentFailed, canBeDismissedByUser: true)
        }
    }

    func reportComment(atIndexPath indexPath: NSIndexPath) {

        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController.emailAccountNotFound()
            presentViewController(alert, animated: true, completion: nil)
            return
        }

        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self

        composer.setToRecipients([Dribbble.ReportInappropriateContentEmail])
        let subject = NSLocalizedString("ShotDetailsViewController.Inappropriate",
                                        comment: "Title of email with abusive content.")
        composer.setSubject(subject)
        let body = viewModel.reportBodyForAbusiveComment(indexPath)
        composer.setMessageBody(body, isHTML: false)

        presentViewController(composer, animated: true, completion: nil)
        composer.navigationBar.tintColor = .whiteColor()
    }

    func likeComment(atIndexPath indexPath: NSIndexPath) {
        firstly {
            viewModel.performLikeOperationForComment(atIndexPath: indexPath)
        }.then {
            self.viewModel.checkLikeStatusForComment(atIndexPath: indexPath, force: true)
        }.then { isLiked -> Void in
            self.viewModel.setLikeStatusForComment(atIndexPath: indexPath, withValue: isLiked)
            self.shotDetailsView.collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }

    func unlikeComment(atIndexPath indexPath: NSIndexPath) {
        firstly {
            viewModel.performUnlikeOperationForComment(atIndexPath: indexPath)
        }.then {
            self.viewModel.checkLikeStatusForComment(atIndexPath: indexPath, force: true)
        }.then { isLiked -> Void in
            self.viewModel.setLikeStatusForComment(atIndexPath: indexPath, withValue: isLiked)
            self.shotDetailsView.collectionView.reloadItemsAtIndexPaths([indexPath])
        }
    }

    func presentShotBucketsViewControllerWithMode(mode: ShotBucketsViewControllerMode, onModalCompletion completion:(() -> Void)? = nil) {

        shotDetailsView.commentComposerView.makeInactive()

        let shotBucketsViewController = ShotBucketsViewController(shot: viewModel.shot, mode: mode)
        animateHeader(start: false)
        shotBucketsViewController.willDismissViewControllerClosure = { [weak self] in
            self?.animateHeader(start: true)
            self?.viewModel.clearBucketsData()
            self?.shotDetailsView.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            completion?()
        }

        modalTransitionAnimator =
                CustomTransitions.pullDownToCloseTransitionForModalViewController(shotBucketsViewController)
        shotBucketsViewController.transitioningDelegate = modalTransitionAnimator
        shotBucketsViewController.modalPresentationStyle = .Custom
        presentViewController(shotBucketsViewController, animated: true, completion: nil)
    }

    func presentShotFullscreen() {

        guard let header = header else { return }

        var imageViewer: ImageViewer {
            if viewModel.shot.animated {
                let url = viewModel.shot.shotImage.hidpiURL ?? viewModel.shot.shotImage.normalURL
                return ImageViewer(imageProvider: self, displacedView: header.imageView, animatedUrl: url)
            } else {
                return ImageViewer(imageProvider: self, displacedView: header.imageView)
            }
        }

        presentImageViewer(imageViewer)
    }
    
    func presentFullScreenAttachment(displacedView: UIView) {
        /* 
         To prevent glitchy animation we are adding placeholder view
         from where animation will start but without showing thumbnail 
         image in show animation.
         */
        let view = UIView(frame: displacedView.frame)
        view.backgroundColor = .clearColor()
        displacedView.superview?.addSubview(view)
        let imageViewer = ImageViewer(imageProvider: header!, displacedView: view)
        imageViewer.dismissCompletionBlock = {
            view.removeFromSuperview()
        }
        presentImageViewer(imageViewer)
    }

    func grayOutFooterIfNeeded() {
        let shouldGrayOut = !viewModel.hasComments && !viewModel.hasDescription
        footer?.grayOutBackground(shouldGrayOut)
    }

    dynamic func closeButtonDidTap(_: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
