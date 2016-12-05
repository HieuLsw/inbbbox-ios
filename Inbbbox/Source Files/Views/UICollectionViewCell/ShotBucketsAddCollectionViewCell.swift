//
//  ShotBucketsAddCollectionViewCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsAddCollectionViewCell: UICollectionViewCell {

    let bucketNameLabel = UILabel.newAutoLayoutView()
    let shotsCountLabel = UILabel.newAutoLayoutView()
    private let arrowImageView = UIImageView.newAutoLayoutView()
    private let separatorLine = UIView.newAutoLayoutView()

    // Size properties
    private let minimumCellHeight = CGFloat(44)
    private let contentLeftAndRightInset = CGFloat(15)
    private var elementsOffset = CGFloat(10)

    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureForAutoLayout()

        contentView.configureForAutoLayout()
        let currentMode = ColorModeProvider.current()
        bucketNameLabel.configureForAutoLayout()
        bucketNameLabel.numberOfLines = 0
        bucketNameLabel.textColor = currentMode.shotDetailsBucketTextColor
        bucketNameLabel.font = UIFont.helveticaFont(.Neue, size: 17)
        contentView.addSubview(bucketNameLabel)

        shotsCountLabel.configureForAutoLayout()
        shotsCountLabel.numberOfLines = 1
        shotsCountLabel.textColor = .followeeTextGrayColor()
        shotsCountLabel.font = UIFont.helveticaFont(.Neue, size: 17)
        contentView.addSubview(shotsCountLabel)

        arrowImageView.image = UIImage(named: "ic-indicator-right")
        contentView.addSubview(arrowImageView)

        separatorLine.backgroundColor = currentMode.cellSeparator
        contentView.addSubview(separatorLine)
        separatorLine.hidden = true

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message = "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bucketNameLabel.preferredMaxLayoutWidth = {
            var maxLayoutWidth = frame.size.width
            maxLayoutWidth -= shotsCountLabel.frame.size.width
            maxLayoutWidth -= arrowImageView.frame.size.width
            maxLayoutWidth -= 2 * contentLeftAndRightInset
            maxLayoutWidth -= 2 * elementsOffset
            return maxLayoutWidth
        }()
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let contentTopAndBottomInset = CGFloat(10)

            bucketNameLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: contentLeftAndRightInset)
            bucketNameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

            shotsCountLabel.autoPinEdge(.Right, toEdge: .Left, ofView: arrowImageView, withOffset: -elementsOffset)
            shotsCountLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: contentTopAndBottomInset)
            shotsCountLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: contentTopAndBottomInset)
            shotsCountLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: bucketNameLabel)

            arrowImageView.autoPinEdgeToSuperviewEdge(.Trailing, withInset: contentLeftAndRightInset)
            arrowImageView.autoSetDimensionsToSize(CGSize(width: 8, height: 13))
            arrowImageView.autoAlignAxis(.Horizontal, toSameAxisOfView: bucketNameLabel)

            separatorLine.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
            separatorLine.autoSetDimension(.Height, toSize: 0.5)

            contentView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes)
                    -> UICollectionViewLayoutAttributes {

        layoutAttributes.frame = {

            var frame = layoutAttributes.frame
            let height = contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            frame.size.height = (height > minimumCellHeight) ? height : minimumCellHeight

            return CGRectIntegral(frame)
        }()

        return layoutAttributes
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        bucketNameLabel.text = nil
        shotsCountLabel.text = nil
        separatorLine.hidden = true
    }

    func showBottomSeparator(show: Bool) {
        separatorLine.hidden = !show
    }
}

extension ShotBucketsAddCollectionViewCell: Reusable {

    class var reuseIdentifier: String {
        return String(ShotBucketsAddCollectionViewCell)
    }
}
