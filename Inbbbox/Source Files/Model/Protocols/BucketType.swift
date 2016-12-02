//
//  BucketType.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/18/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Interface for Bucket and ManagedBucket.
protocol BucketType {

    /// Unique identifier.
    var identifier: String { get }

    /// Name of the Bucket.
    var name: String { get }

    /// Description of the Bucket.
    var attributedDescription: NSAttributedString? { get }

    /// Number of shots contained in this Bucket.
    var shotsCount: UInt { get }

    /// Date when Bucket was created.
    var createdAt: Date { get }

    /// Owner of this Bucket.
    ///
    /// - returns: User.
    var owner: UserType { get }
}

func == (lhs: BucketType, rhs: BucketType) -> Bool {
    return lhs.identifier == rhs.identifier
}

func == (lhs: [BucketType], rhs: [BucketType]) -> Bool {

    guard lhs.count == rhs.count else { return false }

    var indexingGenerators = (left: lhs.makeIterator(), right: rhs.makeIterator())

    var isEqual = true
    while let leftElement = indexingGenerators.left.next(),
            let rightElement = indexingGenerators.right.next(), isEqual {
        isEqual = leftElement == rightElement
    }

    return isEqual
}

func != (lhs: [BucketType], rhs: [BucketType]) -> Bool {
    return !(lhs == rhs)
}
