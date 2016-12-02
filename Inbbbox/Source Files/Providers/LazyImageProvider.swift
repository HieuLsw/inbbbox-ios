//
//  LazyImageProvider.swift
//  Inbbbox
//
//  Created by Peter Bruz on 11/04/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Haneke
import PromiseKit

final class LazyImageProvider {

    /// Lazily loads images from URLs. Uses cache for `imageFormatName`.
    ///
    /// - parameter urls:                  Tuple consisting of max 3 urls that are loaded one by one.
    /// - parameter teaserImageCompletion: Completion called after downloading teaser image.
    /// - parameter normalImageCompletion: Optional completion called after downloading normal image.
    /// - parameter hidpiImageCompletion:  Optional completion called after downloading hidpi image.
    class func lazyLoadImageFromURLs(_ urls: (teaserURL: URL, normalURL: URL?, hidpiURL: URL?),
                                     teaserImageCompletion: @escaping (UIImage) -> Void,
                                     normalImageCompletion: ((UIImage) -> Void)? = nil,
                                     hidpiImageCompletion: ((UIImage) -> Void)? = nil) {
        
        firstly {
            loadImageFromURL(urls.teaserURL)
        }.then { image -> Void in
            if let image = image {
                teaserImageCompletion(image)
            }
        }.then {
            loadImageFromURL(urls.normalURL)
        }.then { image -> Void in
            if let image = image {
                normalImageCompletion?(image)
            }
        }.then {
            loadImageFromURL(urls.hidpiURL)
        }.then { image -> Void in
            if let image = image {
                hidpiImageCompletion?(image)
            }
        }.catch { _ in }
    }
}

private extension LazyImageProvider {

    class func loadImageFromURL(_ url: URL?) -> Promise<UIImage?> {

        guard let url = url else { return Promise<UIImage?>(value: nil) }

        return Promise<UIImage?> { fulfill, reject in
            _ = Shared.imageCache.fetch(URL: url, formatName: CacheManager.imageFormatName, failure: { error in
                    if let error = error {
                        reject(error)
                    }
                },
                success: { image in
                    fulfill(image)
                })
        }
    }
}
