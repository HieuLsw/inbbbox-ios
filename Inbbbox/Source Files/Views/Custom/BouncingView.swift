//
//  BouncingView.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 19.04.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import Async

/// Creates view with vertical bounce animation.
class BouncingView: UIView, DefaultImage {

    /// Container for representing view by its image.
    var imageView = UIImageView()

    /// Defines maximum vertical height for view jumps.
    var jumpHeight: Int

    /// Defines duration between jumps.
    var jumpDuration: TimeInterval

    /// Defines whether view is hidden when the animation is stopped.
    var hidesWhenStopped = true

    /// Defines whether view should animate. This value is read-only.
    /// Set to true after invoking `startAnimating()`.
    /// Set to false after invoking `stopAnimating()`
    /// - SeeAlso: startAnimating(), stopAnimating()
    fileprivate(set) var shouldAnimate = false

    fileprivate var didSetupConstraints = false

    // MARK: Life Cycle

    init(frame: CGRect, jumpHeight: Int, jumpDuration: TimeInterval, image: UIImage? = nil) {
        self.jumpHeight = jumpHeight
        self.jumpDuration = jumpDuration
        super.init(frame: frame)
        if let image = image {
            imageView = UIImageView(image: image)
        } else {
            imageView = UIImageView(image: defaultImage)
        }
        addSubview(imageView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {
        if !didSetupConstraints {
            imageView.autoPinEdge(toSuperviewEdge: .top)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
            didSetupConstraints = true
        }

        super.updateConstraints()
    }

    // MARK: Public

    /// Starts the animation.
    /// - SeeAlso: shouldAnimate, hidesWhenStopped
    func startAnimating() {
        shouldAnimate = true
        isHidden = false
        animateBall()
    }

    /// Stops the animation.
    /// - SeeAlso: shouldAnimate, hidesWhenStopped
    func stopAnimating() {
        shouldAnimate = false
        isHidden = true
    }

    // MARK: Private

    fileprivate func animateBall() {

        guard shouldAnimate else { return }

        Async.main(after: TimeInterval(jumpDuration)) {
            self.animateBall()
        }

        let animations = CAKeyframeAnimation.ballBounceAnimations(jumpHeight, duration: jumpDuration)

        animations.forEach { animation in
            imageView.layer.add(animation, forKey: nil)
        }
    }
}
