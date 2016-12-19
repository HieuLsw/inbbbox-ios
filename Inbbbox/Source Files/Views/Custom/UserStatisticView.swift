//
//  UserStatisticView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class UserStatisticView: UIView {

    private lazy var statisticValueLabel: UILabel = { [unowned self] in
        self.getLabel(fontSize: 24, textColor: .textDarkColor())
    }()

    private lazy var statisticTitleLabel: UILabel = { [unowned self] in
        self.getLabel(fontSize: 12, textColor: .textLightGrayColor())
    }()

    private lazy var stackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [self.statisticValueLabel, self.statisticTitleLabel]
        )

        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 19, left: 0, bottom: 13, right: 0)

        return stackView
    }()

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(statisticTitle: String, statisticValue: String) {
        super.init(frame: .zero)
        statisticTitleLabel.text = statisticTitle
        statisticValueLabel.text = statisticValue
        setupLayout()
    }

    private func setupLayout() {
        autoSetDimension(.height, toSize: 80)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    private func getLabel(fontSize: CGFloat, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
        label.textColor = textColor
        return label
    }
}
