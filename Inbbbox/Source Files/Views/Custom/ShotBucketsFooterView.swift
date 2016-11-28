//
//  ShotBucketsFooterView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 25/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsFooterView: UICollectionReusableView {

    fileprivate let separatorLine = UIView.newAutoLayout()

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        separatorLine.configureForAutoLayout()
        separatorLine.backgroundColor = ColorModeProvider.current().cellSeparator
        addSubview(separatorLine)

    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            separatorLine.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            separatorLine.autoSetDimension(.height, toSize: 0.5)
        }

        super.updateConstraints()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 15, height: 15))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension ShotBucketsFooterView: Reusable {

    class var identifier: String {
        return String(describing: ShotBucketsFooterView.self)
    }
}
