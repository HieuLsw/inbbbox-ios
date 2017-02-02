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

    enum BagdeType: String {
        case pro = "PRO"
        case team = "Team"
    }

    let contentView = UIView.newAutoLayout()
    let avatarView = AvatarView(size: avatarSize, bordered: true, borderWidth: 3)
    var shouldShowButton = true
    let button = UIButton.newAutoLayout()

    var userFollowed: Bool? {
        didSet {
            let title = userFollowed! ?
                    Localized("ProfileHeaderView.Unfollow",
                            comment: "Allows user to unfollow another user.") :
                    Localized("ProfileHeaderView.Follow",
                            comment: "Allows user to follow another user.")
            button.setTitle(title, for: UIControlState())
        }
    }

    var badge: BagdeType? {
        didSet {
            badgeLabel.text = badge?.rawValue
            badgeView.isHidden = badge == nil
        }
    }

    fileprivate let backgroundImageView = UIImageView.newAutoLayout()
    fileprivate let activityIndicator = UIActivityIndicatorView.newAutoLayout()
    fileprivate let badgeView = UIView.newAutoLayout()
    fileprivate let vibrancyView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    fileprivate let badgeLabel = UILabel.newAutoLayout()

    fileprivate var avatarOffset: CGFloat {
        return shouldShowButton ? -20 : 0
    }
    fileprivate var didUpdateConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true

        backgroundImageView.image = UIImage(named: "Profile BG")
        backgroundImageView.contentMode = .top

        addSubview(backgroundImageView)
        addSubview(contentView)

        contentView.backgroundColor = .clear
        contentView.addSubview(avatarView)

        badgeView.backgroundColor = .RGBA(246, 248, 248, 0.63)
        badgeView.layer.cornerRadius = 4
        badgeView.clipsToBounds = true
        badgeView.addSubview(vibrancyView)
        contentView.addSubview(badgeView)

        badgeLabel.font = .systemFont(ofSize: 11, weight: UIFontWeightMedium)
        badgeLabel.textColor = .RGBA(51, 51, 51, 1)
        vibrancyView.addSubview(badgeLabel)

        if shouldShowButton {
            button.setTitleColor(.white, for: UIControlState())
            button.setTitleColor(UIColor(white: 1, alpha: 0.2), for: .highlighted)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
            button.layer.borderColor = UIColor.white.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 13, bottom: 5, right: 13)
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 13
            contentView.addSubview(button)
            button.isHidden = true

            contentView.addSubview(activityIndicator)
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

            contentView.autoPinEdgesToSuperviewEdges()

            backgroundImageView.autoPinEdgesToSuperviewEdges()

            avatarView.autoSetDimensions(to: avatarSize)
            avatarView.autoAlignAxis(toSuperviewAxis: .vertical)
            avatarView.autoAlignAxis(.horizontal, toSameAxisOf: avatarView.superview!, withOffset: avatarOffset)

            badgeView.autoPinEdge(.left, to: .left, of: avatarView, withOffset: avatarSize.width / 2 + 12)
            badgeView.autoPinEdge(.top, to: .top, of: avatarView, withOffset: 4)

            vibrancyView.autoPinEdgesToSuperviewEdges()

            badgeLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 3, left: 4, bottom: 3, right: 4))

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
