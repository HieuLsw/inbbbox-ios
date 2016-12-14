//
//  SettingsTableHeaderView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Async

class SettingsTableHeaderView: UIView, Reusable, AvatarSettable {

    fileprivate(set) var avatarView: AvatarView!
    fileprivate(set) var usernameLabel = UILabel.newAutoLayout()

    let avatarSize = CGSize(width: 176, height: 176)

    fileprivate var didSetConstraints = false

    // MARK: Lifecycyle

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = UIColor.clear
        setupAvatar()
        setupUsernameLabel()
        setNeedsUpdateConstraints()
    }

    @available(*, unavailable, message: "Use init(_: CGRect) method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(size: CGSize) {
        self.init(frame: CGRect(origin: CGPoint.zero, size: size))
    }

    // MARK: UIView

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            avatarView.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            avatarView.autoSetDimensions(to: avatarSize)
            avatarView.autoAlignAxis(toSuperviewAxis: .vertical)

            usernameLabel.autoPinEdge(.top, to: .bottom, of: avatarView, withOffset: 14)
            usernameLabel.autoSetDimension(.height, toSize: 28)
            usernameLabel.autoMatch(.width, to: .width, of: self)
            usernameLabel.autoAlignAxis(.vertical, toSameAxisOf: avatarView)
        }

        super.updateConstraints()
    }

    // MARK: Avatar settable

    func setupAvatar() {
        avatarView = AvatarView(avatarFrame: CGRect(origin: CGPoint.zero, size: avatarSize))
        avatarView.imageView.backgroundColor = UIColor.backgroundGrayColor()
        avatarView.configureForAutoLayout()
        addSubview(avatarView)
    }

    // MARK: Setup label

    func setupUsernameLabel() {
        usernameLabel.textAlignment = .center
        usernameLabel.textColor = ColorModeProvider.current().settingsUsernameTextColor
        usernameLabel.font = UIFont.helveticaFont(.neue, size: 23)
        addSubview(usernameLabel)
    }
}

extension SettingsTableHeaderView: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        usernameLabel.textColor = mode.settingsUsernameTextColor
    }
}
