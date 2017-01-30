//
//  TeamsCollectionHeaderView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

final class TeamsCollectionHeaderView: UICollectionReusableView, Reusable {

    private lazy var headerTitleLabel: UILabel = { [unowned self] in
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightBold)
        label.textColor = .textDarkGrayColor()
        label.text = Localized("TeamsCollectionHeaderView.OnTeams", comment: "Teams table's header")

        return label
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
        addSubview(headerTitleLabel)
        headerTitleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        headerTitleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
    }

}
