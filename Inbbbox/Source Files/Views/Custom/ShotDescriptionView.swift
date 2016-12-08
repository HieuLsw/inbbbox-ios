//
//  ShotDescriptionView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 14/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotDescriptionView: UIView {

    // Public
    var descriptionText: NSMutableAttributedString? {
        didSet {
            descriptionLabel.text = descriptionText?.string
            setNeedsLayout()
            setNeedsUpdateConstraints()
        }
    }

    // Private Properties
    fileprivate var didUpdateConstraints = false
    fileprivate let topInset = CGFloat(10)
    fileprivate let bottomInset = CGFloat(10)

    // Colors
    fileprivate let viewBackgroundColor = UIColor.white

    // Private UI Components
    fileprivate let topSeparatorLine = UIView.newAutoLayout()
    fileprivate let descriptionLabel = UILabel()
    fileprivate let bottomSeparatorLine = UIView.newAutoLayout()

    // MARK: Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = viewBackgroundColor
        setupSubviews()
    }

    @available(*, unavailable, message: "Use init(frame: CGRect) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        let leftAndRightInset = CGFloat(20)
        let separatorLinesHeight = CGFloat(1)

        if !didUpdateConstraints {

            topSeparatorLine.autoPinEdge(toSuperviewEdge: .top)
            topSeparatorLine.autoSetDimension(.height, toSize: separatorLinesHeight)
            topSeparatorLine.autoPinEdge(toSuperviewEdge: .left)
            topSeparatorLine.autoPinEdge(toSuperviewEdge: .right)

            descriptionLabel.autoPinEdge(.top, to: .bottom, of: topSeparatorLine, withOffset: topInset)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: leftAndRightInset)
            descriptionLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: leftAndRightInset)

            bottomSeparatorLine.autoPinEdge(.top, to: .bottom, of: descriptionLabel, withOffset: bottomInset)
            bottomSeparatorLine.autoSetDimension(.height, toSize: separatorLinesHeight)
            bottomSeparatorLine.autoPinEdge(toSuperviewEdge: .left)
            bottomSeparatorLine.autoPinEdge(toSuperviewEdge: .right)
            bottomSeparatorLine.autoPinEdge(toSuperviewEdge: .bottom)

            didUpdateConstraints = true
        }

        super.updateConstraints()
    }

    // MARK: Private

    fileprivate func setupSubviews() {
        setupDescriptionLabel()
        setupSeparatorLines()
    }

    fileprivate func setupDescriptionLabel() {
        descriptionLabel.text = descriptionText?.string
        descriptionLabel.font = UIFont.sanFransiscoFont(withType: .regular, size: 15)
        descriptionLabel.textColor = UIColor.textLightColor()
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = backgroundColor
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.tintColor = UIColor.textLightColor()
        addSubview(descriptionLabel)
    }

    fileprivate func setupSeparatorLines() {
        topSeparatorLine.backgroundColor = UIColor.RGBA(223, 224, 226, 1)
        bottomSeparatorLine.backgroundColor = UIColor.RGBA(223, 224, 226, 1)
        addSubview(topSeparatorLine)
        addSubview(bottomSeparatorLine)
    }
}
