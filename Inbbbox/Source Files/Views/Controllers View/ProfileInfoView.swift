//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileInfoView: UIView {

    private lazy var followersAmountView: UserStatisticView = UserStatisticView(statisticTitle: "Followers", statisticValue: "326")

    private lazy var shotsAmountView: UIView = UserStatisticView(statisticTitle: "Shots", statisticValue: "52")

    private lazy var followingAmountView: UIView = UserStatisticView(statisticTitle: "Following", statisticValue: "154")

    private lazy var statisticsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.followersAmountView,
                SeparatorView(axis: .horizontal, thickness: 0.5, color: .separatorGrayColor()),
                self.shotsAmountView,
                SeparatorView(axis: .horizontal, thickness: 0.5, color: .separatorGrayColor()),
                self.followingAmountView
            ]
        )
        stackView.axis = .horizontal

        self.followersAmountView.autoMatch(.width, to: .width, of: self.followingAmountView)
        self.followersAmountView.autoMatch(.width, to: .width, of: self.shotsAmountView)

        return stackView
    }()

    private lazy var headerStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                SeparatorView(axis: .vertical, thickness: 0.5, color: .separatorGrayColor()),
                self.statisticsStackView,
                SeparatorView(axis: .vertical, thickness: 0.5, color: .separatorGrayColor())
            ]
        )
        stackView.axis = .vertical

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerStackView)
        headerStackView.autoPinEdge(toSuperviewEdge: .top)
        headerStackView.autoPinEdge(toSuperviewEdge: .left)
        headerStackView.autoPinEdge(toSuperviewEdge: .right)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
