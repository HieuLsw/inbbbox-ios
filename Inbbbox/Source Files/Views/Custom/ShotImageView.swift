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
        _ = Shared.imageCache.fetch(URL: url, formatName: CacheManager.imageFormatName, failure: nil) { [weak self] image in
            self?.activityIndicatorView.stopAnimating()
            self?.image = image
            self?.originalImage = image
            self?.applyBlur()
        }
    }

    func applyBlur(_ blur: CGFloat = 0) {
        guard blur > 0 else {
            self.image = originalImage
            return
        }
        
        let blurredImageUrl = imageUrl

        DispatchQueue.global(qos: .default).async { [weak self] in
           let blurredImage = self?.originalImage?.imageByBlurringImageWithBlur(blur)
            DispatchQueue.main.async(execute: {
                guard let blurredImage = blurredImage else { return }
                if self?.imageUrl?.absoluteString == blurredImageUrl?.absoluteString {
                    self?.image = blurredImage
                }
            })
        }
    }
}
