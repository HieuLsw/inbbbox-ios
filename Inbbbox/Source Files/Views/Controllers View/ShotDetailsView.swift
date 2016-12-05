//
//  ShotDetailsView.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ShotDetailsView: UIView {

    let collectionView: UICollectionView
    let commentComposerView = CommentComposerView.newAutoLayoutView()

    var shouldShowCommentComposerView = true {
        willSet(newValue) {
            commentComposerView.hidden = !newValue
        }
    }
    var topLayoutGuideOffset = CGFloat(0)

    private let collectionViewCornerWrapperView = UIView.newAutoLayoutView()
    let keyboardResizableView = KeyboardResizableView.newAutoLayoutView()
    private var didSetConstraints = false

    override init(frame: CGRect) {

        collectionView = UICollectionView(frame: CGRect.zero,
                collectionViewLayout: ShotDetailsCollectionCollapsableHeader())
        collectionView.backgroundColor = .clearColor()
        collectionView.layer.shadowColor = UIColor.grayColor().CGColor
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        collectionView.layer.shadowOpacity = 0.3
        collectionView.clipsToBounds = true

        super.init(frame: frame)
        
        backgroundColor = .clearColor()

        collectionViewCornerWrapperView.backgroundColor = .clearColor()
        collectionViewCornerWrapperView.clipsToBounds = true
        collectionViewCornerWrapperView.addSubview(collectionView)

        keyboardResizableView.automaticallySnapToKeyboardTopEdge = true
        keyboardResizableView.addSubview(collectionViewCornerWrapperView)
        keyboardResizableView.addSubview(commentComposerView)
        addSubview(keyboardResizableView)
    }

    @available(*, unavailable, message = "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            let commentComposerViewHeight = CGFloat(61)
            keyboardResizableView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
            let constraint = keyboardResizableView.autoPinEdgeToSuperviewEdge(.Bottom)
            keyboardResizableView.setReferenceBottomConstraint(constraint)

            commentComposerView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Top)
            commentComposerView.autoSetDimension(.Height, toSize: commentComposerViewHeight)

            let insets = UIEdgeInsets(top: topLayoutGuideOffset + 10, left: 10, bottom: 0, right: 10)
            let commentComposerInset = shouldShowCommentComposerView ? commentComposerViewHeight : 0
            collectionViewCornerWrapperView.autoPinEdgesToSuperviewEdgesWithInsets(insets, excludingEdge: .Bottom)
            collectionViewCornerWrapperView.autoPinEdgeToSuperviewEdge(.Bottom, withInset: commentComposerInset)

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
    
    // MARK: public
    
    func customizeFor3DTouch(hidden: Bool) {
        backgroundColor = hidden ? .backgroundGrayColor() : .clearColor()
    }
}
