//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ShotsCollectionBackgroundView: UIView {

    let logoImageView = UIImageView(image: UIImage(named: "logo-type-home"))
    private var didSetConstraints = false

//    MARK: - Life cycle

    convenience init() {
        self.init(frame: CGRect.zero)

        backgroundColor = UIColor.backgroundGrayColor()

        logoImageView.configureForAutoLayout()
        addSubview(logoImageView)
    }

//    MAKR: - UIView

    override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }

    override func updateConstraints() {

        if !didSetConstraints {
            logoImageView.autoPinEdgeToSuperviewEdge(.Top, withInset: 60)
            logoImageView.autoAlignAxisToSuperviewAxis(.Vertical)
            didSetConstraints = true
        }

        super.updateConstraints()
    }
}
