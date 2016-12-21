//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileInfoView: UIView {

    let followersAmountView = UserStatisticView(title: "Followers")
    let shotsAmountView = UserStatisticView(title: "Shots")
    let followingAmountView = UserStatisticView(title: "Following")
    let locationView = LocationView(location: "Gdańsk, Poland")

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
                SeparatorView(axis: .vertical, thickness: 0.5, color: .separatorGrayColor())
            ]
        )
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var informationsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.locationView,
                self.userDescription,
            ]
        )
        stackView.layoutMargins = UIEdgeInsetsMake(16, 0, 0, 12)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12

        return stackView
    }()

    var teamsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    var teamsCollectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupLayout()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .white

        addSubview(headerStackView)
        headerStackView.autoPinEdge(toSuperviewEdge: .top)
        headerStackView.autoPinEdge(toSuperviewEdge: .left)
        headerStackView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(informationsStackView)
        informationsStackView.autoPinEdge(.top, to: .bottom, of: headerStackView)
        informationsStackView.autoPinEdge(toSuperviewEdge: .left)
        informationsStackView.autoPinEdge(toSuperviewEdge: .right)

        addSubview(teamsCollectionView)
        teamsCollectionView.autoPinEdge(.top, to: .bottom, of: informationsStackView)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .left)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .right)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .bottom)
    }

    private func setupCollectionView() {
        teamsCollectionViewFlowLayout.headerReferenceSize = CGSize(width: frame.size.width, height: 60)

        teamsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: teamsCollectionViewFlowLayout)
        teamsCollectionView.backgroundColor = .green
    }

}
