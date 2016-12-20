//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileInfoView: UIView {

    private lazy var followersAmountView = UserStatisticView(title: "Followers", value: "326")

    private lazy var shotsAmountView = UserStatisticView(title: "Shots", value: "52")

    private lazy var followingAmountView = UserStatisticView(title: "Following", value: "154")

    private lazy var locationView = LocationView(location: "Gdańsk, Poland")

    private lazy var userDescription: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        label.numberOfLines = 0
        label.textColor = .textMediumGrayColor()
        label.textAlignment = .center
        label.text = "9 years experience Product Designer - shuma87@gmail.com"
        return label
    }()

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
                SeparatorView(axis: .vertical, thickness: 0.5, color: .separatorGrayColor()),
                self.locationView
            ]
        )
        stackView.axis = .vertical

        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(headerStackView)
        headerStackView.autoPinEdge(toSuperviewEdge: .top)
        headerStackView.autoPinEdge(toSuperviewEdge: .left)
        headerStackView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(locationView)
        locationView.autoPinEdge(.top, to: .bottom, of: headerStackView)
        locationView.autoAlignAxis(.vertical, toSameAxisOf: headerStackView)

        addSubview(userDescription)
        userDescription.autoPinEdge(.top, to: .bottom, of: locationView)
        userDescription.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
        userDescription.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
        userDescription.autoAlignAxis(.vertical, toSameAxisOf: headerStackView)
    }

}
