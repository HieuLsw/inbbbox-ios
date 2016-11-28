//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CustomTabBarItemView: UIView {

    fileprivate var didSetConstraints = false
    let nameLabel = UILabel.newAutoLayout()
    let iconImageView = UIImageView.newAutoLayout()

//    MARK: - Life cycle

    init(name: String? = nil, icon: UIImage?) {
        super.init(frame: CGRect.zero)

        nameLabel.font = UIFont.systemFont(ofSize: 10)
        nameLabel.textColor = ColorModeProvider.current().tabBarNormalItemTextColor
        nameLabel.text = name
        addSubview(nameLabel)

        iconImageView.image = icon?.withRenderingMode(.alwaysOriginal)
        addSubview(iconImageView)
    }

    @available(*, unavailable, message: "Use init(name:icon:) instead")
    override init(frame: CGRect) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(name:icon:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    MARK: - UIView

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            iconImageView.autoPinEdge(toSuperviewEdge: .top)
            iconImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            nameLabel.autoPinEdge(.top, to: .bottom, of: iconImageView, withOffset: 2.0)
            nameLabel.autoPinEdge(toSuperviewEdge: .bottom)
            nameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            didSetConstraints = true
        }

        super.updateConstraints()
    }
}
