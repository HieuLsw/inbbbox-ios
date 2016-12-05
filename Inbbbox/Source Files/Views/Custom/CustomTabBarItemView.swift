//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CustomTabBarItemView: UIView {

    private var didSetConstraints = false
    let nameLabel = UILabel.newAutoLayoutView()
    let iconImageView = UIImageView.newAutoLayoutView()

//    MARK: - Life cycle

    init(name: String? = nil, icon: UIImage?) {
        super.init(frame: CGRect.zero)

        nameLabel.font = UIFont.systemFontOfSize(10)
        nameLabel.textColor = ColorModeProvider.current().tabBarNormalItemTextColor
        nameLabel.text = name
        addSubview(nameLabel)

        iconImageView.image = icon?.imageWithRenderingMode(.AlwaysOriginal)
        addSubview(iconImageView)
    }

    @available(*, unavailable, message="Use init(name:icon:) instead")
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message="Use init(name:icon:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    MARK: - UIView

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            iconImageView.autoPinEdgeToSuperviewEdge(.Top)
            iconImageView.autoAlignAxisToSuperviewAxis(.Vertical)
            nameLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: iconImageView, withOffset: 2.0)
            nameLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            nameLabel.autoAlignAxisToSuperviewAxis(.Vertical)
            didSetConstraints = true
        }

        super.updateConstraints()
    }
}
