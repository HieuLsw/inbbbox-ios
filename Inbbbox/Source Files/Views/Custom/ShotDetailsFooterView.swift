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

class ShotDetailsFooterView: UICollectionReusableView, Reusable {

    class var minimumRequiredHeight: CGFloat {
        return cornerRadius + footerBottomEdgeSpace
    }

    fileprivate var didUpdateConstraints = false
    fileprivate let activityIndicatorView: BouncingView
    fileprivate let cornerWrapperView = UIView.newAutoLayout()

    override init(frame: CGRect) {
        let height = Int(cornerRadius) - 15
        activityIndicatorView = BouncingView(frame: frame, jumpHeight: height, jumpDuration: TimeInterval(1))
        super.init(frame: frame)

        backgroundColor = .clear

        activityIndicatorView.configureForAutoLayout()

        cornerWrapperView.backgroundColor = .white
        cornerWrapperView.addSubview(activityIndicatorView)
        addSubview(cornerWrapperView)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let radii = CGSize(width: cornerRadius, height: cornerRadius)
        let path = UIBezierPath(roundedRect: cornerWrapperView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: radii)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    override func updateConstraints() {
        if !didUpdateConstraints {
            didUpdateConstraints = true

            cornerWrapperView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            cornerWrapperView.autoSetDimension(.height, toSize: cornerRadius + 5)

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

    func grayOutBackground(_ grayOut: Bool) {
        let currentMode = ColorModeProvider.current()
        cornerWrapperView.backgroundColor = grayOut ? currentMode.tableViewBackground : currentMode.shotBucketsFooterViewBackground
    }
}
