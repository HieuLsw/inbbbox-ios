//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

enum AnimationType {
    case plain
    case spring
}

/// AnimationDescriptor hold all necessary information to perform animation.
/// Used for ShotCollectionViewCell swipe animations.
protocol AnimationDescriptor {

    /// Type of animation, can be Plain or Spring.
    var animationType: AnimationType { get set }

    /// Animation duration value.
    /// Default is 0.3.
    var duration: TimeInterval { get }

    /// Animation delay value.
    var delay: TimeInterval { get set }

    /// Animation spring damping value.
    /// Default is 0.0.
    var springDamping: CGFloat { get }

    /// Animation spring velocity value.
    /// Default is 0.0.
    var springVelocity: CGFloat { get }

    /// Animation options.
    var options: UIViewAnimationOptions { get set }

    /// Closure where all animations will be performed on ShotCollectionViewCell.
    var animations: () -> Void { get set }

    /// Completion closure will be invoked after animations finishes.
    var completion: ((Bool) -> Void)? { get set }


    /// Initialize animation descriptor with ShotCollectionViewCell and completion.
    ///
    /// - parameter shotCell:           Cell on which animations will be perfomed.
    /// - parameter swipeCompletion:    Closure which will be perfomed after animation finishes.
    init(shotCell: ShotCollectionViewCell, swipeCompletion: (() -> ())?)
}


/// Default values for AnimationDescriptor
extension AnimationDescriptor {
    var springDamping: CGFloat {
        return 0.0
    }
    var springVelocity: CGFloat {
        return 0.0
    }
    var duration: TimeInterval {
        return 0.3
    }
}
