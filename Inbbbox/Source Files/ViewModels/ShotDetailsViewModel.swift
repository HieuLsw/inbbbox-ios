//
//  ShotDetailsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit

struct CommentDisplayableData {

    let author: NSAttributedString
    let comment: NSAttributedString?
    let date: NSAttributedString
    let avatarURL: NSURL?
    var likesCount: NSAttributedString
    var likedByMe: Bool
}

final class ShotDetailsViewModel {

    let shot: ShotType
    private(set) var isFetchingComments = false

    var commentsProvider = APICommentsProvider(page: 1, pagination: 30)
    var commentsRequester = APICommentsRequester()
    var userProvider = APIUsersProvider()
    var bucketsRequester = BucketsRequester()
    var shotsRequester = ShotsRequester()
    var attachmentsProvider = APIAttachmentsProvider()

    var itemsCount: Int {

        var counter = comments.count + 1 // 1 for ShotDetailsOperationCollectionViewCell
        if hasDescription {
            counter += 1 // for ShotDetailsDescriptionCollectionViewCell
        }

        if isAllowedToDisplaySeparator {
            counter += 1 // for ShotDetailsDummySpaceCollectionViewCell
        }

        return counter
    }

    private var cachedFormattedComments = [CommentDisplayableData]()
    private var cachedFormattedTitle: NSAttributedString?
    private var cachedFormattedDescription: NSAttributedString?
    
    var comments = [CommentType]()
    var attachments = [Attachment]()
    private var userBucketsForShot = [BucketType]()
    private var isShotLikedByMe: Bool?
    private var userBucketsForShotCount: Int?

    init(shot: ShotType, isLiked: Bool?) {
        self.shot = shot
        isShotLikedByMe = isLiked
    }

    func isDescriptionIndex(index: Int) -> Bool {
        return hasDescription && index == 1
    }

    func isShotOperationIndex(index: Int) -> Bool {
        return index == 0
    }

    func shouldDisplaySeparatorAtIndex(index: Int) -> Bool {

        guard isAllowedToDisplaySeparator else {
            return false
        }

        if index == 2 && hasDescription && hasComments {
            return true
        } else if index == 1 && !hasDescription && hasComments {
            return true
        }

        return false
    }

    func isCurrentUserOwnerOfCommentAtIndex(index: Int) -> Bool {

        let comment = comments[indexInCommentArrayBasedOnItemIndex(index)]
        return UserStorage.currentUser?.identifier == comment.user.identifier
    }
}

// MARK: Data formatting

extension ShotDetailsViewModel {

    var attributedShotTitleForHeader: NSAttributedString {

        if let cachedFormattedTitle = cachedFormattedTitle {
            return cachedFormattedTitle
        }
        cachedFormattedTitle = ShotDetailsFormatter.attributedStringForHeaderWithLinkRangeFromShot(shot).attributedString
        return cachedFormattedTitle!
    }

    var attributedShotDescription: NSAttributedString? {

        if let cachedFormattedDescription = cachedFormattedDescription {
            return cachedFormattedDescription
        }
        cachedFormattedDescription = ShotDetailsFormatter.attributedShotDescriptionFromShot(shot)
        return cachedFormattedDescription!
    }

    var hasDescription: Bool {
        if let description = shot.attributedDescription where description.length > 0 {
            return true
        }
        return false
    }

    var userLinkRange: NSRange {
        return ShotDetailsFormatter.attributedStringForHeaderWithLinkRangeFromShot(shot).userLinkRange ??
                NSRange(location: 0, length: 0)
    }

    var teamLinkRange: NSRange {
        return ShotDetailsFormatter.attributedStringForHeaderWithLinkRangeFromShot(shot).teamLinkRange ??
            NSRange(location: 0, length: 0)
    }

    func displayableDataForCommentAtIndex(index: Int) -> CommentDisplayableData {

        let indexWithOffset = indexInCommentArrayBasedOnItemIndex(index)

        let existsCachedComment = cachedFormattedComments.count > indexWithOffset
        if !existsCachedComment {

            let comment = comments[indexWithOffset]
            let displayableData = createDisplayableData(withComment: comment)

            cachedFormattedComments.append(displayableData)
        }

        return cachedFormattedComments[indexWithOffset]
    }

    func userForCommentAtIndex(index: Int) -> UserType {
        return comments[self.indexInCommentArrayBasedOnItemIndex(index)].user
    }

    private func createDisplayableData(withComment comment: CommentType) -> CommentDisplayableData {
        let displayableData = CommentDisplayableData(
            author: ShotDetailsFormatter.commentAuthorForComment(comment),
            comment: ShotDetailsFormatter.attributedCommentBodyForComment(comment),
            date: ShotDetailsFormatter.commentDateForComment(comment),
            avatarURL: comment.user.avatarURL,
            likesCount: ShotDetailsFormatter.commentLikesCountForComment(comment),
            likedByMe: comment.likedByMe
        )
        return displayableData
    }

}

