//
//  LocationView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import PureLayout
import UIKit

class LocationView: UIView {

    let location: String

    private lazy var earthImageView = UIImageView(image: UIImage(named: "ic-location"))

    private lazy var locationLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        label.textColor = .textGrayColor()
        label.text = self.location
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

    init(location: String) {
        self.location = location
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
