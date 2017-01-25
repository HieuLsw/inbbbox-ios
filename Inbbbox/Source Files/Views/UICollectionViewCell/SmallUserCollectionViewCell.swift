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

    let firstShotImageView = UIImageView.newAutoLayout()
    let secondShotImageView = UIImageView.newAutoLayout()
    let thirdShotImageView = UIImageView.newAutoLayout()
    let fourthShotImageView = UIImageView.newAutoLayout()

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
        for view in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView] {
            shotsView.addSubview(view)
        }
    }

    func updateImageViewsWith(_ color: UIColor) {
        for view in [firstShotImageView, secondShotImageView, thirdShotImageView, fourthShotImageView] {
            view.backgroundColor = color
        }
    }

    func setShotsViewConstraints() {
        let spacings = CollectionViewLayoutSpacings()
        let shotImageViewWidth = contentView.bounds.width / 2
        let shotImageViewHeight = shotImageViewWidth * spacings.smallerShotHeightToWidthRatio

        firstShotImageView.autoSetDimension(.height, toSize: shotImageViewHeight)
        firstShotImageView.autoSetDimension(.width, toSize: shotImageViewWidth)

        secondShotImageView.autoSetDimension(.height, toSize: shotImageViewHeight)
        secondShotImageView.autoSetDimension(.width, toSize: shotImageViewWidth)

        thirdShotImageView.autoSetDimension(.height, toSize: shotImageViewHeight)
        thirdShotImageView.autoSetDimension(.width, toSize: shotImageViewWidth)

        fourthShotImageView.autoSetDimension(.height, toSize: shotImageViewHeight)
        fourthShotImageView.autoSetDimension(.width, toSize: shotImageViewWidth)

        firstShotImageView.autoPinEdge(.top, to: .top, of: shotsView)
        firstShotImageView.autoPinEdge(.left, to: .left, of: shotsView)
        firstShotImageView.autoPinEdge(.bottom, to: .top, of: thirdShotImageView)
        firstShotImageView.autoPinEdge(.right, to: .left, of: secondShotImageView)

        secondShotImageView.autoPinEdge(.top, to: .top, of: shotsView)
        secondShotImageView.autoPinEdge(.right, to: .right, of: shotsView)
        secondShotImageView.autoPinEdge(.bottom, to: .top, of: fourthShotImageView)

        thirdShotImageView.autoPinEdge(.left, to: .left, of: shotsView)
        thirdShotImageView.autoPinEdge(.bottom, to: .bottom, of: shotsView)
        thirdShotImageView.autoPinEdge(.right, to: .left, of: fourthShotImageView)

        fourthShotImageView.autoPinEdge(.bottom, to: .bottom, of: shotsView)
        fourthShotImageView.autoPinEdge(.right, to: .right, of: shotsView)
    }

    func setInfoViewConstraints() {
        avatarView.autoSetDimensions(to: avatarSize)
        avatarView.autoPinEdge(.left, to: .left, of: infoView)
        avatarView.autoPinEdge(.top, to: .top, of: infoView, withOffset: 6.5)

        nameLabel.autoPinEdge(.bottom, to: .top, of: numberOfShotsLabel)
        nameLabel.autoAlignAxis(.horizontal, toSameAxisOf: avatarView)
        nameLabel.autoPinEdge(.left, to: .right, of: avatarView, withOffset: 3)
        nameLabel.autoPinEdge(.right, to: .right, of: infoView)

        numberOfShotsLabel.autoPinEdge(.left, to: .left, of: nameLabel)
    }

    func clearImages() {
        for imageView in [avatarView.imageView, firstShotImageView, secondShotImageView,
                          thirdShotImageView, fourthShotImageView] {
            imageView.image = nil
        }
    }

    // MARK: - Reusable

    static var identifier: String {
        return String(describing: SmallUserCollectionViewCell.self)
    }

    // MARK: - Width dependent height

    static var heightToWidthRatio: CGFloat {
        return CGFloat(1)
    }
}
