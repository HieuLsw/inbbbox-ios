//
//  LocationView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

final class LocationView: UIView {

    private lazy var earthImageView = UIImageView(image: UIImage(named: "ic-location"))

    private(set) lazy var locationLabel: UILabel = { [unowned self] in
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        label.textColor = .textGrayColor()

        return label
    }()

    private lazy var stackView: UIStackView = { [unowned self] in
        let stackView = UIStackView(
            arrangedSubviews: [self.earthImageView, self.locationLabel]
        )
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
    }
}
