//
//  LoginViewAnimations.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 19/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Async

class LoginViewAnimations {

    fileprivate var buttonPositionDelta: (x: CGFloat, width: CGFloat)!
    fileprivate var logoPositionDeltaX: CGFloat!
    fileprivate var shouldAnimate = false

    enum FadeStyle: CGFloat {
        case fadeIn = 1
        case fadeOut = 0
    }

    func prepare() {
        shouldAnimate = true
    }

    func stop() {
        shouldAnimate = false
    }

    func animateCornerRadiusForthAndBack(_ view: UIView) {

        let endValue = view.frame.height * 0.5

        UIView.promise(animateWithDuration: 0.2) { 
            view.layer.cornerRadius = 4
        }.then { _ in
            UIView.animate(withDuration: 0.5, animations: { 
                view.layer.cornerRadius = endValue
            })
        }.catch { _ in }
    }

    func animateSpringShrinkingToBall(_ button: UIView, logo: UIView, completion: @escaping () -> Void) {

        let dimension = button.frame.height
        let deltaX = button.superview!.bounds.midX - dimension *
                0.5 - button.frame.minX

        buttonPositionDelta = (x: deltaX, width: button.frame.width)
        logoPositionDeltaX = logo.superview!.bounds.midX - logo.frame.midX

        UIView.animate(withDuration: 1.5, delay: 0.0,
                usingSpringWithDamping: 0.25, initialSpringVelocity: 0.0,
                options: [], animations: {

            button.layer.position.x += deltaX
            button.layer.frame.size.width = dimension
            logo.layer.position.x += self.logoPositionDeltaX

        }, completion: { _ in
            completion()
        })
    }

    func animateSpringExtendingToButton(_ button: UIView, logo: UIView, completion: @escaping () -> Void) {

        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.25,
                initialSpringVelocity: 0.0, options: [], animations: {

            button.layer.position.x -= self.buttonPositionDelta.x
            button.layer.frame.size.width = self.buttonPositionDelta.width
            logo.layer.position.x -= self.logoPositionDeltaX

        }, completion: { _ in
            completion()
        })
    }

    func rotationAnimation(_ views: [UIView], duration: TimeInterval, cycles: Double) {

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(M_PI * 2.0 * cycles * duration)
        rotationAnimation.duration = duration
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 1.0
        rotationAnimation.timingFunction =
                CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        views.forEach {
            $0.layer.add(rotationAnimation, forKey: nil)
        }
    }

    func moveAnimation(_ views: [UIView], duration: TimeInterval,
            fade: FadeStyle, easeFunction: UIViewAnimationOptions = .curveEaseIn,
            transition: CGPoint, completion: (() -> Void)? = nil) {

        UIView.animate(withDuration: duration, delay: 0, options: [easeFunction], animations: {
            views.forEach {
                let frame = CGRect(
                    x: $0.frame.minX + transition.x,
                    y: $0.frame.minY + transition.y,
                    width: $0.frame.width,
                    height: $0.frame.height
                )

                $0.frame = frame
                $0.alpha = fade.rawValue
            }
        }, completion: { _ in
            completion?()
        })
    }

    func blinkAnimation(_ views: [UIView], duration: TimeInterval) {

        if !shouldAnimate {
            return
        }

        Async.main(after: duration) {
            self.blinkAnimation(views, duration: duration)
        }

        UIView.animate(withDuration: duration * 0.5, animations: {
            views.forEach { $0.alpha = 0.5 }
        }, completion: { _ in
            UIView.animate(withDuration: duration * 0.5, animations: { views.forEach { $0.alpha = 1.0 } }) 
        })
    }

    func bounceAnimation(_ views: [UIView], duration: TimeInterval, additionalYOffset: Bool) {

        guard shouldAnimate else { return }

        Async.main(after: duration) {
            self.bounceAnimation(views, duration: duration, additionalYOffset: additionalYOffset)
        }
        let maxY = additionalYOffset ? 100 : 70

        let animations = CAKeyframeAnimation.ballBounceAnimations(maxY, duration: duration)

        views.forEach { view in
            animations.forEach { animation in
                view.layer.add(animation, forKey: nil)
            }
        }
    }
}
