//
//  EmptyDataSetLoadingView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 23/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Async

class EmptyDataSetLoadingView: UIView {

    let ballView: BouncingView
    let label = UILabel()
    let animator = LoginViewAnimations()

    fileprivate var shouldAnimate = false
    fileprivate let animationDuration = TimeInterval(1)
    fileprivate let ballJumpHeight = 50

    override init(frame: CGRect) {
        var frame = frame
        frame = CGRect(
            x: frame.minX,
            y: frame.minY,
            width: 200,
            height: 200
        )
        ballView = BouncingView(frame: frame, jumpHeight: ballJumpHeight, jumpDuration: animationDuration)
        super.init(frame: frame)

        addSubview(ballView)

        label.text = NSLocalizedString("EmptyDataSetLoadingView.Loading", comment: "Loading view, when empty data")
        label.textColor = .cellBackgroundColor()
        label.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightMedium)
        label.textAlignment = .center
        label.alpha = 0.5
        addSubview(label)

    }
    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {

        // made on Rects because of complex animation of jumping ball, same comment as in LoginView
        let labelSize = CGSize(width: frame.width, height: 30)
        label.frame = CGRect(
            x: frame.maxX / 2 - labelSize.width / 2,
            y: frame.maxY / 2,
            width: labelSize.width,
            height: labelSize.height
        )

        let size = ballView.imageView.image?.size ?? CGSize.zero
        ballView.frame = CGRect(
            x: frame.maxX / 2 - size.width / 2,
            y: label.frame.minY - size.height - CGFloat(ballJumpHeight),
            width: size.width,
            height: size.height
        )
    }

    func startAnimating() {
        shouldAnimate =  true
        ballView.startAnimating()
        blinkLoadingLabel()
    }

    func stopAnimating() {
        shouldAnimate = false
    }

    fileprivate func blinkLoadingLabel() {

        guard shouldAnimate else { return }

        Async.main(after: animationDuration) {
            self.blinkLoadingLabel()
        }

        UIView.animate(withDuration: animationDuration * 0.5, animations: {
            self.label.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: self.animationDuration * 0.5, animations: { self.label.alpha = 0.5 }) 
        })
    }
}
