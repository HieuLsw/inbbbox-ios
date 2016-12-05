//
//  ShotBucketsFooterView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 25/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsFooterView: UICollectionReusableView {

    private let separatorLine = UIView.newAutoLayoutView()

    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        separatorLine.configureForAutoLayout()
        separatorLine.backgroundColor = ColorModeProvider.current().cellSeparator
        addSubview(separatorLine)

    }

    @available(*, unavailable, message = "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            separatorLine.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            separatorLine.autoSetDimension(.Height, toSize: 0.5)
        }

        super.updateConstraints()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.BottomLeft, .BottomRight],
                cornerRadii: CGSize(width: 15, height: 15))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        layer.mask = mask
    }
}

extension ShotBucketsFooterView: Reusable {

    class var reuseIdentifier: String {
        return String(ShotBucketsFooterView)
    }
}
