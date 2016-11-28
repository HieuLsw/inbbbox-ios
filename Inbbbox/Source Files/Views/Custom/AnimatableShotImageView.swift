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
    fileprivate let progressAnimator = ProgressAnimator(imageBaseName: "loadgif_", imageCount: 59)
    fileprivate var didSetupConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        contentMode = .scaleAspectFill
        progressAnimator.progressImageView.configureForAutoLayout()
        progressAnimator.progressImageView.backgroundColor = .white
        addSubview(progressAnimator.progressImageView)
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

            progressAnimator.progressImageView.autoAlignAxis(toSuperviewAxis: .horizontal)
            let progressInset = CGFloat(10)
            progressAnimator.progressImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: progressInset)
            progressAnimator.progressImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: progressInset)
            progressAnimator.progressImageView.autoMatch(.height, to: .width,
                                                                  of: progressAnimator.progressImageView,
                                                                  withMultiplier: 0.3563218391)
        }

        super.updateConstraints()
    }

    func loadAnimatableShotFromUrl(_ url: URL) {
        Shared.dataCache.fetch(key: url.absoluteString, formatName: CacheManager.gifFormatName, failure: {
            _ in
            self.fetchWithURL(url)
        }, success: {
            data in
            self.setImageWithData(data)
        })
    }

    fileprivate func fetchWithURL(_ url: URL) {
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

    fileprivate func setImageWithData(_ data: Data) {
        Async.main {
            self.progressAnimator.progressImageView.isHidden = true
            self.animatedImage = FLAnimatedImage(animatedGIFData: data)
        }
    }

    fileprivate func updateWithProgress(_ progress: Float) {
        Async.main {
            self.progressAnimator.updateProgress(progress)
        }
    }
}
