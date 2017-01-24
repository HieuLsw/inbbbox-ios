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

    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white

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
        }

        super.updateConstraints()
    }
}
