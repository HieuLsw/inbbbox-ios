//
//  ShotImageType.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/17/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//


import Foundation

/// Interface for Team and ManagedTeam.
protocol TeamType {

    /// Unique identifier.
    var identifier: String { get }

    /// Name of the Team.
    var name: String { get }

    /// Username of the Team.
    var username: String { get }

    /// URL to avatar image.
    var avatarURL: URL? { get }

    /// Date when Team was created.
    var createdAt: Date { get }
}
