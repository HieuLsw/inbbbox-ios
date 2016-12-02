//
//  ProfileHeaderView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 14/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

private var avatarSize: CGSize {
    return CGSize(width: 90, height: 90)
}
private var margin: CGFloat {
    return 10
}

class ProfileHeaderView: UICollectionReusableView, Reusable {

    let avatarView = AvatarView(size: avatarSize, bordered: true, borderWidth: 3)
    var shouldShowButton = true
    let button = UIButton.newAutoLayout()
    var userFollowed: Bool? {
        didSet {
            let title = userFollowed! ?
                    NSLocalizedString("ProfileHeaderView.Unfollow",
                            comment: "Allows user to unfollow another user.") :
                    NSLocalizedString("ProfileHeaderView.Follow",
                            comment: "Allows user to follow another user.")
            button.setTitle(title, for: UIControlState())
        }
    }

    fileprivate let activityIndicator = UIActivityIndicatorView.newAutoLayout()

    fileprivate var avatarOffset: CGFloat {
        return shouldShowButton ? -20 : 0
    }
    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        addSubview(avatarView)

        if shouldShowButton {
            button.setTitleColor(.white, for: UIControlState())
            button.setTitleColor(UIColor(white: 1, alpha: 0.2), for: .highlighted)
            button.titleLabel?.font = UIFont.helveticaFont(.neue, size: 14)
            button.layer.borderColor = UIColor.white.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 13)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 13
            addSubview(button)
            button.isHidden = true

            addSubview(activityIndicator)
        }
        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            avatarView.autoSetDimensions(to: avatarSize)
            avatarView.autoAlignAxis(toSuperviewAxis: .vertical)
            avatarView.autoAlignAxis(.horizontal, toSameAxisOf: avatarView.superview!, withOffset: avatarOffset)

            if shouldShowButton {
                button.autoPinEdge(.top, to: .bottom, of: avatarView, withOffset: 10)
                button.autoAlignAxis(.vertical, toSameAxisOf: avatarView)

                activityIndicator.autoAlignAxis(.horizontal, toSameAxisOf: button)
                activityIndicator.autoAlignAxis(.vertical, toSameAxisOf: button)
            }
        }
        super.updateConstraints()
    }

    func startActivityIndicator() {
        button.isHidden = true
        activityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        button.isHidden = false
    }
}
