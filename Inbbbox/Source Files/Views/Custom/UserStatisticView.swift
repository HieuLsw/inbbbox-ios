//
//  UserStatisticView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class UserStatisticView: UIView {

    private lazy var statisticValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightBold)
        return label
    }()

    private lazy var statisticTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightMedium)
        label.textColor = UIColor.textDarkColor()
        return label
    }()

    private lazy var stackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [self.statisticValueLabel, self.statisticTitleLabel]
        )
        stackView.axis = .vertical
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(statisticTitle: String, statisticValue: String) {
        self.init(frame: .zero)
        autoSetDimension(.height, toSize: 80)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        statisticTitleLabel.text = statisticTitle
        statisticValueLabel.text = statisticValue
    }
}
