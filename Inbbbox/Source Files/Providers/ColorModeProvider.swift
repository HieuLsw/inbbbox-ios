//
//  ColorModeProvider.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 26.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

enum ColorMode: String {
    case DayMode
    case NightMode
}

final class ColorModeProvider {

    // MARK: Internal

    class func setup() {
        let currentMode = Settings.Customization.CurrentColorMode
        select(currentMode)
    }

    class func change(to mode: ColorMode) {
        Settings.Customization.CurrentColorMode = mode
        ColorModeProvider.setup()
    }

    class func current() -> ColorModeType {
        let currentMode = Settings.Customization.CurrentColorMode
        switch currentMode {
        case .DayMode: return DayMode()
        case .NightMode: return NightMode()
        }
    }

    // MARK: Private

    private class func select(mode: ColorMode) {
        switch mode {
            case .DayMode:
                let mode = DayMode()
                ColorModeProvider.adaptInterface(to: mode)
                ColorModeProvider.adaptInterfaceToCustomViews(to: mode)
            case .NightMode:
                let mode = NightMode()
                ColorModeProvider.adaptInterface(to: mode)
                ColorModeProvider.adaptInterfaceToCustomViews(to: mode)
        }
    }

    private class func adaptInterface(to mode: ColorModeType) {
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

        UICollectionView.appearanceWhenContainedInInstancesOfClasses([TwoLayoutsCollectionViewController.self]).backgroundColor = mode.twoLayoutsCollectionViewBackground
        UICollectionView.appearanceWhenContainedInInstancesOfClasses([BucketsCollectionViewController.self]).backgroundColor = mode.bucketsCollectionViewBackground

        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().translucent = false
        UIWindow.appearance().backgroundColor = mode.windowBackgroundColor
        UITabBar.appearance().backgroundColor = mode.windowBackgroundColor
        UIApplication.sharedApplication().keyWindow?.backgroundColor = mode.windowBackgroundColor

        UIDatePicker.appearance().backgroundColor = mode.tableViewBackground
        
        FlashMessageView.defaultStyle = FlashMessageView.Style(backgroundColor: mode.flashMessageBackgroundColor,
                textColor: mode.flashMessageTextColor,
                titleFont: UIFont.helveticaFont(.Neue, size:14),
                roundedCorners: [.BottomLeft, .BottomRight], roundSize: CGSizeMake(10, 10), padding: 25.0)
        ColorModeProvider.resetViews()
    }

    private class func resetViews() {
        let windows = UIApplication.sharedApplication().windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
    
    private class func adaptInterfaceToCustomViews(to mode: ColorModeType) {
        guard let centerButtonTabBarController = findCenterButtonTabControllerInWindows() else {
            return
        }
        
        centerButtonTabBarController.adaptColorMode(mode)
    }
    
    private class func findCenterButtonTabControllerInWindows() -> CenterButtonTabBarController? {
        let windows = UIApplication.sharedApplication().windows as [UIWindow]
        for window in windows {
            guard let centerButtonTabBarController = window.rootViewController as? CenterButtonTabBarController  else {
                continue
            }
            return centerButtonTabBarController
        }
        return nil
    }
}
