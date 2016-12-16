//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileInfoView: UIView {

    private lazy var followersAmountView: UserStatisticView = {
        UserStatisticView(statisticTitle: "Followers", statisticValue: "326")
    }()

    private lazy var shotsAmountView: UIView = {
        UserStatisticView(statisticTitle: "Shots", statisticValue: "52")
    }()

    private lazy var followingAmountView: UIView = {
        UserStatisticView(statisticTitle: "Following", statisticValue: "154")
    }()

    private lazy var statisticsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [self.followersAmountView, self.shotsAmountView, self.followingAmountView]
        )
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(statisticsStackView)
        statisticsStackView.autoPinEdge(toSuperviewEdge: .top)
        statisticsStackView.autoPinEdge(toSuperviewEdge: .left)
        statisticsStackView.autoPinEdge(toSuperviewEdge: .right)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
