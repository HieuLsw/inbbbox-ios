//
//  ProfileView.swift
//  Inbbbox
//
//  Created by Peter Bruz on 23/01/2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileView: UIView {

    let headerView = ProfileHeaderView()
    let menuBarView = ProfileMenuBarView()

    var childView = UIView()

//    let collectionView: UICollectionView
//    let commentComposerView = CommentComposerView.newAutoLayout()

//    var shouldShowCommentComposerView = true {
//        willSet(newValue) {
//            commentComposerView.isHidden = !newValue
//        }
//    }
//    var topLayoutGuideOffset = CGFloat(0)

//    fileprivate let collectionViewCornerWrapperView = UIView.newAutoLayout()
//    let keyboardResizableView = KeyboardResizableView.newAutoLayout()
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

//        collectionViewCornerWrapperView.backgroundColor = .clear
//        collectionViewCornerWrapperView.clipsToBounds = true
//        collectionViewCornerWrapperView.addSubview(collectionView)
//
//        keyboardResizableView.automaticallySnapToKeyboardTopEdge = true
//        keyboardResizableView.addSubview(collectionViewCornerWrapperView)
//        keyboardResizableView.addSubview(commentComposerView)
//        addSubview(keyboardResizableView)

        addSubview(headerView)
        addSubview(menuBarView)
        addSubview(childView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            headerView.autoSetDimension(.height, toSize: 150)

            menuBarView.autoPinEdge(toSuperviewEdge: .leading)
            menuBarView.autoPinEdge(toSuperviewEdge: .trailing)
            menuBarView.autoPinEdge(.top, to: .bottom, of: headerView)
            menuBarView.autoSetDimension(.height, toSize: 48)

            childView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            childView.autoPinEdge(.top, to: .bottom, of: menuBarView)

//            let commentComposerViewHeight = CGFloat(61)
//            keyboardResizableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .bottom)
//            let constraint = keyboardResizableView.autoPinEdge(toSuperviewEdge: .bottom)
//            keyboardResizableView.setReferenceBottomConstraint(constraint)
//
//            commentComposerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
//            commentComposerView.autoSetDimension(.height, toSize: commentComposerViewHeight)
//
//            let insets = UIEdgeInsets(top: topLayoutGuideOffset + 10, left: 10, bottom: 0, right: 10)
//            let commentComposerInset = shouldShowCommentComposerView ? commentComposerViewHeight : 0
//            collectionViewCornerWrapperView.autoPinEdgesToSuperviewEdges(with: insets, excludingEdge: .bottom)
//            collectionViewCornerWrapperView.autoPinEdge(toSuperviewEdge: .bottom, withInset: commentComposerInset)
//
//            collectionView.autoPinEdgesToSuperviewEdges()
        }

        super.updateConstraints()
    }

    // MARK: public



//    func hideKeyboard() {
//        commentComposerView.makeInactive()
//    }
}
