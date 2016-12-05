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

class ProfileHeaderView: UICollectionReusableView {

    let avatarView = AvatarView(size: avatarSize, bordered: true, borderWidth: 3)
    var shouldShowButton = true
    let button = UIButton.newAutoLayoutView()
    var userFollowed: Bool? {
        didSet {
            let title = userFollowed! ?
                    NSLocalizedString("ProfileHeaderView.Unfollow",
                            comment: "Allows user to unfollow another user.") :
                    NSLocalizedString("ProfileHeaderView.Follow",
                            comment: "Allows user to follow another user.")
            button.setTitle(title, forState: .Normal)
        }
    }

    private let activityIndicator = UIActivityIndicatorView.newAutoLayoutView()

    private var avatarOffset: CGFloat {
        return shouldShowButton ? -20 : 0
    }
    private var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        addSubview(avatarView)

        if shouldShowButton {
            button.setTitleColor(.whiteColor(), forState: .Normal)
            button.setTitleColor(UIColor(white: 1, alpha: 0.2), forState: .Highlighted)
            button.titleLabel?.font = UIFont.helveticaFont(.Neue, size: 14)
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 13)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 13
            addSubview(button)
            button.hidden = true

            addSubview(activityIndicator)
        }
        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message = "Use init(frame:) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didUpdateConstraints {
            didUpdateConstraints = true

            avatarView.autoSetDimensionsToSize(avatarSize)
            avatarView.autoAlignAxisToSuperviewAxis(.Vertical)
            avatarView.autoAlignAxis(.Horizontal, toSameAxisOfView: avatarView.superview!, withOffset: avatarOffset)

            if shouldShowButton {
                button.autoPinEdge(.Top, toEdge: .Bottom, ofView: avatarView, withOffset: 10)
                button.autoAlignAxis(.Vertical, toSameAxisOfView: avatarView)

                activityIndicator.autoAlignAxis(.Horizontal, toSameAxisOfView: button)
                activityIndicator.autoAlignAxis(.Vertical, toSameAxisOfView: button)
            }
        }
        super.updateConstraints()
    }

    func startActivityIndicator() {
        button.hidden = true
        activityIndicator.startAnimating()
    }

    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        button.hidden = false
    }
}

extension ProfileHeaderView: Reusable {

    class var reuseIdentifier: String {
        return String(ProfileHeaderView)
    }
}
