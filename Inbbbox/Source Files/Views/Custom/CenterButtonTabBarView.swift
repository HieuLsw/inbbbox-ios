//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class CenterButtonTabBarView: UITabBar {

    fileprivate var didSetConstraints = false
    fileprivate var dummyItemScreenSizeDependentWidth: CGFloat {
        switch frame.width {
            case 0 ..< 375: return 60
            case 376 ..< CGFloat.infinity: return 76
            default: return 70
        }
    }

    fileprivate(set) var likesItemViewVerticalConstraint: NSLayoutConstraint?
    fileprivate(set) var bucketsItemViewVerticalConstraint: NSLayoutConstraint?
    fileprivate(set) var followingItemViewVerticalConstraint: NSLayoutConstraint?
    fileprivate(set) var accountItemViewVerticalConstraint: NSLayoutConstraint?

    fileprivate let likesItemView: CustomTabBarItemView
    fileprivate let bucketsItemView: CustomTabBarItemView
    fileprivate let followingItemView: CustomTabBarItemView
    fileprivate let accountItemView: CustomTabBarItemView
    fileprivate let dummyItemView = CustomTabBarItemView(name: "", icon: nil)
    fileprivate let itemViewDefaultInset: CGFloat = 14

//    MARK: - Life cycle

    @available(*, unavailable, message: "Use init() or init(frame:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        likesItemView = CustomTabBarItemView(icon: UIImage(named: "ic-likes"))
        bucketsItemView = CustomTabBarItemView(icon: UIImage(named: "ic-buckets"))
        accountItemView = CustomTabBarItemView(icon: UIImage(named: "ic-settings"))
        followingItemView = CustomTabBarItemView(icon: UIImage(named: "ic-following"))

        super.init(frame: frame)

        isUserInteractionEnabled = false

        _ = { // these two lines hide top border line of tabBar - can't be separated, so I packed them into closure
            shadowImage = UIImage()
            backgroundImage = UIImage()
        }()

        isTranslucent = false

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

            likesItemViewVerticalConstraint = likesItemView.autoPinEdge(toSuperviewEdge: .top, withInset: itemViewDefaultInset)
            likesItemView.autoPinEdge(toSuperviewEdge: .left)
            likesItemView.autoPinEdge(.right, to: .left, of: bucketsItemView)

            bucketsItemViewVerticalConstraint = bucketsItemView.autoPinEdge(toSuperviewEdge: .top, withInset: itemViewDefaultInset)
            bucketsItemView.autoPinEdge(.right, to: .left, of: dummyItemView, withOffset: -3)
            bucketsItemView.autoMatch(.width, to: .width, of: likesItemView)

            dummyItemView.autoPinEdge(toSuperviewEdge: .top, withInset: 7)
            dummyItemView.autoPinEdge(toSuperviewEdge: .bottom)
            dummyItemView.autoAlignAxis(toSuperviewAxis: .vertical)
            dummyItemView.autoSetDimension(.width, toSize: dummyItemScreenSizeDependentWidth)

            followingItemViewVerticalConstraint = followingItemView.autoPinEdge(toSuperviewEdge: .top, withInset: itemViewDefaultInset)
            followingItemView.autoPinEdge(.left, to: .right, of: dummyItemView, withOffset: 2.5)
            followingItemView.autoMatch(.width, to: .width, of: accountItemView)

            accountItemViewVerticalConstraint = accountItemView.autoPinEdge(toSuperviewEdge: .top, withInset: itemViewDefaultInset)
            accountItemView.autoPinEdge(.left, to: .right, of: followingItemView)
            accountItemView.autoPinEdge(toSuperviewEdge: .right)
        }

        super.updateConstraints()
    }
}
