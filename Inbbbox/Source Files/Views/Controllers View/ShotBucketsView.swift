//
//  ShotBucketsView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ShotBucketsView: UIView {

    let collectionView: UICollectionView

    weak var viewController: UIViewController?

    private let offsetToTopLayoutGuide = CGFloat(10)

    private let collectionViewCornerWrapperView = UIView.newAutoLayoutView()
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: ColorModeProvider.current().visualEffectBlurType))
    private var didSetConstraints = false

    override init(frame: CGRect) {

        collectionView = UICollectionView(frame: CGRect.zero,
                collectionViewLayout: ShotDetailsCollectionCollapsableHeader())
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.layer.shadowColor = UIColor.grayColor().CGColor
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        collectionView.layer.shadowOpacity = 0.3
        collectionView.clipsToBounds = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)

        super.init(frame: frame)
        let currentColorMode = ColorModeProvider.current()
        if DeviceInfo.shouldDowngrade() {
            backgroundColor = currentColorMode.tableViewBackground
        } else {
            backgroundColor = currentColorMode.tableViewBlurColor
            blurView.configureForAutoLayout()
            addSubview(blurView)
        }

        collectionViewCornerWrapperView.backgroundColor = .clearColor()
        collectionViewCornerWrapperView.clipsToBounds = true
        collectionViewCornerWrapperView.addSubview(collectionView)

        addSubview(collectionViewCornerWrapperView)
    }

    @available(*, unavailable, message = "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            if !DeviceInfo.shouldDowngrade() {
                blurView.autoPinEdgesToSuperviewEdges()
            }

            if let viewController = viewController {
                collectionViewCornerWrapperView.autoPinToTopLayoutGuideOfViewController(viewController,
                        withInset: offsetToTopLayoutGuide)
            } else {
                collectionViewCornerWrapperView.autoPinEdgeToSuperviewEdge(.Top, withInset: offsetToTopLayoutGuide)
            }
            collectionViewCornerWrapperView.autoPinEdgeToSuperviewEdge(.Left, withInset: 10)
            collectionViewCornerWrapperView.autoPinEdgeToSuperviewEdge(.Right, withInset: 10)
            collectionViewCornerWrapperView.autoPinEdgeToSuperviewEdge(.Bottom)

            collectionView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let path = UIBezierPath(roundedRect: collectionViewCornerWrapperView.bounds,
                byRoundingCorners: [.TopLeft, .TopRight], cornerRadii: CGSize(width: 15, height: 15))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        collectionViewCornerWrapperView.layer.mask = mask
    }
}
