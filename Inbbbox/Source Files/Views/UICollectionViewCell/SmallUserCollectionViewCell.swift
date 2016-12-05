//
//  SmallUserCollectionViewCell.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 27.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class SmallUserCollectionViewCell: BaseInfoShotsCollectionViewCell, Reusable, WidthDependentHeight,
        InfoShotsCellConfigurable, AvatarSettable {

    let firstShotImageView = UIImageView.newAutoLayoutView()
    let secondShotImageView = UIImageView.newAutoLayoutView()
    let thirdShotImageView = UIImageView.newAutoLayoutView()
    let fourthShotImageView = UIImageView.newAutoLayoutView()

    var avatarView: AvatarView!
    let avatarSize = CGSize(width: 16, height: 16)

    private var didSetConstraints = false


    // MARK: - Lifecycle

    override func commonInit() {
        super.commonInit()
        setupAvatar()
        setupShotsView()
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
        for view in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView] {
            shotsView.addSubview(view)
        }
    }

    func updateImageViewsWith(color: UIColor) {
        for view in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView] {
            view.backgroundColor = color
        }
    }

    func setShotsViewConstraints() {
        let spacings = CollectionViewLayoutSpacings()
        let shotImageViewWidth = contentView.bounds.width / 2
        let shotImageViewHeight = shotImageViewWidth * spacings.smallerShotHeightToWidthRatio

        firstShotImageView.autoSetDimension(.Height, toSize: shotImageViewHeight)
        firstShotImageView.autoSetDimension(.Width, toSize: shotImageViewWidth)

        secondShotImageView.autoSetDimension(.Height, toSize: shotImageViewHeight)
        secondShotImageView.autoSetDimension(.Width, toSize: shotImageViewWidth)

        thirdShotImageView.autoSetDimension(.Height, toSize: shotImageViewHeight)
        thirdShotImageView.autoSetDimension(.Width, toSize: shotImageViewWidth)

        fourthShotImageView.autoSetDimension(.Height, toSize: shotImageViewHeight)
        fourthShotImageView.autoSetDimension(.Width, toSize: shotImageViewWidth)

        firstShotImageView.autoPinEdge(.Top, toEdge: .Top, ofView: shotsView)
        firstShotImageView.autoPinEdge(.Left, toEdge: .Left, ofView: shotsView)
        firstShotImageView.autoPinEdge(.Bottom, toEdge: .Top, ofView: thirdShotImageView)
        firstShotImageView.autoPinEdge(.Right, toEdge: .Left, ofView: secondShotImageView)

        secondShotImageView.autoPinEdge(.Top, toEdge: .Top, ofView: shotsView)
        secondShotImageView.autoPinEdge(.Right, toEdge: .Right, ofView: shotsView)
        secondShotImageView.autoPinEdge(.Bottom, toEdge: .Top, ofView: fourthShotImageView)

        thirdShotImageView.autoPinEdge(.Left, toEdge: .Left, ofView: shotsView)
        thirdShotImageView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: shotsView)
        thirdShotImageView.autoPinEdge(.Right, toEdge: .Left, ofView: fourthShotImageView)

        fourthShotImageView.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: shotsView)
        fourthShotImageView.autoPinEdge(.Right, toEdge: .Right, ofView: shotsView)
    }

    func setInfoViewConstraints() {
        avatarView.autoSetDimensionsToSize(avatarSize)
        avatarView.autoPinEdge(.Left, toEdge: .Left, ofView: infoView)
        avatarView.autoPinEdge(.Top, toEdge: .Top, ofView: infoView, withOffset: 6.5)

        nameLabel.autoPinEdge(.Bottom, toEdge: .Top, ofView: numberOfShotsLabel)
        nameLabel.autoAlignAxis(.Horizontal, toSameAxisOfView: avatarView)
        nameLabel.autoPinEdge(.Left, toEdge: .Right, ofView: avatarView, withOffset: 3)
        nameLabel.autoPinEdge(.Right, toEdge: .Right, ofView: infoView)

        numberOfShotsLabel.autoPinEdge(.Left, toEdge: .Left, ofView: nameLabel)
    }

    func clearImages() {
        for imageView in [avatarView.imageView, firstShotImageView, secondShotImageView,
                          thirdShotImageView, fourthShotImageView] {
            imageView.image = nil
        }
    }

    // MARK: - Reusable

    static var reuseIdentifier: String {
        return String(SmallUserCollectionViewCell)
    }

    // MARK: - Width dependent height

    static var heightToWidthRatio: CGFloat {
        return CGFloat(1)
    }
}
