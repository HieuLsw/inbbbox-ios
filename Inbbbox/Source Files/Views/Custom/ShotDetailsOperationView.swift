//
//  ShotDetailsOperationView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 12/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

private var selectableViewSize: CGSize {
    return CGSize(width: 44, height: 44)
}

class ShotDetailsOperationView: UIView {

    class var minimumRequiredHeight: CGFloat {
        let margin = CGFloat(5)
        return selectableViewSize.height + 2 * margin
    }

    let likeSelectableView = ActivityIndicatorSelectableView.newAutoLayout()
    let bucketSelectableView = ActivityIndicatorSelectableView.newAutoLayout()
	let shareButton = UIButton.newAutoLayout()
    let likeCounterLabel = UILabel.newAutoLayout()
    let bucketCounterLabel = UILabel.newAutoLayout()

    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        likeSelectableView.setImage(UIImage(named: "ic-like-details-active"), forState: .selected)
        likeSelectableView.setImage(UIImage(named: "ic-like-details"), forState: .deselected)
        addSubview(likeSelectableView)

        bucketSelectableView.setImage(UIImage(named: "ic-bucket-details-active"), forState: .selected)
        bucketSelectableView.setImage(UIImage(named: "ic-bucket-details"), forState: .deselected)
        addSubview(bucketSelectableView)
		
        shareButton.setImage(UIImage(named: "ic-share"), for: .normal)
        addSubview(shareButton)

        for label in [likeCounterLabel, bucketCounterLabel] {
            
            label.font = UIFont.helveticaFont(.neue, size: 12)
            label.textColor = ColorModeProvider.current().shotDetailsCommentEditLabelTextColor
            
            addSubview(label)
        }
        
    }

    @available(*, unavailable, message: "Use init(withImage: UIImage) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize : CGSize {
        return CGSize(width: 0, height: type(of: self).minimumRequiredHeight)
    }

    override func updateConstraints() {
        if !didUpdateConstraints {
            didUpdateConstraints = true

            let offset = CGFloat(65)
            likeSelectableView.autoAlignAxis(.vertical, toSameAxisOf: likeSelectableView.superview!,
                    withOffset: -offset)
            bucketSelectableView.autoAlignAxis(.vertical, toSameAxisOf: likeSelectableView.superview!)
            shareButton.autoAlignAxis(.vertical, toSameAxisOf: likeSelectableView.superview!,
                    withOffset: offset)

            [likeSelectableView, bucketSelectableView, shareButton].forEach {
                $0.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: -5)
                $0.autoSetDimensions(to: selectableViewSize)
            }

            likeCounterLabel.autoConstrainAttribute(.left, to: .right,
                                                    of: likeSelectableView, withOffset: 0)
            likeCounterLabel.autoAlignAxis(.horizontal, toSameAxisOf: likeSelectableView)

            bucketCounterLabel.autoConstrainAttribute(.left, to: .right,
                                                    of: bucketSelectableView, withOffset: 0)
            bucketCounterLabel.autoAlignAxis(.horizontal, toSameAxisOf: bucketSelectableView)
        }

        super.updateConstraints()
    }
}