// MARK: Likes handling

extension ShotDetailsViewModel {

    func performLikeOperation() -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in

            if let shotLiked = isShotLikedByMe {

                firstly {
                    shotLiked ? shotsRequester.unlikeShot(shot) : shotsRequester.likeShot(shot)
                }.then { _ -> Void in
                    self.isShotLikedByMe = !shotLiked
                    fulfill(!shotLiked)
                }.error(reject)
            }
        }
    }

    func checkLikeStatusOfShot() -> Promise<Bool> {

        if let isShotLikedByMe = isShotLikedByMe {
            return Promise(isShotLikedByMe)
        }

        return Promise<Bool> { fulfill, reject in

            firstly {
                shotsRequester.isShotLikedByMe(shot)
            }.then { isShotLikedByMe -> Void in
                self.isShotLikedByMe = isShotLikedByMe
                fulfill(isShotLikedByMe)
            }.error(reject)
        }
    }

    func checkDetailOfShot() -> Promise<ShotType> {
        return shotsRequester.fetchShotDetails(shot)
    }
}

// MARK: Buckets handling

extension ShotDetailsViewModel {

    func checkShotAffiliationToUserBuckets() -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in

            firstly {
                checkNumberOfUserBucketsForShot()
            }.then { number -> Void in
                fulfill(Bool(number))
            }.error(reject)
        }
    }

    func checkNumberOfUserBucketsForShot() -> Promise<Int> {

        if let userBucketsForShotCount = userBucketsForShotCount {
            return Promise(userBucketsForShotCount)
        }

        return Promise<Int> { fulfill, reject in

            firstly {
                shotsRequester.userBucketsForShot(shot)
            }.then { buckets -> Void in
                self.userBucketsForShot = buckets
                self.userBucketsForShotCount = self.userBucketsForShot.count
                fulfill(self.userBucketsForShotCount!)
            }.error(reject)
        }
    }

    func clearBucketsData() {
        userBucketsForShotCount = nil
        userBucketsForShot = []
    }

    func removeShotFromBucketIfExistsInExactlyOneBucket() -> Promise<(removed: Bool, bucketsNumber: Int?)> {
        return Promise<(removed: Bool, bucketsNumber: Int?)> { fulfill, reject in

            var numberOfBuckets: Int?

            firstly {
                checkNumberOfUserBucketsForShot()
            }.then { number -> Void in
                numberOfBuckets = number
                if numberOfBuckets == 1 {
                    self.bucketsRequester.removeShot(self.shot, fromBucket: self.userBucketsForShot[0])
                }
            }.then { () -> Void in
                if numberOfBuckets == 1 {
                    self.clearBucketsData()
                    fulfill((removed: true, bucketsNumber: nil))
                } else {
                    fulfill((removed: false, bucketsNumber: numberOfBuckets))
                }
            }.error(reject)
        }
    }
}

// MARK: Comments handling

extension ShotDetailsViewModel {

    var isCommentingAvailable: Bool {
        if let accountType = UserStorage.currentUser?.accountType {
            return accountType == .Player || accountType == .Team
        }
        return false
    }

    var hasComments: Bool {
        return comments.count > 0
    }

    private var hasMoreCommentsToFetch: Bool {
        return UInt(comments.count) < shot.commentsCount
    }

    func loadComments() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            isFetchingComments = true

