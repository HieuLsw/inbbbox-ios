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

    private lazy var __once: () = {
            if self.shouldScrollToMostRecentMessage {
                self.viewModel.isCommentingAvailable ? self.shotDetailsView.commentComposerView.makeActive() :
                        self.scroller.scrollToBottomAnimated(true)
            }
            if self.shouldShowKeyboardAtStart && self.viewModel.isCommentingAvailable {
                AsyncWrapper().main {
                    self.shotDetailsView.commentComposerView.textField.becomeFirstResponder()
                }
            }
        }()

    var shouldScrollToMostRecentMessage = false
    var shouldShowKeyboardAtStart = false
    var shotIndex = 0

    var shotDetailsView: ShotDetailsView! {
        return view as? ShotDetailsView
    }

    let viewModel: ShotDetailsViewModel

    fileprivate(set) var header: ShotDetailsHeaderView?
    fileprivate var footer: ShotDetailsFooterView?
    fileprivate(set) var scroller = ScrollViewAutoScroller()
    fileprivate(set) var operationalCell: ShotDetailsOperationCollectionViewCell?
    fileprivate var onceTokenForShouldScrollToMessagesOnOpen = Int(0)
    fileprivate var modalTransitionAnimator: ZFModalTransitionAnimator?
    
    var willDismissDetailsCompletionHandler: ((Int) -> Void)?
    var updatedShotInfo: ((ShotType) -> ())?

    /// Initialize ShotDetailsViewController.
    ///
    /// - parameter shot:   Shot to display.
    /// - parameter isLked: Nil if status unknown, ViewModel will fetch it.
    init(shot: ShotType, isLiked: Bool? = nil) {
        self.viewModel = ShotDetailsViewModel(shot: shot, isLiked: isLiked)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init(shot:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(shot:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = ShotDetailsView(frame: CGRect.zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scroller.scrollView = shotDetailsView.collectionView

        shotDetailsView.topLayoutGuideOffset = UIApplication.shared.statusBarFrame.size.height
        shotDetailsView.collectionView.delegate = self
        shotDetailsView.collectionView.dataSource = self
        shotDetailsView.collectionView.registerClass(ShotDetailsCommentCollectionViewCell.self, type: .cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsOperationCollectionViewCell.self, type: .cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsDescriptionCollectionViewCell.self, type: .cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsDummySpaceCollectionViewCell.self, type: .cell)
        shotDetailsView.collectionView.registerClass(ShotDetailsFooterView.self, type: .footer)
        shotDetailsView.collectionView.registerClass(ShotDetailsHeaderView.self, type: .header)
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
        }.catch { _ in }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = shotDetailsView.collectionView.collectionViewLayout as?
                ShotDetailsCollectionCollapsableHeader {
            layout.collapsableHeight = heightForCollapsedCollectionViewHeader
            layout.invalidateLayout()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _ = self.__once

        AnalyticsManager.trackScreen(.shotDetailsView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        header?.cancelAllAnimatedImageSettings()
        willDismissDetailsCompletionHandler?(shotIndex)
        shotDetailsView?.hideKeyboard()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if fabs(velocity.y) > 2.0 { //2.0 is considered fast scroll which means user intends to dismiss the keyboard
            view.endEditing(true)
        }
    }
}

// MARK: UICollectionViewDataSource

extension ShotDetailsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if viewModel.isShotOperationIndex(indexPath.row) {
            let cell = collectionView.dequeueReusableClass(ShotDetailsOperationCollectionViewCell.self,
                    forIndexPath: indexPath, type: .cell)
            operationalCell = cell

            let likeSelectableView = cell.operationView.likeSelectableView
            let bucketSelectableView = cell.operationView.bucketSelectableView
            let shareButton = cell.operationView.shareButton
			
            likeSelectableView.tapHandler = { [weak self] in
                self?.likeSelectableViewDidTap(likeSelectableView)
            }

            bucketSelectableView.tapHandler = { [weak self] in
                self?.bucketSelectableViewDidTap(bucketSelectableView)
            }
			
            shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)

            setLikeStateInSelectableView(likeSelectableView)
            setBucketStatusInSelectableView(bucketSelectableView)

            setLikesCountForLabel(cell.operationView.likeCounterLabel)
            setBucketsCountForLabel(cell.operationView.bucketCounterLabel)

            return cell

        } else if viewModel.isDescriptionIndex(indexPath.row) {
            let cell = collectionView.dequeueReusableClass(ShotDetailsDescriptionCollectionViewCell.self,
                    forIndexPath: indexPath, type: .cell)

            if let description = viewModel.attributedShotDescription {
                cell.setDescriptionLabelAttributedText(description)
            }
            cell.delegate = self

            return cell

        } else if viewModel.shouldDisplaySeparatorAtIndex(indexPath.row) {
            return collectionView.dequeueReusableClass(ShotDetailsDummySpaceCollectionViewCell.self,
                    forIndexPath: indexPath, type: .cell)

        } else {
            let cell = collectionView.dequeueReusableClass(ShotDetailsCommentCollectionViewCell.self,
                    forIndexPath: indexPath, type: .cell)

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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionFooter {

            footer = collectionView.dequeueReusableClass(ShotDetailsFooterView.self, forIndexPath: indexPath,
                    type: .footer)
            viewModel.isFetchingComments ? footer?.startAnimating() : footer?.stopAnimating()
            grayOutFooterIfNeeded()

            return footer!
        }

        if kind == UICollectionElementKindSectionHeader {
            header = collectionView.dequeueReusableClass(ShotDetailsHeaderView.self, forIndexPath: indexPath,
                    type: .header)
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
            if let team = viewModel.shot.team, let url = viewModel.urlForTeam(team) {
                header?.setLinkInTitle(url, range: viewModel.teamLinkRange, delegate: self)
            }
            let placeholderAvatar = UIImage(named: "ic-author-mugshot-nopicture")
            header?.avatarView.imageView.loadImageFromURL(viewModel.shot.user.avatarURL,
                                                          placeholderImage: placeholderAvatar)
            header?.closeButtonView.closeButton.addTarget(self, action: #selector(closeButtonDidTap(_:)),
            for: .touchUpInside)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ShotDetailsCommentCollectionViewCell {
            hideUnusedCommentEditingViews()
            let isOwner = viewModel.isCurrentUserOwnerOfCommentAtIndex(indexPath.row)
            cell.showEditView(true, forActionType: isOwner ? EditActionType.editing : .reporting)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sizeForExpandedCollectionViewHeader(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        let height: CGFloat = viewModel.isFetchingComments ? 64 : ShotDetailsFooterView.minimumRequiredHeight
        return CGSize(width: collectionView.frame.width, height: height)
    }
}

// MARK: Public extension

extension ShotDetailsViewController {

    func animateHeader(start: Bool) {
        start ? header?.imageView.startAnimating() : header?.imageView.stopAnimating()
    }

    func hideUnusedCommentEditingViews() {
        shotDetailsView.collectionView.visibleCells.forEach {
            if let commentCell = $0 as? ShotDetailsCommentCollectionViewCell {
                commentCell.showEditView(false)
            }
        }
    }

    func presentProfileViewControllerForUser(_ user: UserType) {

        if let profileController = (self.presentingViewController as? UINavigationController)?.topViewController
                    as? ProfileViewController, profileController.isDisplayingUser(user) {
            animateHeader(start: false)
            dismiss(animated: true, completion: nil)
            return
        }

        let profileViewController = ProfileViewController(user: user)
        let navigationController = UINavigationController(rootViewController: profileViewController)

        animateHeader(start: false)
        profileViewController.dismissClosure = { [weak self] in
            self?.animateHeader(start: true)
        }
        present(navigationController, animated: true, completion: nil)
    }
    
    func customizeFor3DTouch(_ hidden: Bool) {
        shotDetailsView.customizeFor3DTouch(hidden)
    }
}

// MARK: Private extension

private extension ShotDetailsViewController {

    func refreshWithShot(_ shot: ShotType) {
    
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
        }.catch { _ in }
    }

    func setLikeStateInSelectableView(_ view: ActivityIndicatorSelectableView) {
        handleSelectableViewStatus(view) {
            self.viewModel.checkLikeStatusOfShot()
        }
    }

    func setBucketStatusInSelectableView(_ view: ActivityIndicatorSelectableView) {
        handleSelectableViewStatus(view) {
            self.viewModel.checkShotAffiliationToUserBuckets()
        }
    }
    
    func setLikesCountForLabel(_ label: UILabel) {
        label.text = "\(viewModel.shot.likesCount)"
    }

    func setBucketsCountForLabel(_ label: UILabel) {
        label.text = "\(viewModel.shot.bucketsCount)"
    }

    func handleSelectableViewStatus(_ view: ActivityIndicatorSelectableView, withAction action: (() -> Promise<Bool>)) {

        view.startAnimating()

        firstly {
            action()
        }.then { selected in
            view.selected = selected
        }.always {
            view.stopAnimating()
        }.catch { _ in }
    }

    func likeSelectableViewDidTap(_ view: ActivityIndicatorSelectableView) {
        
        view.startAnimating()

        firstly {
            viewModel.performLikeOperation()
        }.then { isShotLikedByUser in
            view.selected = isShotLikedByUser
        }.always {
            self.refreshLikesBucketsCounter()
            view.stopAnimating()
        }.catch { _ in }
    }

    func bucketSelectableViewDidTap(_ view: ActivityIndicatorSelectableView) {

        view.startAnimating()

        firstly {
            viewModel.removeShotFromBucketIfExistsInExactlyOneBucket()
        }.then { result -> Void in
            if let bucketNumber = result.bucketsNumber, !result.removed {
                let mode: ShotBucketsViewControllerMode = bucketNumber == 0 ? .addToBucket : .removeFromBucket
                self.presentShotBucketsViewControllerWithMode(mode, onModalCompletion: {
                    self.refreshLikesBucketsCounter()
                })
            } else {
                self.refreshLikesBucketsCounter()
                view.selected = false
            }
        }.always {
            view.stopAnimating()
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketProcessingFailed, canBeDismissedByUser: true)
        }
    }

    var heightForCollapsedCollectionViewHeader: CGFloat {

        let margin = CGFloat(20)
        let maxWidth = abs((shotDetailsView.collectionView.frame.size.width) -
                (header?.availableWidthForTitle ?? 0))
        let height = viewModel.attributedShotTitleForHeader.boundingHeightUsingAvailableWidth(maxWidth) + 2 * margin

        return max(70, height)
    }

    func sizeForExpandedCollectionViewHeader(_ collectionView: UICollectionView) -> CGSize {
        let dribbbleImageRatio = CGFloat(0.75)
        return CGSize(
            width: floor(collectionView.bounds.width),
            height: ceil(collectionView.bounds.width * dribbbleImageRatio + heightForCollapsedCollectionViewHeader) + viewModel.attachmentContainerHeight()
        )
    }

    func deleteComment(atIndexPath indexPath: IndexPath) {
        let isAllowedToDisplaySeparator = viewModel.isAllowedToDisplaySeparator
        firstly {
            viewModel.deleteCommentAtIndex(indexPath.item)
        }.then { () -> Void in
            var indexPaths = [indexPath]
            if isAllowedToDisplaySeparator != self.viewModel.isAllowedToDisplaySeparator {
                indexPaths.append(IndexPath(item: indexPath.item - 1, section: 0))
            }
            self.shotDetailsView.collectionView.deleteItems(at: indexPaths)
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.deleteCommentFailed, canBeDismissedByUser: true)
        }
    }

    func reportComment(atIndexPath indexPath: IndexPath) {

        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController.emailAccountNotFound()
            present(alert, animated: true, completion: nil)
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

        present(composer, animated: true, completion: nil)
        composer.navigationBar.tintColor = .white
    }

    func likeComment(atIndexPath indexPath: IndexPath) {
        firstly {
            viewModel.performLikeOperationForComment(atIndexPath: indexPath)
        }.then {
            self.viewModel.checkLikeStatusForComment(atIndexPath: indexPath, force: true)
        }.then { isLiked -> Void in
            self.viewModel.setLikeStatusForComment(atIndexPath: indexPath, withValue: isLiked)
            self.shotDetailsView.collectionView.reloadItems(at: [indexPath])
        }.catch { _ in }
    }

    func unlikeComment(atIndexPath indexPath: IndexPath) {
        firstly {
            viewModel.performUnlikeOperationForComment(atIndexPath: indexPath)
        }.then {
            self.viewModel.checkLikeStatusForComment(atIndexPath: indexPath, force: true)
        }.then { isLiked -> Void in
            self.viewModel.setLikeStatusForComment(atIndexPath: indexPath, withValue: isLiked)
            self.shotDetailsView.collectionView.reloadItems(at: [indexPath])
        }.catch { _ in }
    }

    func presentShotBucketsViewControllerWithMode(_ mode: ShotBucketsViewControllerMode, onModalCompletion completion:(() -> Void)? = nil) {

        shotDetailsView.commentComposerView.makeInactive()

        let shotBucketsViewController = ShotBucketsViewController(shot: viewModel.shot, mode: mode)
        animateHeader(start: false)
        shotBucketsViewController.willDismissViewControllerClosure = { [weak self] in
            self?.animateHeader(start: true)
            self?.viewModel.clearBucketsData()
            self?.shotDetailsView.collectionView.reloadItems(at: [IndexPath(item: 0, section: 0)])
            completion?()
        }

        modalTransitionAnimator =
                CustomTransitions.pullDownToCloseTransitionForModalViewController(shotBucketsViewController)
        shotBucketsViewController.transitioningDelegate = modalTransitionAnimator
        shotBucketsViewController.modalPresentationStyle = .custom
        present(shotBucketsViewController, animated: true, completion: nil)
    }

    func presentShotFullscreen() {

        guard let header = header, header.isDoneFetchingImage  else { return }

        
        let url = viewModel.shot.shotImage.hidpiURL ?? viewModel.shot.shotImage.normalURL
        if viewModel.shot.animated {
            let galleryProvider = GalleryViewProvider(animatedUrl: url, displacedView: header.imageView)
            presentImageGallery(galleryProvider.galleryViewController)
            
        } else {
            let galleryProvider = GalleryViewProvider(imageUrls: [url], displacedView: header.imageView)
            presentImageGallery(galleryProvider.galleryViewController)
        }
    }
    
    func presentFullScreenAttachment(_ displacedView: UIView) {
        /* 
         To prevent glitchy animation we are adding placeholder view
         from where animation will start but without showing thumbnail 
         image in show animation.
         */
        guard let url = header?.selectedAttachment?.imageURL else {
            return
        }
        let placeholderView = UIImageView(frame: displacedView.frame)
        placeholderView.backgroundColor = .clear
        displacedView.superview?.addSubview(placeholderView)
        let galleryProvider = GalleryViewProvider(imageUrls: [url], displacedView: placeholderView)
        galleryProvider.galleryViewController.closedCompletion = {
            placeholderView.removeFromSuperview()
        }

        presentImageGallery(galleryProvider.galleryViewController)
    }

    func grayOutFooterIfNeeded() {
        let shouldGrayOut = !viewModel.hasComments && !viewModel.hasDescription
        footer?.grayOutBackground(shouldGrayOut)
    }

    dynamic func closeButtonDidTap(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    dynamic func shareButtonDidTap() {
        let activityViewController = UIActivityViewController(activityItems: [viewModel.shot.htmlUrl], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
