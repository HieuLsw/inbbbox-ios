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

// MARK: Protocols

protocol UICollectionViewCellWithLabelContainingClickableLinksDelegate: class {
    func labelContainingClickableLinksDidTap(_ gestureRecognizer: UITapGestureRecognizer, textContainer: NSTextContainer, layoutManager: NSLayoutManager)
    func urlInLabelTapped(_ url: URL)
}

// MARK: KeyboardResizableViewDelegate

extension ShotDetailsViewController: KeyboardResizableViewDelegate {

    func keyboardResizableView(_ view: KeyboardResizableView, willRelayoutSubviewsWithState state: KeyboardState) {
        let round = state == .willAppear
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

    func didTapSendButtonInComposerView(_ view: CommentComposerView, comment: String) {

        view.startAnimation()

        let isAllowedToDisplaySeparator = viewModel.isAllowedToDisplaySeparator

        firstly {
            viewModel.postComment(comment)
        }.then { () -> Void in

            let numberOfItemsInFirstSection = self.shotDetailsView.collectionView.numberOfItems(inSection: 0)
            var indexPaths = [IndexPath(item: numberOfItemsInFirstSection, section: 0)]
            if isAllowedToDisplaySeparator != self.viewModel.isAllowedToDisplaySeparator {
                indexPaths.append(IndexPath(item: numberOfItemsInFirstSection + 1, section: 0))
            }
            self.shotDetailsView.collectionView.performBatchUpdates({ () -> Void in
                self.shotDetailsView.collectionView.insertItems(at: indexPaths)
            }, completion: { _ -> Void in
                self.shotDetailsView.collectionView.scrollToItem(at: indexPaths[0],
                    at: .centeredVertically, animated: true)
            })
        }.always {
            view.stopAnimation()
        }.catch { error -> Void in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.addingCommentFailed, canBeDismissedByUser: true)
        }
    }

    func commentComposerViewDidBecomeActive(_ view: CommentComposerView) {
        scroller.scrollToBottomAnimated(true)
    }
}

// MARK: UIScrollViewDelegate

extension ShotDetailsViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animateHeader(start: false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        !decelerate ? {
            animateHeader(start: true)
            checkForCommentsLikes()
        }() : {}()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateHeader(start: true)
        checkForCommentsLikes()
    }

    fileprivate func checkForCommentsLikes() {
        let visibleCells = shotDetailsView.collectionView.indexPathsForVisibleItems

        for indexPath in visibleCells {
            let index = viewModel.indexInCommentArrayBasedOnItemIndex(indexPath.row)

            if index >= 0 && index < viewModel.comments.count {
                firstly {
                    viewModel.checkLikeStatusForComment(atIndexPath: indexPath, force: false)
                }.then { isLiked -> Void in
                    self.viewModel.setLikeStatusForComment(atIndexPath: indexPath, withValue: isLiked)
                    if isLiked {
                        self.shotDetailsView.collectionView.reloadItems(at: [indexPath])
                    }
                }.catch { _ in }
            }
        }
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension ShotDetailsViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {

        controller.dismiss(animated: true) {
            self.hideUnusedCommentEditingViews()
        }

        switch result {
        case MFMailComposeResult.sent:
            let contentReportedAlert = UIAlertController.inappropriateContentReported()
            present(contentReportedAlert, animated: true, completion: nil)
        default: break
        }
    }
}

// MARK: TTTAttributedLabelDelegate

extension ShotDetailsViewController: TTTAttributedLabelDelegate {

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        if let user = viewModel.userForURL(url) {
            presentProfileViewControllerForUser(user)
        } else {
            firstly {
                viewModel.userForId(url.absoluteString)
            }.then { [weak self] user in
                self?.presentProfileViewControllerForUser(user)
            }.catch { _ in }
        }
    }
}

// MARK: AvatarViewDelegate

extension ShotDetailsViewController: AvatarViewDelegate {

    func avatarView(_ avatarView: AvatarView, didTapButton avatarButton: UIButton) {
        var user: UserType?
        if avatarView.superview == header {
            user = viewModel.shot.user
        } else if avatarView.superview?.superview is ShotDetailsCommentCollectionViewCell {

            guard let cell = avatarView.superview?.superview as? ShotDetailsCommentCollectionViewCell else { return }

            if let indexPath = shotDetailsView.collectionView.indexPath(for: cell) {
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

    func labelContainingClickableLinksDidTap(_ gestureRecognizer: UITapGestureRecognizer,
                                             textContainer: NSTextContainer, layoutManager: NSLayoutManager) {

        guard let url = URLDetector.detectUrlFromGestureRecognizer(gestureRecognizer,
                                                                   textContainer: textContainer,
                                                                   layoutManager: layoutManager) else { return }
        handleTappedUrl(url)
        
    }
    
    func urlInLabelTapped(_ url: URL) {
        handleTappedUrl(url)
    }
    
    fileprivate func handleTappedUrl(_ url: URL) {
        if viewModel.shouldOpenUserDetailsFromUrl(url) {
            if let identifier = url.absoluteString.components(separatedBy: "/").last {
                firstly {
                    viewModel.userForId(identifier)
                    }.then { [weak self] user in
                        self?.presentProfileViewControllerForUser(user)
                }.catch { _ in }
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
