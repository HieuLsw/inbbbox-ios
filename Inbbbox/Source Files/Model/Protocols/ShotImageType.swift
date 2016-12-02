//
//  ShotImageType.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/17/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Interface for ShotImage and ManagedShotImage.
protocol ShotImageType {

    /// The hidpi image may or may not be present, but will always be 800x600.
    ///
    /// - returns: URL to image with size 800x600. If `animated` attribute of the shot is `true`,
    ///            this image will be animated.
    var hidpiURL: URL? { get }

    /// The normal image is typically 400x300, but may be smaller if created before October 4th, 2012.
    ///
    /// - returns: URL to image with size 400x300. If `animated` attribute of the shot is `true`,
    ///            this image will be animated.
    var normalURL: URL { get }

    /// The teaser image is typically 200x150, but may be smaller if created before October 4th, 2012.
    ///
    /// - returns: URL to image with size 200x150.
    var teaserURL: URL { get }
}
