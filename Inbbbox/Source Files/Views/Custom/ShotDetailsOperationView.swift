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
        return  selectableViewSize.height + 2 * margin
    }

    let likeSelectableView = ActivityIndicatorSelectableView.newAutoLayoutView()
    let bucketSelectableView = ActivityIndicatorSelectableView.newAutoLayoutView()

    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .RGBA(246, 248, 248, 1)

        likeSelectableView.setImage(UIImage(named: "ic-like-details-active"), forState: .Selected)
        likeSelectableView.setImage(UIImage(named: "ic-like-details"), forState: .Deselected)
        addSubview(likeSelectableView)

        bucketSelectableView.setImage(UIImage(named: "ic-bucket-details-active"), forState: .Selected)
        bucketSelectableView.setImage(UIImage(named: "ic-bucket-details"), forState: .Deselected)
        addSubview(bucketSelectableView)
    }

    @available(*, unavailable, message="Use init(withImage: UIImage) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 0, height: self.dynamicType.minimumRequiredHeight)
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            let offset = CGFloat(40)
            likeSelectableView.autoAlignAxis(.Vertical, toSameAxisOfView: likeSelectableView.superview!, withOffset: -offset)
            bucketSelectableView.autoAlignAxis(.Vertical, toSameAxisOfView: likeSelectableView.superview!, withOffset: offset)

            [likeSelectableView, bucketSelectableView].forEach {
                $0.autoAlignAxis(.Horizontal, toSameAxisOfView: self, withOffset: -10)
                $0.autoSetDimensionsToSize(selectableViewSize)
            }
        }

        super.updateConstraints()
    }
}
