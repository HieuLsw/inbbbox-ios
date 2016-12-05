//
//  ShotDetailsViewControllerExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 02/05/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import ImageViewer
import MessageUI
import TTTAttributedLabel
import PromiseKit

// MARK: ImageProvider

extension ShotDetailsViewController: ImageProvider {

    func provideImage(completion: UIImage? -> Void) {
        if !viewModel.shot.animated {
            if let image = header?.imageView.image {
                completion(image)
            }
        }
    }
}

// MARK: KeyboardResizableViewDelegate

extension ShotDetailsViewController: KeyboardResizableViewDelegate {

    func keyboardResizableView(view: KeyboardResizableView, willRelayoutSubviewsWithState state: KeyboardState) {
        let round = state == .WillAppear
        shotDetailsView.commentComposerView.animateByRoundingCorners(round)
    }
}

// MARK: ModalByDraggingClosable

extension ShotDetailsViewController: ModalByDraggingClosable {
    var scrollViewToObserve: UIScrollView {
        return shotDetailsView.collectionView
    }
}

// MARK: CommentComposerViewDelegate

extension ShotDetailsViewController: CommentComposerViewDelegate {

    func didTapSendButtonInComposerView(view: CommentComposerView, comment: String) {

        view.startAnimation()

        let isAllowedToDisplaySeparator = viewModel.isAllowedToDisplaySeparator

        firstly {
            viewModel.postComment(comment)
        }.then { () -> Void in

            let numberOfItemsInFirstSection = self.shotDetailsView.collectionView.numberOfItemsInSection(0)
            var indexPaths = [NSIndexPath(forItem: numberOfItemsInFirstSection, inSection: 0)]
            if isAllowedToDisplaySeparator != self.viewModel.isAllowedToDisplaySeparator {
                indexPaths.append(NSIndexPath(forItem: numberOfItemsInFirstSection + 1, inSection: 0))
            }
            self.shotDetailsView.collectionView.performBatchUpdates({ () -> Void in
                self.shotDetailsView.collectionView.insertItemsAtIndexPaths(indexPaths)
            }, completion: { _ -> Void in
                self.shotDetailsView.collectionView.scrollToItemAtIndexPath(indexPaths[0],
                        atScrollPosition: .CenteredVertically, animated: true)
            })
        }.always {
            view.stopAnimation()
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.addingCommentFailed, canBeDismissedByUser: true)
        }
    }

    func commentComposerViewDidBecomeActive(view: CommentComposerView) {
        scroller.scrollToBottomAnimated(true)
    }
}

// MARK: UIScrollViewDelegate

extension ShotDetailsViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        animateHeader(start: false)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        !decelerate ? {
            animateHeader(start: true)
            checkForCommentsLikes()
        }() : {}()
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        animateHeader(start: true)
        checkForCommentsLikes()
    }

    private func checkForCommentsLikes() {
        let visibleCells = shotDetailsView.collectionView.indexPathsForVisibleItems()

        for indexPath in visibleCells {
            let index = viewModel.indexInCommentArrayBasedOnItemIndex(indexPath.row)

            if index >= 0 && index < viewModel.comments.count {
                firstly {
                    viewModel.checkLikeStatusForComment(atIndexPath: indexPath, force: false)
                }.then { isLiked -> Void in
                    self.viewModel.setLikeStatusForComment(atIndexPath: indexPath, withValue: isLiked)
                    if isLiked {
                        self.shotDetailsView.collectionView.reloadItemsAtIndexPaths([indexPath])
                    }
                }
            }
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension ShotDetailsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {

        controller.dismissViewControllerAnimated(true) {
            self.hideUnusedCommentEditingViews()
        }

        switch result {
        case MFMailComposeResultSent:
            let contentReportedAlert = UIAlertController.inappropriateContentReported()
            presentViewController(contentReportedAlert, animated: true, completion: nil)
        default: break
        }
    }
}

// MARK: TTTAttributedLabelDelegate

extension ShotDetailsViewController: TTTAttributedLabelDelegate {

    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if let user = viewModel.userForURL(url) {
            presentProfileViewControllerForUser(user)
        } else {
            firstly {
                viewModel.userForId(url.absoluteString)
            }.then { [weak self] user in
                self?.presentProfileViewControllerForUser(user)
            }
        }
    }
}

// MARK: AvatarViewDelegate

extension ShotDetailsViewController: AvatarViewDelegate {

    func avatarView(avatarView: AvatarView, didTapButton avatarButton: UIButton) {
        var user: UserType?
        if avatarView.superview == header {
            user = viewModel.shot.user
        } else if avatarView.superview?.superview is ShotDetailsCommentCollectionViewCell {

            guard let cell = avatarView.superview?.superview as? ShotDetailsCommentCollectionViewCell else { return }

            if let indexPath = shotDetailsView.collectionView.indexPathForCell(cell) {
                let index = viewModel.indexInCommentArrayBasedOnItemIndex(indexPath.row)
                user = viewModel.comments[index].user
            }
        }
        if let user = user {
            presentProfileViewControllerForUser(user)
        }
    }
}

// MARK: UICollectionViewCellWithLabelContainingClickableLinksDelegate

extension ShotDetailsViewController: UICollectionViewCellWithLabelContainingClickableLinksDelegate {

    func labelContainingClickableLinksDidTap(gestureRecognizer: UITapGestureRecognizer,
                                             textContainer: NSTextContainer, layoutManager: NSLayoutManager) {

        guard let url = URLDetector.detectUrlFromGestureRecognizer(gestureRecognizer,
                                                                   textContainer: textContainer,
                                                                   layoutManager: layoutManager) else { return }
        handleTappedUrl(url)
        
    }
    
    func urlInLabelTapped(url: NSURL) {
        handleTappedUrl(url)
    }
    
    private func handleTappedUrl(url: NSURL) {
        if viewModel.shouldOpenUserDetailsFromUrl(url) {
            if let identifier = url.absoluteString.componentsSeparatedByString("/").last {
                firstly {
                    viewModel.userForId(identifier)
                    }.then { [weak self] user in
                        self?.presentProfileViewControllerForUser(user)
                }
            }
        } else {
            UIApplication.sharedApplication().openURL(url)
        }
    }
}

// MARK: Protocols

protocol UICollectionViewCellWithLabelContainingClickableLinksDelegate: class {

    func labelContainingClickableLinksDidTap(gestureRecognizer: UITapGestureRecognizer,
                                             textContainer: NSTextContainer, layoutManager: NSLayoutManager)
    func urlInLabelTapped(url: NSURL)
}
