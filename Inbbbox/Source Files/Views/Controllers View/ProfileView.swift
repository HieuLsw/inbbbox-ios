//
//  ProfileView.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileView: UIView {

    static let headerInitialHeight = CGFloat(150)

    let headerView = ProfileHeaderView()
    let menuBarView = ProfileMenuBarView()

    var childView = UIView()

    fileprivate let headerHeight = CGFloat(150)
    fileprivate var headerHeightConstraint: NSLayoutConstraint?
    fileprivate var isHeaderVisible: Bool = true
    fileprivate var didSetConstraints = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = ColorModeProvider.current().tableViewBackground

        addSubview(childView)
        addSubview(headerView)
        addSubview(menuBarView)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            headerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            headerHeightConstraint = headerView.autoSetDimension(.height, toSize: headerHeight)

            menuBarView.autoPinEdge(toSuperviewEdge: .leading)
            menuBarView.autoPinEdge(toSuperviewEdge: .trailing)
            menuBarView.autoPinEdge(.top, to: .bottom, of: headerView)
            menuBarView.autoSetDimension(.height, toSize: 48)

            childView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            childView.autoPinEdge(toSuperviewEdge: .top, withInset: 48)
        }

        super.updateConstraints()
    }

    // MARK: Public

    /// Sets header's height. Note: you can pass negative values, they will be properly mapped/ignored.
    ///
    /// - Parameter value: Value of header's height
    func setHeaderHeight(value: CGFloat) {
        headerHeightConstraint?.constant = value > 0 ? value : 0

        if value > headerHeight {
            headerView.contentView.alpha = 1
            headerView.setBackgroundImageOffset(value: value / headerHeight)
        } else if value < 0 {
            headerView.contentView.alpha = 0
        } else {
            headerView.contentView.alpha = value / headerHeight
        }
    }
}
