//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIView {

    /// Animate UIView with descriptor
    ///
    /// - parameter animationDescriptor: animation descriptor with values for animation aspects.
    class func animateWithDescriptor(_ animationDescriptor: AnimationDescriptor) {
        let duration = animationDescriptor.duration
        let delay = animationDescriptor.delay
        let options = animationDescriptor.options
        let animationType = animationDescriptor.animationType
        let animations = animationDescriptor.animations
        let completion = animationDescriptor.completion

        switch animationType {
        case AnimationType.plain:
            self.animate(withDuration: duration,
                              delay: delay,
                            options: options,
                         animations: animations,
                         completion: completion)
        case AnimationType.spring:
            let springDamping = animationDescriptor.springDamping
            let springVelocity = animationDescriptor.springVelocity
            self.animate(withDuration: duration,
                              delay: delay,
             usingSpringWithDamping: springDamping,
              initialSpringVelocity: springVelocity,
                            options: options,
                         animations: animations,
                         completion: completion)
        }
    }
}
