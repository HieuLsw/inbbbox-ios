//
//  AnimatableShotImageView.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 02.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout
import FLAnimatedImage
import Haneke
import Async

class AnimatableShotImageView: FLAnimatedImageView {
    let downloader = DataDownloader()
    private let progressAnimator = ProgressAnimator(imageBaseName: "loadgif_", imageCount: 59)
    private var didSetupConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .whiteColor()
        contentMode = .ScaleAspectFill
        progressAnimator.progressImageView.configureForAutoLayout()
        progressAnimator.progressImageView.backgroundColor = .whiteColor()
        addSubview(progressAnimator.progressImageView)
    }

    @available(*, unavailable, message = "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetupConstraints {
            didSetupConstraints = true

            progressAnimator.progressImageView.autoAlignAxisToSuperviewAxis(.Horizontal)
            let progressInset = CGFloat(10)
            progressAnimator.progressImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: progressInset)
            progressAnimator.progressImageView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: progressInset)
            progressAnimator.progressImageView.autoMatchDimension(.Height, toDimension: .Width,
                                                                  ofView: progressAnimator.progressImageView,
                                                                  withMultiplier: 0.3563218391)
        }

        super.updateConstraints()
    }

    func loadAnimatableShotFromUrl(url: NSURL) {
        Shared.dataCache.fetch(key: url.absoluteString, formatName: CacheManager.gifFormatName, failure: {
            _ in
            self.fetchWithURL(url)
        }, success: {
            data in
            self.setImageWithData(data)
        })
    }

    private func fetchWithURL(url: NSURL) {
        downloader.fetchData(url, progress: {
            [weak self] progress in
            self?.updateWithProgress(progress)
        }) {
            [weak self] data in
            self?.setImageWithData(data)
            Shared.dataCache.set(value: data, key: url.absoluteString, formatName: CacheManager.gifFormatName,
                    success: nil)
        }
    }

    private func setImageWithData(data: NSData) {
        Async.main {
            self.progressAnimator.progressImageView.hidden = true
            self.animatedImage = FLAnimatedImage(animatedGIFData: data)
        }
    }

    private func updateWithProgress(progress: Float) {
        Async.main {
            self.progressAnimator.updateProgress(progress)
        }
    }
}
