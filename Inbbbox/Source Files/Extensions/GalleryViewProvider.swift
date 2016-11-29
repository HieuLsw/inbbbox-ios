//
//  GalleryViewProvider.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15/04/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import ImageViewer
import Haneke
import FLAnimatedImage

class GalleryViewProvider {
    
    fileprivate let imageUrls: [URL]?
    fileprivate let animatedUrl: URL?
    fileprivate let displacedView: UIImageView?
    
    fileprivate let galleryConfiguration: GalleryConfiguration = {
        let closeImage = UIImage(named: "ic-cross-naked") ?? UIImage()
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.setImage(closeImage, for: .highlighted)
        return [GalleryConfigurationItem.closeButtonMode(.custom(closeButton)),
                GalleryConfigurationItem.closeLayout(.pinRight(20, 20)),
                GalleryConfigurationItem.thumbnailsButtonMode(.none),
                GalleryConfigurationItem.hideDecorationViewsOnLaunch(false),
                GalleryConfigurationItem.blurDismissDuration(0.1),
                GalleryConfigurationItem.blurDismissDelay(0)]
    }()
    
    lazy var galleryViewController: GalleryViewController = {
        
        var gallery = GalleryViewController(startIndex: 0, itemsDatasource: self, displacedViewsDatasource: self, configuration: self.galleryConfiguration)
        return gallery
    }()
    
    fileprivate lazy var galleryItems: [GalleryItem] = {
        
        if let animated = self.animatedUrl {
            return [GalleryItem.custom(fetchImageBlock: { _ in },
                    itemViewControllerBlock: { ( index , count , imageCompletion, configuration , isInitial ) -> UIViewController in
                        
                        let controller = ItemBaseController<AnimatableShotImageView>(index: index, itemCount: count, fetchImageBlock:{ _ in }, configuration: configuration, isInitialController: isInitial)
                        controller.itemView.loadAnimatableShotFromUrl(animated)
                        return controller
                    })]
        }
        if let imageUrls = self.imageUrls {
            return imageUrls.map { url in
                return GalleryItem.image(fetchImageBlock: { completion in
                    _ = Shared.imageCache.fetch(
                            URL: url,
                            formatName: CacheManager.imageFormatName,
                            failure: nil,
                            success: { image in
                                completion(image)
                    })
                })
            }
        }
        return [GalleryItem]()
    }()
    

    /// Initialize `GalleryViewProvider` using default configuration.
    ///
    /// - parameter imageUrls: Images that should be shown in gallery
    /// - parameter displacedView: View that should be displaced.
    init(imageUrls: [URL], displacedView: UIImageView?) {
        self.imageUrls = imageUrls
        self.displacedView = displacedView
        self.animatedUrl = nil
    }
    
    /// Initialize `GalleryViewProvider` using default configuration.
    ///
    /// - parameter animatedUrl: Url with animated gif image
    /// - parameter displacedView: View that should be displaced.
    init(animatedUrl: URL?, displacedView: UIImageView?) {
        self.imageUrls = nil
        self.displacedView = displacedView
        self.animatedUrl = animatedUrl
    }
    
}

extension GalleryViewProvider: GalleryItemsDatasource {
    
    public func itemCount() -> Int {
        if let imageUrls = imageUrls {
            return imageUrls.count
        } else if animatedUrl != nil {
            return 1
        }
        return 0
    }
    
    public func provideGalleryItem(_ index: Int) -> GalleryItem {
        return galleryItems[index]
    }
}

extension GalleryViewProvider: GalleryDisplacedViewsDatasource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        return displacedView
    }
}

extension UIImageView: DisplaceableView {/* Empty by design */}
