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
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)

    fileprivate var didSetupConstraints = false
    fileprivate var imageUrl: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .cellBackgroundColor()
        contentMode = .scaleAspectFill

        addSubview(activityIndicatorView)
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetupConstraints {
            didSetupConstraints = true

            activityIndicatorView.autoCenterInSuperview()
        }

        super.updateConstraints()
    }

    func loadShotImageFromURL(_ url: URL, blur: CGFloat = 0) {
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

    func applyBlur(_ blur: CGFloat = 0) {
        if blur == 0 {
            self.image = originalImage
            return
        }
        let bluredImageUrl = imageUrl?.copy()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { [weak self] in
            let bluredImage = self?.originalImage?.imageByBlurringImageWithBlur(blur)
            DispatchQueue.main.async(execute: {
                if self?.imageUrl?.absoluteString == (bluredImageUrl as AnyObject).absoluteString {
                    self?.image = bluredImage
                }
            })
        })
    }
}
