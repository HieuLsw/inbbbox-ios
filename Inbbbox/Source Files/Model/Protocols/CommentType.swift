//
//  CommentType.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/18/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Interface for Comment.
protocol CommentType {

    /// Unique identifier
    var identifier: String { get }

    /// Comment's content.
    var body: NSAttributedString? { get }

    /// Date when Comment was created.
    var createdAt: Date { get }

    /// User which created this comment.
    ///
    /// - returns: User.
    var user: UserType { get }

    /// Number of likes received by comment
    var likesCount: Int { get set}

    /// Is comment marked as liked by user
    var likedByMe: Bool { get set }

    /// Was like data already fetched
    var checkedForLike: Bool { get set }
}
