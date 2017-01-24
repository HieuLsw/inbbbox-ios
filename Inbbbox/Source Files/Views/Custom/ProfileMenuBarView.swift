//
//  ProfileMenuBarView.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

class ProfileMenuBarView: UIView {

    var didSelectItem: ((ProfileMenuItem) -> Void)?

    let menuStackView = UIStackView()

    fileprivate let shotsButton = UIButton()
    fileprivate let infoButton = UIButton()
    fileprivate let projectsButton = UIButton()
    fileprivate let bucketsButton = UIButton()
    fileprivate let underlineBarView = UnderlineBarView()

    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

        deselectAllItems()

        shotsButton.setTitle("Shots", for: .normal)
        infoButton.setTitle("Info", for: .normal)
        projectsButton.setTitle("Projects", for: .normal)
        bucketsButton.setTitle("Buckets", for: .normal)

        [shotsButton, infoButton, projectsButton, bucketsButton].forEach {
            $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            $0.addTarget(self, action: #selector(didSelect(button:)), for: .touchUpInside)
        }

        menuStackView.addArrangedSubview(shotsButton)
        menuStackView.addArrangedSubview(infoButton)
        menuStackView.addArrangedSubview(projectsButton)
        menuStackView.addArrangedSubview(bucketsButton)

        menuStackView.distribution = .fillEqually
        
        menuStackView.spacing = 10

        addSubview(menuStackView)
        addSubview(underlineBarView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            menuStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            menuStackView.autoPinEdge(.bottom, to: .top, of: underlineBarView)

            underlineBarView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            underlineBarView.autoSetDimension(.height, toSize: 2)

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
    
    func select(item: ProfileMenuItem) {
        let button: UIButton = {
            switch item {
            case .shots: return shotsButton
            case .info: return infoButton
            case .projects: return projectsButton
            case .buckets: return bucketsButton
            }
        }()
        deselectAllItems()
        select(button: button)
    }
}

private extension ProfileMenuBarView {

    dynamic func didSelect(button: UIButton) {
        deselectAllItems()
        select(button: button)

        let item: ProfileMenuItem? = {
            switch button {
            case shotsButton: return .shots
            case infoButton: return .info
            case projectsButton: return .projects
            case bucketsButton: return .buckets
            default: return nil
            }
        }()

        if let item = item {
            didSelectItem?(item)
        }
    }

    func select(button: UIButton) {
        button.setTitleColor(.RGBA(26, 26, 26, 1), for: .normal)
        underlineBarView.underline(frame: button.frame)
    }


    func deselectAllItems() {
        [shotsButton, infoButton, projectsButton, bucketsButton].forEach {
            $0.setTitleColor(.RGBA(148, 147, 153, 1), for: .normal)
        }
    }
}
