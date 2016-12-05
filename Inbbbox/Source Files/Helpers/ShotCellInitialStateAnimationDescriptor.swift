//
//  ShotCellInitialStateAnimationDescriptor.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 2/8/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

struct ShotCellInitialStateAnimationDescriptor: AnimationDescriptor {

    weak var shotCell: ShotCollectionViewCell?
    var animationType = AnimationType.Spring
    var delay = 0.0
    var springDamping = CGFloat(0.6)
    var springVelocity = CGFloat(0.9)
    var options: UIViewAnimationOptions = .CurveEaseInOut
    var animations: () -> Void
    var completion: ((Bool) -> Void)?

    init(shotCell: ShotCollectionViewCell, swipeCompletion: (() -> ())?) {
        self.shotCell = shotCell
        animations = {
            shotCell.shotImageView.transform = CGAffineTransformIdentity
        }
        completion = { _ in
            shotCell.likeImageView.hidden = false
            shotCell.bucketImageView.hidden = false
            shotCell.plusImageView.hidden = false
            shotCell.commentImageView.hidden = false
            shotCell.followImageView.hidden = false
            shotCell.messageLabel.alpha = 0
            swipeCompletion?()
        }
    }
}
