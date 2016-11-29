//
//  CAKeyframeAnimationExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension CAKeyframeAnimation {

    /// Class method used to perform ball bounce animation.
    ///
    /// - parameter jumpHeight: Defines how height ball should jump.
    /// - parameter duration:   Animation duration.
    ///
    /// - returns: Array of animations to perform.
    class func ballBounceAnimations(_ jumpHeight: Int, duration: TimeInterval)
                    -> [CAKeyframeAnimation] {

        let translationY = CAKeyframeAnimation(keyPath: "transform.translation.y")
        translationY.values = [0, jumpHeight, 0]
        translationY.keyTimes = [0, 0.45, 1]
        translationY.timingFunction = CAMediaTimingFunction(controlPoints: 0.7, 0.2, 0.3, 0.8)
        translationY.duration = duration
        translationY.repeatCount = 1

        let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
        scaleX.values = [1, 0.95, 1.1, 0.95, 1.0]
        scaleX.keyTimes = [0, 0.44, 0.48, 0.52, 1]
        scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        scaleX.duration = duration
        scaleX.repeatCount = 1

        let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleY.values = [1, 1.1, 0.9, 1.1, 1]
        scaleY.keyTimes = [0, 0.44, 0.48, 0.52, 1]
        scaleY.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        scaleY.duration = duration
        scaleY.repeatCount = 1

        return [translationY, scaleX, scaleY]
    }
}
