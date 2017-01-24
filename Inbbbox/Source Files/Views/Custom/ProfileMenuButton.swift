//
//  ProfileMenuButton.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class ProfileMenuButton: UIButton {

    var badge = 0 {
        didSet {
            badgeLabel.text = "\(badge)"
            badgeLabel.isHidden = badge == 0
            titleEdgeInsets = UIEdgeInsets(top: 0, left: badge == 0 ? 0 : -3, bottom: 0, right: badge == 0 ? 0 : 3)
        }
    }

    var badgeColor = UIColor.RGBA(26, 26, 26, 1) {
        didSet {
            badgeLabel.textColor = badgeColor
        }
    }

    fileprivate let badgeLabel = UILabel()
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        badgeLabel.font = UIFont.systemFont(ofSize: 10)

        titleLabel?.addSubview(badgeLabel)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            guard let titleLabel = titleLabel else { return }

            badgeLabel.autoPinEdge(.leading, to: .trailing, of: titleLabel)
            badgeLabel.autoPinEdge(.bottom, to: .top, of: titleLabel, withOffset: 7)
        }

        super.updateConstraints()
    }
}
