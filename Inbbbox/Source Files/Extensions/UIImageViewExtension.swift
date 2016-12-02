//
//  UIImageViewExtension.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 07.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Haneke

extension UIImageView {

    /// Loads image form URL
    ///
    /// - parameter url:                URL where image is located
    /// - parameter placeholderImage:   optional placeholder image
    func loadImageFromURL(_ url: URL?, placeholderImage: UIImage? = nil) {
        image = placeholderImage
        guard let url = url else { return }
        _ = Shared.imageCache.fetch(URL: url,
                                    formatName: CacheManager.imageFormatName,
                                    failure: nil,
                                    success: { [weak self] image in
                                        self?.image = image
                                    }
        )
    }
}
