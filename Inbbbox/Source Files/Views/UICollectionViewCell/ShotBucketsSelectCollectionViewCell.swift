//
//  ShotBucketsSelectCollectionViewCell.swift
//  Inbbbox
//
//  Created by Peter Bruz on 25/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotBucketsSelectCollectionViewCell: UICollectionViewCell {

    let bucketNameLabel = UILabel.newAutoLayout()
    fileprivate let selectImageView = UIImageView.newAutoLayout()
    fileprivate let separatorLine = UIView.newAutoLayout()

    // Size properties
    fileprivate let minimumCellHeight = CGFloat(44)
    fileprivate let contentLeftInset = CGFloat(15)
    fileprivate let contentRightInset = CGFloat(15)
    fileprivate var elementsOffset = CGFloat(20)

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureForAutoLayout()

        contentView.configureForAutoLayout()
        contentView.backgroundColor = .white

        bucketNameLabel.configureForAutoLayout()
        bucketNameLabel.numberOfLines = 0
        bucketNameLabel.textColor = ColorModeProvider.current().shotDetailsBucketTextColor
        bucketNameLabel.font = UIFont.helveticaFont(.neue, size: 17)
        contentView.addSubview(bucketNameLabel)

        selectImageView.image = UIImage(named: "select")
        contentView.addSubview(selectImageView)

        separatorLine.backgroundColor = .RGBA(237, 237, 237, 1)
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

            selectImageView.autoPinEdge(toSuperviewEdge: .leading, withInset: contentLeftInset)
            selectImageView.autoSetDimensions(to: CGSize(width: 20, height: 20))
            selectImageView.autoAlignAxis(toSuperviewAxis: .horizontal)

            bucketNameLabel.autoPinEdge(.left, to: .right, of: selectImageView, withOffset: elementsOffset)
            bucketNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentTopAndBottomInset)
            bucketNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)

            separatorLine.autoPinEdge(toSuperviewEdge: .leading, withInset: 50)
            separatorLine.autoPinEdge(toSuperviewEdge: .bottom)
            separatorLine.autoPinEdge(toSuperviewEdge: .right)
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
        selectImageView.image = UIImage(named: "select")
        separatorLine.isHidden = true
    }

    func selectBucket(_ select: Bool) {
        selectImageView.image = select ? UIImage(named: "selected") : UIImage(named: "select")
    }

    func showBottomSeparator(_ show: Bool) {
        separatorLine.isHidden = !show
    }
}

extension ShotBucketsSelectCollectionViewCell: Reusable {

    class var identifier: String {
        return String(describing: ShotBucketsSelectCollectionViewCell.self)
    }
}
