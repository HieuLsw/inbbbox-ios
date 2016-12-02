//
//  APICommentsProvider.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 10/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

/// Provides interface for dribbble comments read API
class APICommentsProvider: PageableProvider {

    /**
     Provides comments for given shot.

     - parameter shot: Shot which comments should be fetched

     - returns: Promise which resolves with comments or nil.
     */
    func provideCommentsForShot(_ shot: ShotType) -> Promise<[CommentType]?> {

        let query = CommentQuery(shot: shot)
        return Promise<[CommentType]?> { fulfill, reject in
            firstly {
                firstPageForQueries([query], withSerializationKey: nil)
            }.then { (comments: [Comment]?) -> Void in
                fulfill(comments.flatMap { $0.map { $0 as CommentType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides next page of comments.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with comments or nil.
     */
    func nextPage() -> Promise<[CommentType]?> {
        return Promise <[CommentType]?> { fulfill, reject in
            firstly {
                nextPageFor(Comment.self)
            }.then { comments -> Void in
                fulfill(comments.flatMap { $0.map { $0 as CommentType } })
            }.catch(execute: reject)
        }
    }

    /**
     Provides previous page of comments.

     - Warning: You have to use any of provide... method first to be able to use this method.
     Otherwise an exception will appear.

     - returns: Promise which resolves with comments or nil.
     */
    func previousPage() -> Promise<[CommentType]?> {
        return Promise <[CommentType]?> { fulfill, reject in
            firstly {
                previousPageFor(Comment.self)
            }.then { comments -> Void in
                fulfill(comments.flatMap { $0.map { $0 as CommentType } })
            }.catch(execute: reject)
        }
    }
}
