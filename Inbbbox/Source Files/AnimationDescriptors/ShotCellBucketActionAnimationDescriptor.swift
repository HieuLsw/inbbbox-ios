//
//  ShotCellBucketActionAnimationDescriptor.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 10.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

struct ShotCellBucketActionAnimationDescriptor: AnimationDescriptor {

    weak var shotCell: ShotCollectionViewCell?
    var animationType = AnimationType.Plain
    var delay = 0.0
    var options: UIViewAnimationOptions = []
    var animations: () -> Void
    var completion: ((Bool) -> Void)?

    init(shotCell: ShotCollectionViewCell, swipeCompletion: (() -> ())?) {
        self.shotCell = shotCell
        animations = {
            let contentViewWidht = CGRectGetWidth(shotCell.contentView.bounds)
            shotCell.likeImageViewLeftConstraint?.constant = round(contentViewWidht / 2 -
                    (shotCell.likeImageView.intrinsicContentSize().width +
                            shotCell.plusImageView.intrinsicContentSize().width +
                            shotCell.bucketImageView.intrinsicContentSize().width + 2 * 15) / 2)
            shotCell.likeImageViewWidthConstraint?.constant =
                    shotCell.likeImageView.intrinsicContentSize().width
            shotCell.likeImageViewWidthConstraint?.constant =
                    shotCell.likeImageView.intrinsicContentSize().width
            shotCell.plusImageViewWidthConstraint?.constant =
                    shotCell.plusImageView.intrinsicContentSize().width
            shotCell.bucketImageViewWidthConstraint?.constant =
                    shotCell.bucketImageView.intrinsicContentSize().width
            shotCell.contentView.layoutIfNeeded()
            shotCell.likeImageView.alpha = 1.0
            shotCell.shotImageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                    contentViewWidht, 0)
            shotCell.likeImageView.displaySecondImageView()
            shotCell.messageLabel.alpha = 1
        }
        completion = { _ in
            var delayedRestoreInitialStateAnimationDescriptor =
                    ShotCellInitialStateAnimationDescriptor(shotCell: shotCell,
                                                     swipeCompletion: swipeCompletion)
            delayedRestoreInitialStateAnimationDescriptor.delay = 0.5
            shotCell.viewClass.animateWithDescriptor(delayedRestoreInitialStateAnimationDescriptor)
        }
    }
}