            if comments.count == 0 {
                firstly {
                    commentsProvider.provideCommentsForShot(shot)
                }.then { comments -> Void in
                    self.comments = comments ?? []
                }.always {
                    self.isFetchingComments = false
                }.then(fulfill).error(reject)

            } else {

                firstly {
                    commentsProvider.nextPage()
                }.then { comments -> Void in
                    if let comments = comments {
                        self.comments.appendContentsOf(comments)
                    }
                }.always {
                    self.isFetchingComments = false
                }.then(fulfill).error(reject)
            }
        }
    }

    func loadAllComments() -> Promise<Void> {
        loadAttachments()
        return Promise<Void> { fulfill, reject in

            firstly {
                loadComments()
            }.then {
                if !self.hasMoreCommentsToFetch {
                    fulfill()
                    return Promise()
                }
                return self.loadAllComments()
            }.then(fulfill).error(reject)
        }
    }

    func postComment(message: String) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            firstly {
                commentsRequester.postCommentForShot(shot, withText: message)
            }.then { comment in
                self.comments.append(comment)
            }.then(fulfill).error(reject)
        }
    }

    func deleteCommentAtIndex(index: Int) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            let comment = comments[indexInCommentArrayBasedOnItemIndex(index)]

            firstly {
                commentsRequester.deleteComment(comment, forShot: shot)
            }.then { comment -> Void in
                let indexOfCommentToRemove = self.indexInCommentArrayBasedOnItemIndex(index)
                self.comments.removeAtIndex(indexOfCommentToRemove)
                self.cachedFormattedComments.removeAtIndex(indexOfCommentToRemove)

                fulfill()
            }.error(reject)
        }
    }

    func reportBodyForAbusiveComment(indexPath: NSIndexPath) -> String {

        let index = indexInCommentArrayBasedOnItemIndex(indexPath.row)
        let comment = comments[index]

        let commentBody = comment.body?.string ?? ""

        let separator = "***********************************"
        let report = separator + "\n" +
                     commentBody + "\n" +
                     "Author: " + comment.user.username + "\n" +
                     "Author ID: " + comment.user.identifier + "\n" +
                     "Comment ID: " + comment.identifier + "\n" +
                     "Shot ID: " + shot.identifier + "\n" +
                     separator
        return report
    }

    func performLikeOperationForComment(atIndexPath indexPath: NSIndexPath) -> Promise<Void> {

        let index = indexInCommentArrayBasedOnItemIndex(indexPath.row)
        let comment = comments[index]

        return Promise<Void> { fulfill, reject in

            firstly {
                commentsRequester.likeComment(comment, forShot: shot)
            }.then(fulfill).error(reject)
        }
    }

    func performUnlikeOperationForComment(atIndexPath indexPath: NSIndexPath) -> Promise<Void> {

        let index = indexInCommentArrayBasedOnItemIndex(indexPath.row)
        let comment = comments[index]

        return Promise<Void> { fulfill, reject in

            firstly {
                commentsRequester.unlikeComment(comment, forShot: shot)
            }.then(fulfill).error(reject)
        }
    }

    func checkLikeStatusForComment(atIndexPath indexPath: NSIndexPath, force: Bool) -> Promise<Bool> {

        let index = indexInCommentArrayBasedOnItemIndex(indexPath.row)
        let comment = comments[index]

        if force || !comment.checkedForLike {
            return Promise<Bool> { fulfill, reject in

                firstly {
                    commentsRequester.checkIfLikeComment(comment, forShot: shot)
                }.then(fulfill).error(reject)
            }
        }

        return Promise(comment.likedByMe)
    }

    func setLikeStatusForComment(atIndexPath indexPath: NSIndexPath, withValue isLiked: Bool) {

        let index = indexInCommentArrayBasedOnItemIndex(indexPath.row)
        var comment = comments[index]

        if comment.likedByMe != isLiked {
            let diff = isLiked ? 1 : -1
            comment.likesCount = comment.likesCount + diff

            comment.likedByMe = isLiked

            let displayableData = createDisplayableData(withComment: comment)
            cachedFormattedComments[index] = displayableData
        }

        comment.checkedForLike = true
        comments[index] = comment
    }
}

extension ShotDetailsViewModel {

    func shouldOpenUserDetailsFromUrl(url: NSURL) -> Bool {
        let userUrlPattern = "^https://dribbble.com/[0-9]{1,9}$"
        return url.absoluteString.rangeOfString(userUrlPattern, options: .RegularExpressionSearch) != nil
    }

    func indexInCommentArrayBasedOnItemIndex(index: Int) -> Int {
        return comments.count - itemsCount + index
    }

    var isAllowedToDisplaySeparator: Bool {

        if isFetchingComments {
            return false
        } else if (hasDescription && hasComments) || (!hasDescription && hasComments) {
            return true
        }

        return false
    }
}

// MARK: URL - User handling

extension ShotDetailsViewModel: URLToUserProvider, UserToURLProvider {

    func userForURL(url: NSURL) -> UserType? {
        return shot.user.identifier == url.absoluteString ? shot.user : comments.filter {
            $0.user.identifier == url.absoluteString
        }.first?.user
    }

    func userForId(identifier: String) -> Promise<UserType> {
        return userProvider.provideUser(identifier)
    }
}

// MARK: Attachments handling

extension ShotDetailsViewModel {
    
    /*
     Returns height for attachment Container in shot details view.
     0 is returned if there is no attachments.
     */
    func attachmentContainerHeight() -> CGFloat {
        return shot.attachmentsCount == 0 ? 0 : 70
    }
    
    /*
     Downloads attachments for shot and saves them into attachment property.
     */
    func loadAttachments() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            if (shot.attachmentsCount == 0) {
                fulfill()
                return
            }
            firstly {
                attachmentsProvider.provideAttachmentsForShot(shot)
            }.then { attachments -> Void in
                if let attachments = attachments {
                    self.attachments = attachments
                }
                fulfill()
            }.error(reject)
        }
    }
    
}
