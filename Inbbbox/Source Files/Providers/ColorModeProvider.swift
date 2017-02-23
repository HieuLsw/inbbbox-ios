//
//  ColorModeProvider.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 26.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

enum ColorMode: String {
    case dayMode
    case nightMode
}

final class ColorModeProvider {

    // MARK: Internal

    class func setup() {
        if let mode = NightModeHoursProvider.currentColorModeBasedOnTime(), Settings.Customization.AutoNightMode {
            select(mode)
        } else {
            let currentMode = Settings.Customization.CurrentColorMode
            select(currentMode)
        }
    }

    class func change(to mode: ColorMode) {
        Settings.Customization.CurrentColorMode = mode
        ColorModeProvider.setup()
    }

    class func current() -> ColorModeType {
        let currentMode = Settings.Customization.CurrentColorMode
        switch currentMode {
        case .dayMode: return DayMode()
        case .nightMode: return NightMode()
        }
    }

    // MARK: Private

    fileprivate class func select(_ mode: ColorMode) {
        switch mode {
            case .dayMode:
                let mode = DayMode()
                ColorModeProvider.adaptInterface(to: mode)
                ColorModeProvider.adaptInterfaceToCustomViews(to: mode)
            case .nightMode:
                let mode = NightMode()
                ColorModeProvider.adaptInterface(to: mode)
                ColorModeProvider.adaptInterfaceToCustomViews(to: mode)
        }
    }

    fileprivate class func adaptInterface(to mode: ColorModeType) {
        UITabBar.appearance().barTintColor = mode.tabBarTint
        UITabBar.appearance().backgroundColor = mode.windowBackgroundColor
        UINavigationBar.appearance().barTintColor = mode.navigationBarTint
        UITableView.appearance().backgroundColor = mode.tableViewBackground
        UITableView.appearance().separatorColor = mode.cellSeparator
        UITableViewCell.appearance().backgroundColor = mode.tableViewCellBackground
        ShotsCollectionBackgroundView.appearance().backgroundColor = mode.shotsCollectionBackground
        ShotBucketsAddCollectionViewCell.appearance().backgroundColor = mode.shotBucketsAddCollectionViewCellBackground
        ShotBucketsSeparatorCollectionViewCell.appearance().backgroundColor = mode.shotBucketsSeparatorCollectionViewCellBackground
        ShotBucketsHeaderView.appearance().backgroundColor = mode.shotBucketsHeaderViewBackground
        ShotBucketsFooterView.appearance().backgroundColor = mode.shotBucketsFooterViewBackground
        ShotBucketsActionCollectionViewCell.appearance().backgroundColor = mode.shotBucketsActionCellBackground
        ShotDetailsHeaderView.appearance().backgroundColor = mode.shotDetailsHeaderViewBackground
        ShotDetailsOperationView.appearance().backgroundColor = mode.shotDetailsOperationViewBackground
        ShotDetailsDescriptionCollectionViewCell.appearance().backgroundColor = mode.shotDetailsDescriptionCollectionViewCellBackground
        ShotDetailsCommentCollectionViewCell.appearance().backgroundColor = mode.shotDetailsCommentCollectionViewCellBackground
        ProfileHeaderView.appearance().backgroundColor = mode.profileHeaderViewBackground

        UICollectionView.appearance().backgroundColor = mode.collectionViewBackgroundColor
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        UIWindow.appearance().backgroundColor = mode.windowBackgroundColor
        UITabBar.appearance().backgroundColor = mode.windowBackgroundColor
        UIApplication.shared.keyWindow?.backgroundColor = mode.windowBackgroundColor

        UIDatePicker.appearance().backgroundColor = mode.tableViewBackground
        
        FlashMessageView.defaultStyle = FlashMessageView.Style(backgroundColor: mode.flashMessageBackgroundColor,
                textColor: mode.flashMessageTextColor,
                titleFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                roundedCorners: [.bottomLeft, .bottomRight], roundSize: CGSize(width: 10, height: 10), padding: 25.0)
        ColorModeProvider.resetViews()
    }

    fileprivate class func resetViews() {
        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
    
    fileprivate class func adaptInterfaceToCustomViews(to mode: ColorModeType) {
        guard let centerButtonTabBarController = findCenterButtonTabControllerInWindows() else {
            return
        }
        
        centerButtonTabBarController.adaptColorMode(mode)
    }
    
    fileprivate class func findCenterButtonTabControllerInWindows() -> CenterButtonTabBarController? {
        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            if let centerButtonTabBarController = window.rootViewController as? CenterButtonTabBarController {
                return centerButtonTabBarController
            } else if let loginViewController = window.rootViewController as? LoginViewController {
                return loginViewController.centerButtonTabBarController
            }
        }
        return nil
    }
}
