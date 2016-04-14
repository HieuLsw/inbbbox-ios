//
//  ShotCellCommentActionAnimationDescriptor.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 10.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

struct ShotCellCommentActionAnimationDescriptor: AnimationDescriptor {

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
            shotCell.commentImageViewRightConstraint?.constant = -round(contentViewWidht / 2 - shotCell.commentImageView.intrinsicContentSize().width / 2)
            shotCell.commentImageViewWidthConstraint?.constant = shotCell.commentImageView.intrinsicContentSize().width
            shotCell.contentView.layoutIfNeeded()
            shotCell.shotImageView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -contentViewWidht, 0)
        }
        completion = { _ in
            var delayedRestoreInitialStateAnimationDescriptor = ShotCellInitialStateAnimationDescriptor(shotCell: shotCell, swipeCompletion: swipeCompletion)
            delayedRestoreInitialStateAnimationDescriptor.delay = 0.2
            shotCell.viewClass.animateWithDescriptor(delayedRestoreInitialStateAnimationDescriptor)
        }
    }
}
