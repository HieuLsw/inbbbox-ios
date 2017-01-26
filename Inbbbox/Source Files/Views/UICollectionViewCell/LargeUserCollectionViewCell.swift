//
//  LargeUserCollectionViewCell.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 03.02.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class LargeUserCollectionViewCell: BaseInfoShotsCollectionViewCell, Reusable, WidthDependentHeight,
        InfoShotsCellConfigurable, AvatarSettable {

    let shotImageView = UIImageView.newAutoLayout()
    var avatarView: AvatarView!
    let avatarSize = CGSize(width: 16, height: 16)
    fileprivate var didSetConstraints = false

    // MARK: - Lifecycle

    override func commonInit() {
        super.commonInit()
        setupAvatar()
        setupShotsView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        clearImages()
    }

    // MARK: - UIView

    override func updateConstraints() {
        if !didSetConstraints {
            setShotsViewConstraints()
            setInfoViewConstraints()
            didSetConstraints = true
        }
        super.updateConstraints()
    }

    // MARK: Avatar settable

    func setupAvatar() {
        avatarView = AvatarView(avatarFrame: CGRect(origin: CGPoint.zero, size: avatarSize), bordered: false)
        avatarView.imageView.backgroundColor = UIColor.backgroundGrayColor()
        avatarView.configureForAutoLayout()
        infoView.addSubview(avatarView)
    }

    // MARK: - Info Shots Cell Configurable

    func setupShotsView() {
        shotsView.addSubview(shotImageView)
    }

    func setShotsViewConstraints() {
        shotImageView.autoPinEdgesToSuperviewEdges()
    }

    func setInfoViewConstraints() {
        avatarView.autoSetDimensions(to: avatarSize)
        avatarView.autoPinEdge(.left, to: .left, of: infoView, withOffset: 2)
        avatarView.autoPinEdge(.top, to: .top, of: infoView, withOffset: 10)

        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: avatarView)
        nameLabel.autoPinEdge(.left, to: .right, of: avatarView, withOffset: 3)
        nameLabel.autoPinEdge(.right, to: .left, of: numberOfShotsLabel)

        numberOfShotsLabel.autoPinEdge(.right, to: .right, of: infoView, withOffset: -2)
        numberOfShotsLabel.autoAlignAxis(.horizontal, toSameAxisOf: nameLabel)
    }

    func clearImages() {
        avatarView.imageView.image = nil
        shotImageView.image = nil
    }

    // MARK: - Width dependent height

    static var heightToWidthRatio: CGFloat {
        return CGFloat(0.83)
    }
}
