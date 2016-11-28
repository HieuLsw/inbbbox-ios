//
//  ShotBucketsSeparatorCollectionViewCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 25/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsSeparatorCollectionViewCell: UICollectionViewCell {

    fileprivate let cellHeight = CGFloat(20)

    fileprivate let topSeparatorLine = UIView.newAutoLayout()
    fileprivate let bottomSeparatorLine = UIView.newAutoLayout()

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureForAutoLayout()

        contentView.configureForAutoLayout()
        let currentMode = ColorModeProvider.current()
        topSeparatorLine.configureForAutoLayout()
        topSeparatorLine.backgroundColor = currentMode.cellSeparator
        contentView.addSubview(topSeparatorLine)

        bottomSeparatorLine.configureForAutoLayout()
        bottomSeparatorLine.backgroundColor = currentMode.cellSeparator
        contentView.addSubview(bottomSeparatorLine)

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let separatorLineHeight = CGFloat(0.5)

            topSeparatorLine.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            topSeparatorLine.autoSetDimension(.height, toSize: separatorLineHeight)

            bottomSeparatorLine.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
            bottomSeparatorLine.autoSetDimension(.height, toSize: separatorLineHeight)

            contentView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
                    -> UICollectionViewLayoutAttributes {

        layoutAttributes.frame = {

            var frame = layoutAttributes.frame
            frame.size.height = cellHeight

            return frame.integral
        }()

        return layoutAttributes
    }
}

extension ShotBucketsSeparatorCollectionViewCell: Reusable {

    class var identifier: String {
        return String(describing: ShotBucketsSeparatorCollectionViewCell.self)
    }
}
