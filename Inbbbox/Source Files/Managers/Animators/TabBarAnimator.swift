//
//  TabBarAnimator.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 21/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit

class TabBarAnimator {

    fileprivate let centerButton = RoundedButton()
    fileprivate let tabBarView = CenterButtonTabBarView()
    fileprivate var tabBarHeight: CGFloat {
        return tabBarView.intrinsicContentSize.height
    }

    init(view: LoginView) {

        let tabBarHeight = tabBarView.intrinsicContentSize.height

        tabBarView.layer.shadowColor = UIColor(white: 0, alpha: 0.03).cgColor
        tabBarView.layer.shadowRadius = 1
        tabBarView.layer.shadowOpacity = 0.6

        view.addSubview(tabBarView)
        tabBarView.frame = CGRect(
            x: 0,
            y: view.frame.maxY,
            width: view.frame.width,
            height: tabBarHeight
        )
        tabBarView.layoutIfNeeded()
        centerButton.setImage(UIImage(named: "ic-ball-active"), for: .normal)
        centerButton.backgroundColor = .white
        tabBarView.addSubview(centerButton)
        centerButton.frame = CGRect(
            x: tabBarView.frame.width / 2 - centerButton.intrinsicContentSize.width / 2,
            y: -centerButton.intrinsicContentSize.height - 8,
            width: centerButton.intrinsicContentSize.width,
            height: centerButton.intrinsicContentSize.height
        )
    }

    func animateTabBar() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            firstly {
                prepare()
            }.then {
                self.fadeCenterButtonIn()
            }.then {
                when(fulfilled: [self.slideTabBar(), self.slideTabBarItemsSubsequently(), self.positionCenterButton()])
            }.then {
                fulfill()
            }.catch { _ in }
        }
    }
}

private extension TabBarAnimator {

    func slideTabBarItemsSubsequently() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            UIView.animateKeyframes(withDuration: 1, delay: 0, options: .layoutSubviews, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                    self.tabBarView.likesItemViewVerticalConstraint?.constant -= self.tabBarHeight
                    self.tabBarView.layoutIfNeeded()
                })
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                    self.tabBarView.bucketsItemViewVerticalConstraint?.constant -= self.tabBarHeight
                    self.tabBarView.layoutIfNeeded()
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                    self.tabBarView.followingItemViewVerticalConstraint?.constant -= self.tabBarHeight
                    self.tabBarView.layoutIfNeeded()
                })
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                    self.tabBarView.accountItemViewVerticalConstraint?.constant -= self.tabBarHeight
                    self.tabBarView.layoutIfNeeded()
                })
            }, completion: { _ in
                fulfill()
            })
        }
    }

    func slideTabBar() -> Promise<Void> {

        var frame = tabBarView.frame
        frame.origin.y -= tabBarHeight

        return Promise<Void> { fulfill, _ in

            UIView.animate(withDuration: 0.5, animations: {
                self.tabBarView.frame = frame
            }, completion: { _ in
                fulfill()
            })
        }
    }

    func positionCenterButton() -> Promise<Void> {

        var frame = centerButton.frame
        frame.origin.y += tabBarHeight

        return Promise<Void> { fulfill, _ in

            UIView.animate(withDuration: 0.5, animations: {
                self.centerButton.frame = frame
            }, completion: { _ in
                fulfill()
            })
        }
    }

    func fadeCenterButtonIn() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [], animations: {
                self.centerButton.alpha = 1
            }, completion: { _ in
                fulfill()
            })
        }
    }

    func prepare() -> Promise<Void> {

        tabBarView.likesItemViewVerticalConstraint?.constant += tabBarHeight
        tabBarView.bucketsItemViewVerticalConstraint?.constant += tabBarHeight
        tabBarView.followingItemViewVerticalConstraint?.constant += tabBarHeight
        tabBarView.accountItemViewVerticalConstraint?.constant += tabBarHeight

        centerButton.alpha = 0.0
        return Promise<Void>(value:Void())
    }
}
