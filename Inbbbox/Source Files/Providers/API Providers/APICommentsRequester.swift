//
//  APICommentsRequester.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

/// Provides interface for dribbble comments update, delete and create API

class APICommentsRequester: Verifiable {
    /**
     Creates and posts comment for given shot with provided text.

     - Warning: Posting comments requires authenticated user with AccountType *Team* or *Player*

     - parameter shot: Shot which should be commented.
     - parameter text: Text of comment.

     - returns: Promise which resolves with created comment.
     */
    func postCommentForShot(shot: ShotType, withText text: String) -> Promise<CommentType> {
        AnalyticsManager.trackUserActionEvent(.Comment)
        let query = CreateCommentQuery(shot: shot, body: text)
        return sendCommentQuery(query, verifyTextLength: text)
    }

    /**
     Updates given comment for shot with provided text.

     - Warning: Updating comments requires authenticated user with AccountType *Team* or *Player*.
     User has to be owner of comment.

     - parameter comment: Comment which should be updated.
     - parameter shot:    Shot which belongs to comment.
     - parameter text:    New body of comment.

     - returns: Promise which resolves with updated comment.
     */
    func updateComment(comment: CommentType, forShot shot: ShotType, withText text: String) -> Promise<CommentType> {

        let query = UpdateCommentQuery(shot: shot, comment: comment, withBody: text)
        return sendCommentQuery(query, verifyTextLength: text)
    }

    /**
     Deletes given comment for provided shot.

     - Warning: Deleting comments requires authenticated user with AccountType *Team* or *Player*.
     User has to be owner of comment.

     - parameter comment: Comment which should be deleted.
     - parameter shot:    Shot which belongs to comment.

     - returns: Promise which resolves with Void.
     */
    func deleteComment(comment: CommentType, forShot shot: ShotType) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            let query = DeleteCommentQuery(shot: shot, comment: comment)

            firstly {
                sendCommentDeleteQuery(query)
            }.then(fulfill).error(reject)
        }
    }

    /**
     Likes given comment for provided shot.

     - Warning: Liking comments requires authenticated user with the *write* scope.

     - parameter comment: Comment which should be marked as liked.
     - parameter shot:    Shot which belongs to comment.

     - returns: Promise which resolves with Void.
     */
    func likeComment(comment: CommentType, forShot shot: ShotType) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            let query = CommentLikeQuery(shot: shot, comment: comment)

            firstly {
                sendCommentLikeQuery(query)
            }.then(fulfill).error(reject)
        }
    }

    /**
     Unlikes given comment for provided shot.

     - Warning: Unliking comments requires authenticated user with the *write* scope.

     - parameter comment: Comment for which a like mark should be removed.
     - parameter shot:    Shot which belongs to comment.

     - returns: Promise which resolves with Void.
     */
    func unlikeComment(comment: CommentType, forShot shot: ShotType) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            let query = CommentUnlikeQuery(shot: shot, comment: comment)

            firstly {
                sendCommentLikeQuery(query)
            }.then(fulfill).error(reject)
        }
    }

    /**
     Checks like status of comment for provided shot.

     - parameter comment: Comment for check.
     - parameter shot:    Shot which belongs to comment.

     - returns: Promise which resolves with Bool.
     */
    func checkIfLikeComment(comment: CommentType, forShot shot: ShotType) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in

            let query = CommentLikedQuery(shot: shot, comment: comment)

            firstly {
                sendCommentLikedQuery(query)
            }.then { result in
                fulfill(result)
            }.error(reject)
        }
    }
}

private extension APICommentsRequester {

    func sendCommentQuery(query: Query, verifyTextLength text: String) -> Promise<CommentType> {
        return Promise<CommentType> { fulfill, reject in

            firstly {
                verifyTextLength(text, min: 1, max: UInt.max)
            }.then {
                self.sendCommentQuery(query)
            }.then(fulfill).error(reject)
        }
    }

    func sendCommentQuery(query: Query) -> Promise<CommentType> {
        return Promise<CommentType> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                self.verifyAccountType()
            }.then {
                Request(query: query).resume()
            }.then { json -> Void in

                guard let json = json else {
                    throw ResponseError.UnexpectedResponse
                }
                fulfill(Comment.map(json))

            }.error(reject)
        }
    }

    func sendCommentDeleteQuery(query: Query) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                self.verifyAccountType()
            }.then {
                Request(query: query).resume()
            }.then { _ in fulfill() }.error(reject)
        }
    }

    func sendCommentLikeQuery(query: Query) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                Request(query: query).resume()
            }.then { _ in fulfill() }.error(reject)
        }
    }

    func sendCommentLikedQuery(query: Query) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in

            firstly {
                verifyAuthenticationStatus(true)
            }.then {
                Request(query: query).resume()
            }.then { _ in
                fulfill(true)
            }.error { error in
                // According to API documentation, when response.code is 404,
                // then comment is not liked by authenticated user.
                (error as NSError).code == 404 ? fulfill(false) : reject(error)
            }
        }
    }
}
