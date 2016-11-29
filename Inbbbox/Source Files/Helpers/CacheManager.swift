//
//  CacheManager.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 07.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Haneke

class CacheManager {

    static let gifFormatName = "gifs"
    static let imageFormatName = "images"

    class func setupCache() {
        let dataCache = Shared.dataCache

        let gifFormat = Format<Data>(name: gifFormatName, diskCapacity: 10 * 1024 * 1024)
        dataCache.addFormat(gifFormat)

        let imageCache = Shared.imageCache

        let imageFormat = Format<UIImage>(name: imageFormatName, diskCapacity: 10 * 1024 * 1024)
        imageCache.addFormat(imageFormat)
    }
}
