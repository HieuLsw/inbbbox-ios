//
//  UnderlineBarView.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class UnderlineBarView: UIView {

    fileprivate let fillView = UIView()
    fileprivate var didSetConstraints = false

    fileprivate var widthContraint: NSLayoutConstraint?
    fileprivate var leadingContraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        fillView.backgroundColor = UIColor.pinkColor()

        addSubview(fillView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            leadingContraint = fillView.autoPinEdge(toSuperviewEdge: .leading, withInset: 0)
            widthContraint = fillView.autoSetDimension(.width, toSize: 0)

            fillView.autoPinEdge(toSuperviewEdge: .top)
            fillView.autoPinEdge(toSuperviewEdge: .bottom)
        }

        super.updateConstraints()
    }

    // MARK: public

    func underline(frame: CGRect) {

        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.leadingContraint?.constant = frame.origin.x
            self.widthContraint?.constant = frame.width
            self.layoutIfNeeded()
        }, completion: nil)
    }
}
