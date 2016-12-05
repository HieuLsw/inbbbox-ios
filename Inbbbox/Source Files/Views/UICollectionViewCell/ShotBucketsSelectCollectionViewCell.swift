//
//  ShotBucketsSelectCollectionViewCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 25/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsSelectCollectionViewCell: UICollectionViewCell {

    let bucketNameLabel = UILabel.newAutoLayoutView()
    private let selectImageView = UIImageView.newAutoLayoutView()
    private let separatorLine = UIView.newAutoLayoutView()

    // Size properties
    private let minimumCellHeight = CGFloat(44)
    private let contentLeftInset = CGFloat(15)
    private let contentRightInset = CGFloat(15)
    private var elementsOffset = CGFloat(20)

    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureForAutoLayout()

        contentView.configureForAutoLayout()
        contentView.backgroundColor = .whiteColor()

        bucketNameLabel.configureForAutoLayout()
        bucketNameLabel.numberOfLines = 0
        bucketNameLabel.textColor = ColorModeProvider.current().shotDetailsBucketTextColor
        bucketNameLabel.font = UIFont.helveticaFont(.Neue, size: 17)
        contentView.addSubview(bucketNameLabel)

        selectImageView.image = UIImage(named: "select")
        contentView.addSubview(selectImageView)

        separatorLine.backgroundColor = .RGBA(237, 237, 237, 1)
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
            maxLayoutWidth -= selectImageView.frame.size.width
            maxLayoutWidth -= contentLeftInset
            maxLayoutWidth -= contentRightInset
            maxLayoutWidth -= elementsOffset
            return maxLayoutWidth
        }()
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let contentTopAndBottomInset = CGFloat(10)

            selectImageView.autoPinEdgeToSuperviewEdge(.Leading, withInset: contentLeftInset)
            selectImageView.autoSetDimensionsToSize(CGSize(width: 20, height: 20))
            selectImageView.autoAlignAxisToSuperviewAxis(.Horizontal)

            bucketNameLabel.autoPinEdge(.Left, toEdge: .Right, ofView: selectImageView, withOffset: elementsOffset)
            bucketNameLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoAlignAxisToSuperviewAxis(.Horizontal)

            separatorLine.autoPinEdgeToSuperviewEdge(.Leading, withInset: 50)
            separatorLine.autoPinEdgeToSuperviewEdge(.Bottom)
            separatorLine.autoPinEdgeToSuperviewEdge(.Right)
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
        selectImageView.image = UIImage(named: "select")
        separatorLine.hidden = true
    }

    func selectBucket(select: Bool) {
        selectImageView.image = select ? UIImage(named: "selected") : UIImage(named: "select")
    }

    func showBottomSeparator(show: Bool) {
        separatorLine.hidden = !show
    }
}

extension ShotBucketsSelectCollectionViewCell: Reusable {

    class var reuseIdentifier: String {
        return String(ShotBucketsSelectCollectionViewCell)
    }
}
