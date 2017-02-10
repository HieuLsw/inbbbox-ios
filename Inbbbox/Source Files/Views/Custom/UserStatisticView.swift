//
//  UserStatisticView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

final class UserStatisticView: UIView {

    private(set) lazy var valueLabel: UILabel = { [unowned self] in
        self.label(fontSize: 24, textColor: ColorModeProvider.current().statisticValueTextColor)
    }()

    private lazy var titleLabel: UILabel = { [unowned self] in
        self.label(fontSize: 12, textColor: ColorModeProvider.current().statisticNameTextColor)
    }()

    private lazy var stackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [self.valueLabel, self.titleLabel]
        )
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 19, left: 0, bottom: 13, right: 0)

        return stackView
    }()

    @available(*, unavailable, message: "Use init(title:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupLayout()
    }

    private func setupLayout() {
        autoSetDimension(.height, toSize: 80)
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }

    private func label(fontSize: CGFloat, textColor: UIColor) -> UILabel {
        let label = UILabel()

        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
        label.textColor = textColor

        return label
    }
}
