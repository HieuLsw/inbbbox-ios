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
    var animationType = AnimationType.spring
    var delay = 0.0
    var springDamping = CGFloat(0.6)
    var springVelocity = CGFloat(0.9)
    var options: UIViewAnimationOptions = UIViewAnimationOptions()
    var animations: () -> Void
    var completion: ((Bool) -> Void)?

    init(shotCell: ShotCollectionViewCell, swipeCompletion: (() -> ())?) {
        self.shotCell = shotCell
        animations = {
            shotCell.shotImageView.transform = CGAffineTransform.identity
        }
        completion = { _ in
            shotCell.likeImageView.isHidden = false
            shotCell.bucketImageView.isHidden = false
            shotCell.plusImageView.isHidden = false
            shotCell.commentImageView.isHidden = false
            shotCell.followImageView.isHidden = false
            shotCell.messageLabel.alpha = 0
            swipeCompletion?()
        }
    }
}
