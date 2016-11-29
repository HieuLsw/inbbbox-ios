//
// Created by Lukasz Pikor on 26.04.2016.
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

extension AppDelegate {

    func rollbackToLoginViewController() {
        let centerTabBarController = CenterButtonTabBarController()
        loginViewController = LoginViewController(tabBarController: centerTabBarController)
        let rootViewController = loginViewController!
        centerButtonTabBarController = rootViewController.centerButtonTabBarController
        UIApplication.shared.keyWindow?.setRootViewController(rootViewController, transition: nil)
    }
}
