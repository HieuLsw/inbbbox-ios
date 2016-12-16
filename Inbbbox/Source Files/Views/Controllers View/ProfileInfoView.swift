//
//  ProfileInfoView.swift
//  Inbbbox
//
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

class ProfileInfoView: UIView {

    private lazy var followersAmountView: UIView = { [unowned self] in
        let view = UIView(frame: .zero)
        view.backgroundColor = .red
        return view
    }()

    private lazy var shotsAmountView: UIView = { [unowned self] in
        let view = UIView(frame: .zero)
        view.backgroundColor = .green
        return view
    }()

    private lazy var followingAmountView: UIView = { [unowned self] in
        let view = UIView(frame: .zero)
        view.backgroundColor = .blue
        return view
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
        statisticsStackView.autoPinEdgesToSuperviewEdges()
    }

    @available(*, unavailable, message: "Use init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
