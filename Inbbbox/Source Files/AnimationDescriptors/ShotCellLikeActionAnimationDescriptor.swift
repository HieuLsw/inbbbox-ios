//
//  ShotCellLikeActionAnimationDescriptor.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/8/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

struct ShotCellLikeActionAnimationDescriptor: AnimationDescriptor {

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
            shotCell.likeImageViewLeftConstraint?.constant =
                    round(contentViewWidht / 2 -
                    shotCell.likeImageView.intrinsicContentSize().width / 2)
            shotCell.likeImageViewWidthConstraint?.constant =
                    shotCell.likeImageView.intrinsicContentSize().width
            shotCell.contentView.layoutIfNeeded()
            shotCell.likeImageView.alpha = 1.0
            shotCell.shotImageView.transform =
                    CGAffineTransformTranslate(CGAffineTransformIdentity, contentViewWidht, 0)
            shotCell.likeImageView.displaySecondImageView()
        }
        completion = { _ in
            var delayedRestoreInitialStateAnimationDescriptor =
                    ShotCellInitialStateAnimationDescriptor(shotCell: shotCell,
                                                     swipeCompletion: swipeCompletion)
            delayedRestoreInitialStateAnimationDescriptor.delay = 0.2
            shotCell.viewClass.animateWithDescriptor(delayedRestoreInitialStateAnimationDescriptor)
        }
    }
}
