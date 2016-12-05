//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CenterButtonTabBarView: UITabBar {

    private var didSetConstraints = false
    private var dummyItemScreenSizeDependentWidth: CGFloat {
        switch CGRectGetWidth(frame) {
            case 0 ..< 375: return 60
            case 376 ..< CGFloat.infinity: return 76
            default: return 70
        }
    }

    private(set) var likesItemViewVerticalConstraint: NSLayoutConstraint?
    private(set) var bucketsItemViewVerticalConstraint: NSLayoutConstraint?
    private(set) var followingItemViewVerticalConstraint: NSLayoutConstraint?
    private(set) var accountItemViewVerticalConstraint: NSLayoutConstraint?

    private let likesItemView: CustomTabBarItemView
    private let bucketsItemView: CustomTabBarItemView
    private let followingItemView: CustomTabBarItemView
    private let accountItemView: CustomTabBarItemView
    private let dummyItemView = CustomTabBarItemView(name: "", icon: nil)
    private let itemViewDefaultInset: CGFloat = 14

//    MARK: - Life cycle

    @available(*, unavailable, message = "Use init() or init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        likesItemView = CustomTabBarItemView(icon: UIImage(named: "ic-likes"))
        bucketsItemView = CustomTabBarItemView(icon: UIImage(named: "ic-buckets"))
        accountItemView = CustomTabBarItemView(icon: UIImage(named: "ic-settings"))
        followingItemView = CustomTabBarItemView(icon: UIImage(named: "ic-following"))

        super.init(frame: frame)

        userInteractionEnabled = false

        _ = { // these two lines hide top border line of tabBar - can't be separated, so I packed them into closure
            shadowImage = UIImage()
            backgroundImage = UIImage()
        }()

        translucent = false

        likesItemView.configureForAutoLayout()
        addSubview(likesItemView)

        bucketsItemView.configureForAutoLayout()
        addSubview(bucketsItemView)

        dummyItemView.configureForAutoLayout()
        addSubview(dummyItemView)

        followingItemView.configureForAutoLayout()
        addSubview(followingItemView)

        accountItemView.configureForAutoLayout()
        addSubview(accountItemView)
    }

    override func updateConstraints() {

        if !didSetConstraints {
            didSetConstraints = true

            likesItemViewVerticalConstraint = likesItemView.autoPinEdgeToSuperviewEdge(.Top, withInset: itemViewDefaultInset)
            likesItemView.autoPinEdgeToSuperviewEdge(.Left)
            likesItemView.autoPinEdge(.Right, toEdge: .Left, ofView: bucketsItemView)

            bucketsItemViewVerticalConstraint = bucketsItemView.autoPinEdgeToSuperviewEdge(.Top, withInset: itemViewDefaultInset)
            bucketsItemView.autoPinEdge(.Right, toEdge: .Left, ofView: dummyItemView, withOffset: -3)
            bucketsItemView.autoMatchDimension(.Width, toDimension: .Width, ofView: likesItemView)

            dummyItemView.autoPinEdgeToSuperviewEdge(.Top, withInset: 7)
            dummyItemView.autoPinEdgeToSuperviewEdge(.Bottom)
            dummyItemView.autoAlignAxisToSuperviewAxis(.Vertical)
            dummyItemView.autoSetDimension(.Width, toSize: dummyItemScreenSizeDependentWidth)

            followingItemViewVerticalConstraint = followingItemView.autoPinEdgeToSuperviewEdge(.Top, withInset: itemViewDefaultInset)
            followingItemView.autoPinEdge(.Left, toEdge: .Right, ofView: dummyItemView, withOffset: 2.5)
            followingItemView.autoMatchDimension(.Width, toDimension: .Width, ofView: accountItemView)

            accountItemViewVerticalConstraint = accountItemView.autoPinEdgeToSuperviewEdge(.Top, withInset: itemViewDefaultInset)
            accountItemView.autoPinEdge(.Left, toEdge: .Right, ofView: followingItemView)
            accountItemView.autoPinEdgeToSuperviewEdge(.Right)
        }

        super.updateConstraints()
    }
}
