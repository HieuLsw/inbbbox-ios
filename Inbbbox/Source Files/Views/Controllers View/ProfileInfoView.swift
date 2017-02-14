//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout
import TTTAttributedLabel

final class ProfileInfoView: UIView {

    let followersAmountView = UserStatisticView(title: Localized("ProfileInfoView.Followers", comment: "Followers"))
    let shotsAmountView = UserStatisticView(title: Localized("ProfileInfoView.Shots", comment: "Shots"))
    let followingAmountView = UserStatisticView(title: Localized("ProfileInfoView.Following", comment: "Following"))
    let locationView = LocationView()
    let scrollView = UIScrollView(frame: .zero)

    private(set) lazy var bioLabel: TTTAttributedLabel = { [unowned self] in
        let label = TTTAttributedLabel.newAutoLayout()

        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.linkAttributes = [NSForegroundColorAttributeName : UIColor.pinkColor()]
        label.textAlignment = .center

        return label
    }()

    private lazy var statisticsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.followersAmountView,
                SeparatorView(axis: .horizontal, thickness: 0.5, color: ColorModeProvider.current().separatorColor),
                self.shotsAmountView,
                SeparatorView(axis: .horizontal, thickness: 0.5, color: ColorModeProvider.current().separatorColor),
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
                SeparatorView(axis: .vertical, thickness: 0.5, color: ColorModeProvider.current().separatorColor),
                self.statisticsStackView,
                SeparatorView(axis: .vertical, thickness: 0.5, color: ColorModeProvider.current().separatorColor)
            ]
        )
        stackView.axis = .vertical

        return stackView
    }()

    private lazy var informationsStackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [
                self.locationView,
                self.bioLabel,
            ]
        )
        stackView.layoutMargins = UIEdgeInsetsMake(16, 16, 12, 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12

        return stackView
    }()

    private(set) var teamsCollectionView: UICollectionView
    private(set) var teamsCollectionViewFlowLayout: UICollectionViewFlowLayout
    private(set) var teamMembersTableView: UITableView
    private(set) var likedShotsTableView: UITableView

    override init(frame: CGRect) {
        teamsCollectionViewFlowLayout = UICollectionViewFlowLayout()
        teamsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: teamsCollectionViewFlowLayout)
        teamMembersTableView = UITableView(frame: .zero)
        likedShotsTableView = UITableView(frame: .zero)
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

        addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewEdges()

        scrollView.addSubview(headerStackView)
        headerStackView.autoPinEdge(toSuperviewEdge: .top)
        headerStackView.autoPinEdge(toSuperviewEdge: .left)
        headerStackView.autoPinEdge(toSuperviewEdge: .right)
        headerStackView.autoMatch(.width, to: .width, of: self)
        
        scrollView.addSubview(informationsStackView)
        informationsStackView.autoPinEdge(.top, to: .bottom, of: headerStackView)
        informationsStackView.autoPinEdge(toSuperviewEdge: .left)
        informationsStackView.autoPinEdge(toSuperviewEdge: .right)

        scrollView.addSubview(likedShotsTableView)
        likedShotsTableView.autoPinEdge(.top, to: .bottom, of: informationsStackView)
        likedShotsTableView.autoPinEdge(toSuperviewEdge: .left)
        likedShotsTableView.autoPinEdge(toSuperviewEdge: .right)
        
        scrollView.addSubview(teamsCollectionView)
        teamsCollectionView.autoPinEdge(.top, to: .bottom, of: likedShotsTableView)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .left)
        teamsCollectionView.autoPinEdge(toSuperviewEdge: .right)

        scrollView.addSubview(teamMembersTableView)
        teamMembersTableView.autoPinEdge(.top, to: .bottom, of: informationsStackView)
        teamMembersTableView.autoPinEdge(toSuperviewEdge: .left)
        teamMembersTableView.autoPinEdge(toSuperviewEdge: .right)
    }

    private func setupCollectionView() {
        teamsCollectionViewFlowLayout.headerReferenceSize = CGSize(width: frame.size.width, height: 60)
        teamsCollectionViewFlowLayout.minimumInteritemSpacing = 0
        teamsCollectionViewFlowLayout.minimumLineSpacing = 0
    }

    func updateLayout() {
        teamsCollectionView.autoSetDimension(.height, toSize: teamsCollectionView.contentSize.height + 60)
        teamMembersTableView.autoSetDimension(.height, toSize: teamMembersTableView.contentSize.height)
        likedShotsTableView.autoSetDimension(.height, toSize: likedShotsTableView.contentSize.height)
        
        var scrollViewContentSize = headerStackView.frame.size.height + informationsStackView.frame.size.height
        
        if !teamsCollectionView.isHidden {
            scrollViewContentSize += teamsCollectionView.contentSize.height + 60 + 16
        }
        
        if !teamMembersTableView.isHidden {
            scrollViewContentSize += teamMembersTableView.contentSize.height + likedShotsTableView.contentSize.height
        }
        scrollView.contentSize.height = scrollViewContentSize
    }

}
