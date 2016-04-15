//
//  ImageViewerExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 15/04/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import ImageViewer

extension ImageViewer {

    /// Initialize `ImageViewer` using default configuration.
    ///
    /// - parameter imageProvider: Object that conforms to protocol `ImageProvider`.
    /// - parameter displacedView: View that should be displaced.
    convenience init(imageProvider: ImageProvider, displacedView: UIView) {

        let closeImage = UIImage(named: "ic-cross-naked") ?? UIImage()

        let buttonAssets = CloseButtonAssets(normal: closeImage, highlighted: closeImage)
        let imageSize = CGSize(width: 40, height: 40)
        let configuration = ImageViewerConfiguration(imageSize: imageSize, closeButtonAssets: buttonAssets)

        self.init(imageProvider: imageProvider, configuration: configuration, displacedView: displacedView)
    }
}
