//
//  GifIndicatorView.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 23.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class GifIndicatorView: UIView {

    let gifLabel = UILabel()
    let vibrancyGifView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    fileprivate var didSetConstraints = false

    // MARK: - Life cycle

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        gifLabel.configureForAutoLayout()
        gifLabel.text = NSLocalizedString("GifIndicatorView.GIF", comment: "GIF file type.")
        gifLabel.font = UIFont.helveticaFont(.neueMedium, size: 11)
        gifLabel.textColor = UIColor.textDarkColor()
        gifLabel.textAlignment = .center

        vibrancyGifView.contentView.addSubview(gifLabel)
        vibrancyGifView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        vibrancyGifView.layer.cornerRadius = 4
        vibrancyGifView.clipsToBounds = true
        self.addSubview(vibrancyGifView)
    }

    override func updateConstraints() {
        if !didSetConstraints {
            didSetConstraints = true

            gifLabel.autoPinEdgesToSuperviewEdges()
            vibrancyGifView.autoPinEdgesToSuperviewEdges()
            autoSetDimension(.width, toSize: 30)
            autoSetDimension(.height, toSize: 20)
        }
        super.updateConstraints()
    }

}
