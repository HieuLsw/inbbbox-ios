//
//  ShotDetailsFooterView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 02/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

private var cornerRadius: CGFloat {
    return 30
}

private var footerBottomEdgeSpace: CGFloat {
    return 20
}

class ShotDetailsFooterView: UICollectionReusableView {

    class var minimumRequiredHeight: CGFloat {
        return cornerRadius + footerBottomEdgeSpace
    }

    private var didUpdateConstraints = false
    private let activityIndicatorView: BouncingView
    private let cornerWrapperView = UIView.newAutoLayoutView()

    override init(frame: CGRect) {
        let height = Int(cornerRadius)
        activityIndicatorView = BouncingView(frame: frame, jumpHeight: height, jumpDuration: NSTimeInterval(1))
        super.init(frame: frame)

        backgroundColor = .clearColor()

        activityIndicatorView.configureForAutoLayout()

        cornerWrapperView.backgroundColor = .whiteColor()
        cornerWrapperView.addSubview(activityIndicatorView)
        addSubview(cornerWrapperView)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message = "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let radii = CGSize(width: cornerRadius, height: cornerRadius)
        let path = UIBezierPath(roundedRect: cornerWrapperView.bounds, byRoundingCorners: [.BottomLeft, .BottomRight],
                cornerRadii: radii)
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        layer.mask = mask
    }

    override func updateConstraints() {
        if !didUpdateConstraints {
            didUpdateConstraints = true

            cornerWrapperView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            cornerWrapperView.autoSetDimension(.Height, toSize: cornerRadius)

            activityIndicatorView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    func startAnimating() {
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
    }

    func grayOutBackground(grayOut: Bool) {
        let currentMode = ColorModeProvider.current()
        cornerWrapperView.backgroundColor = grayOut ? currentMode.tableViewBackground : currentMode.shotBucketsFooterViewBackground
    }
}

extension ShotDetailsFooterView: Reusable {

    class var reuseIdentifier: String {
        return String(ShotDetailsFooterView)
    }
}
