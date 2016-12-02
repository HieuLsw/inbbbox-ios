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

    fileprivate let offsetToTopLayoutGuide = CGFloat(10)

    fileprivate let collectionViewCornerWrapperView = UIView.newAutoLayout()
    fileprivate let blurView = UIVisualEffectView(effect: UIBlurEffect(style: ColorModeProvider.current().visualEffectBlurType))
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {

        collectionView = UICollectionView(frame: CGRect.zero,
                collectionViewLayout: ShotDetailsCollectionCollapsableHeader())
        collectionView.backgroundColor = UIColor.clear
        collectionView.layer.shadowColor = UIColor.gray.cgColor
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

        collectionViewCornerWrapperView.backgroundColor = .clear
        collectionViewCornerWrapperView.clipsToBounds = true
        collectionViewCornerWrapperView.addSubview(collectionView)

        addSubview(collectionViewCornerWrapperView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
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
                collectionViewCornerWrapperView.autoPin(toTopLayoutGuideOf: viewController,
                        withInset: offsetToTopLayoutGuide)
            } else {
                collectionViewCornerWrapperView.autoPinEdge(toSuperviewEdge: .top, withInset: offsetToTopLayoutGuide)
            }
            collectionViewCornerWrapperView.autoPinEdge(toSuperviewEdge: .left, withInset: 10)
            collectionViewCornerWrapperView.autoPinEdge(toSuperviewEdge: .right, withInset: 10)
            collectionViewCornerWrapperView.autoPinEdge(toSuperviewEdge: .bottom)

            collectionView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let path = UIBezierPath(roundedRect: collectionViewCornerWrapperView.bounds,
                byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        collectionViewCornerWrapperView.layer.mask = mask
    }
}
