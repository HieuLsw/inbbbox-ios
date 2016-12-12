//
//  ShotBucketsAddCollectionViewCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsAddCollectionViewCell: UICollectionViewCell, Reusable {

    let bucketNameLabel = UILabel.newAutoLayout()
    let shotsCountLabel = UILabel.newAutoLayout()
    fileprivate let arrowImageView = UIImageView.newAutoLayout()
    fileprivate let separatorLine = UIView.newAutoLayout()

    // Size properties
    fileprivate let minimumCellHeight = CGFloat(44)
    fileprivate let contentLeftAndRightInset = CGFloat(15)
    fileprivate var elementsOffset = CGFloat(10)

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureForAutoLayout()

        contentView.configureForAutoLayout()
        let currentMode = ColorModeProvider.current()
        bucketNameLabel.configureForAutoLayout()
        bucketNameLabel.numberOfLines = 0
        bucketNameLabel.textColor = currentMode.shotDetailsBucketTextColor
        bucketNameLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        contentView.addSubview(bucketNameLabel)

        shotsCountLabel.configureForAutoLayout()
        shotsCountLabel.numberOfLines = 1
        shotsCountLabel.textColor = .followeeTextGrayColor()
        shotsCountLabel.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        contentView.addSubview(shotsCountLabel)

        arrowImageView.image = UIImage(named: "ic-indicator-right")
        contentView.addSubview(arrowImageView)

        separatorLine.backgroundColor = currentMode.cellSeparator
        contentView.addSubview(separatorLine)
        separatorLine.isHidden = true

        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
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

            bucketNameLabel.autoPinEdge(toSuperviewEdge: .left, withInset: contentLeftAndRightInset)
            bucketNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            shotsCountLabel.autoPinEdge(.right, to: .left, of: arrowImageView, withOffset: -elementsOffset)
            shotsCountLabel.autoPinEdge(toSuperviewEdge: .top, withInset: contentTopAndBottomInset)
            shotsCountLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentTopAndBottomInset)
            shotsCountLabel.autoAlignAxis(.horizontal, toSameAxisOf: bucketNameLabel)

            arrowImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: contentLeftAndRightInset)
            arrowImageView.autoSetDimensions(to: CGSize(width: 8, height: 13))
            arrowImageView.autoAlignAxis(.horizontal, toSameAxisOf: bucketNameLabel)

            separatorLine.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
            separatorLine.autoSetDimension(.height, toSize: 0.5)

            contentView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
                    -> UICollectionViewLayoutAttributes {

        layoutAttributes.frame = {

            var frame = layoutAttributes.frame
            let height = contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            frame.size.height = (height > minimumCellHeight) ? height : minimumCellHeight

            return frame.integral
        }()

        return layoutAttributes
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        bucketNameLabel.text = nil
        shotsCountLabel.text = nil
        separatorLine.isHidden = true
    }

    func showBottomSeparator(_ show: Bool) {
        separatorLine.isHidden = !show
    }
}
