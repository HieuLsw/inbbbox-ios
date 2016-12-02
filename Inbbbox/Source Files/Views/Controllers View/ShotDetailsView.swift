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
    let commentComposerView = CommentComposerView.newAutoLayout()

    var shouldShowCommentComposerView = true {
        willSet(newValue) {
            commentComposerView.isHidden = !newValue
        }
    }
    var topLayoutGuideOffset = CGFloat(0)

    fileprivate let collectionViewCornerWrapperView = UIView.newAutoLayout()
    let keyboardResizableView = KeyboardResizableView.newAutoLayout()
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {

        collectionView = UICollectionView(frame: CGRect.zero,
                collectionViewLayout: ShotDetailsCollectionCollapsableHeader())
        collectionView.backgroundColor = .clear
        collectionView.layer.shadowColor = UIColor.gray.cgColor
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        collectionView.layer.shadowOpacity = 0.3
        collectionView.clipsToBounds = true
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }

        super.init(frame: frame)
        
        backgroundColor = .clear

        collectionViewCornerWrapperView.backgroundColor = .clear
        collectionViewCornerWrapperView.clipsToBounds = true
        collectionViewCornerWrapperView.addSubview(collectionView)

        keyboardResizableView.automaticallySnapToKeyboardTopEdge = true
        keyboardResizableView.addSubview(collectionViewCornerWrapperView)
        keyboardResizableView.addSubview(commentComposerView)
        addSubview(keyboardResizableView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            let commentComposerViewHeight = CGFloat(61)
            keyboardResizableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
            let constraint = keyboardResizableView.autoPinEdge(toSuperviewEdge: .bottom)
            keyboardResizableView.setReferenceBottomConstraint(constraint)

            commentComposerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
            commentComposerView.autoSetDimension(.height, toSize: commentComposerViewHeight)

            let insets = UIEdgeInsets(top: topLayoutGuideOffset + 10, left: 10, bottom: 0, right: 10)
            let commentComposerInset = shouldShowCommentComposerView ? commentComposerViewHeight : 0
            collectionViewCornerWrapperView.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: .bottom)
            collectionViewCornerWrapperView.autoPinEdge(toSuperviewEdge: .bottom, withInset: commentComposerInset)

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
    
    // MARK: public
    
    func customizeFor3DTouch(_ hidden: Bool) {
        backgroundColor = hidden ? .backgroundGrayColor() : .clear
    }
    
    func hideKeyboard() {
        commentComposerView.makeInactive()
    }
}
