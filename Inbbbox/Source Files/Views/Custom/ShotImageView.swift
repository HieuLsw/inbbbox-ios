//
//  ShotImageView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 12/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout
import Haneke

class ShotImageView: UIImageView {

    var originalImage: UIImage?
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)

    private var didSetupConstraints = false
    private var imageUrl: NSURL?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .cellBackgroundColor()
        contentMode = .ScaleAspectFill

        addSubview(activityIndicatorView)
    }

    @available(*, unavailable, message="Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetupConstraints {
            didSetupConstraints = true

            activityIndicatorView.autoCenterInSuperview()
        }

        super.updateConstraints()
    }

    func loadShotImageFromURL(url: NSURL, blur: CGFloat = 0) {
        imageUrl = url
        image = nil
        originalImage = nil
        activityIndicatorView.startAnimating()
        Shared.imageCache.fetch(URL: url, formatName: CacheManager.imageFormatName, failure: nil) { [weak self] image in
            self?.activityIndicatorView.stopAnimating()
            self?.image = image
            self?.originalImage = image
            self?.applyBlur()
        }
    }

    func applyBlur(blur: CGFloat = 0) {
        if blur == 0 {
            self.image = originalImage
            return
        }
        let bluredImageUrl = imageUrl?.copy()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { [weak self] in
            let bluredImage = self?.originalImage?.imageByBlurringImageWithBlur(blur)
            dispatch_async(dispatch_get_main_queue(), {
                if self?.imageUrl?.absoluteString == bluredImageUrl?.absoluteString {
                    self?.image = bluredImage
                }
            })
        })
    }
}
