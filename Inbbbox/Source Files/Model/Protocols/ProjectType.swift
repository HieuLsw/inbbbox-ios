//
//  ProjectType.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/18/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Interface for Project and ManagedProject.
protocol ProjectType {

    /// Unique identifier.
    var identifier: String { get }

    /// Name of the Project.
    var name: String? { get }

    /// Description of the Project.
    var attributedDescription: NSAttributedString? { get }

    /// Date when Project was created.
    var createdAt: Date { get }

    /// Number of shots associated to this Project.
    var shotsCount: UInt { get }
}

func == (lhs: ProjectType, rhs: ProjectType) -> Bool {
    return lhs.identifier == rhs.identifier
}

func == (lhs: [ProjectType], rhs: [ProjectType]) -> Bool {

    guard lhs.count == rhs.count else { return false }

    var indexingGenerators = (left: lhs.makeIterator(), right: rhs.makeIterator())

    var isEqual = true
    while let leftElement = indexingGenerators.left.next(),
        let rightElement = indexingGenerators.right.next(), isEqual {
            isEqual = leftElement == rightElement
    }

    return isEqual
}

func != (lhs: [ProjectType], rhs: [ProjectType]) -> Bool {
    return !(lhs == rhs)
}
