//
//  NightMode.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 26.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct NightMode: ColorModeType {
    
    // MARK: Window
    var windowBackgroundColor: UIColor {
        return .backgroundNightModeGrayColor()
    }

    // MARK: Tab Bar
    var tabBarTint: UIColor {
        return .black
    }
    
    var tabBarNormalItemTextColor: UIColor {
        return .white
    }
    
    var tabBarSelectedItemTextColor: UIColor {
        return .pinkColor()
    }
    
    var tabBarCenterButtonBackground: UIColor {
        return .black
    }
    
    var tabBarCenterButtonShadowOffset: CGSize {
        return CGSize(width: 0, height: 2)
    }
    
    var tabBarLikesNormalImageName: String {
        return "ic-likes-night"
    }
    
    var tabBarLikesSelectedImageName: String {
        return "ic-likes-active"
    }
    
    var tabBarBucketsNormalImageName: String {
        return "ic-buckets-night"
    }
    
    var tabBarBucketsSelectedImageName: String {
        return "ic-buckets-active"
    }
    
    var tabBarCenterButtonNormalImageName: String {
        return "ic-ball-inactive-night"
    }
    
    var tabBarCenterButtonSelectedImageName: String {
        return "ic-ball-active-night"
    }
    
    var tabBarFollowingNormalImageName: String {
        return "ic-following-night"
    }
    
    var tabBarFollowingSelectedImageName: String {
        return "ic-following-active"
    }
    
    var tabBarSettingsNormalImageName: String {
        return "ic-settings-night"
    }
    
    var tabBarSettingsSelectedImageName: String { 
        return "ic-settings-active"
    }

    // MARK: Navigation Bar
    var navigationBarTint: UIColor {
        return .black
    }

    // MARK: Shots Collection
    var shotsCollectionBackground: UIColor {
        return .darkGrayNightMode()
    }
    
    // MARK: Shot Cell
    var shotViewCellBackground: UIColor {
        return .grayNightMode()
    }
    
    // MARK: Table View
    var tableViewBlurColor: UIColor {
        return .RGBA(71, 72, 72, 1)
    }

    var tableViewBackground: UIColor {
        return .darkGrayNightMode()
    }

    // MARK: Table View Cell
    var tableViewCellBackground: UIColor {
        return .lessDarkGrayNightMode()
    }
    
    var tableViewCellTextColor: UIColor {
        return .white
    }
    
    // MARK: Swich Cell
    var switchCellTintColor: UIColor {
        return .black
    }

    var shotBucketsAddCollectionViewCellBackground: UIColor {
        return .lessDarkGrayNightMode()
    }

    var shotBucketsHeaderViewBackground: UIColor {
        return .darkGrayNightMode()
    }

    var shotBucketsFooterViewBackground: UIColor {
        return .lessDarkGrayNightMode()
    }

    var shotBucketsSeparatorCollectionViewCellBackground: UIColor {
        return .darkGrayNightMode()
    }
    
    var emptyBucketImageName: String {
        return "ic-bucket-emptystate-night"
    }

    var shotDetailsHeaderViewBackground: UIColor {
        return .darkGrayNightMode()
    }
    
    var shotDetailsAttachmentViewBackground: UIColor {
        return .RGBA(51, 51, 51, 1)
    }

    var shotDetailsOperationViewBackground: UIColor {
        return .darkGrayNightMode()
    }

    var shotDetailsDescriptionCollectionViewCellBackground: UIColor {
        return .lessDarkGrayNightMode()
    }

    var shotDetailsCommentCollectionViewCellBackground: UIColor {
        return .lessDarkGrayNightMode()
    }

    var profileHeaderViewBackground: UIColor {
        return .black
    }

    // MARK: Profile Menu Bar
    var menuBackground: UIColor {
        return .RGBA(19, 19, 19, 1)
    }

    var activeMenuButtonTitle: UIColor {
        return .white
    }

    var activeMenuButtonBadge: UIColor {
        return .pinkColor()
    }

    var inactiveMenuButtonTitle: UIColor {
        return .RGBA(148, 147, 153, 1)
    }

    var inactiveMenuButtonBadge: UIColor {
        return .RGBA(148, 147, 153, 1)
    }

    // MARK: TwoLayout Collection View Controller
    var twoLayoutsCollectionViewBackground: UIColor {
        return .darkGrayNightMode()
    }

    var bucketsCollectionViewBackground: UIColor {
        return .darkGrayNightMode()
    }

    // MARK: Shot Detail
    var shotDetailsHeaderViewTitleLabelTextColor: UIColor {
        return .white
    }
    
    var shotDummySpaceBackground: UIColor {
        return .lessDarkGrayNightMode()
    }
    
    var shotDetailsHeaderViewOverlappingTitleLabelTextColor: UIColor {
        return .white
    }
    
    var shotDetailsHeaderViewAuthorNotLinkColor: UIColor {
        return  .lessWhiteNightMode()
    }
    
    var shotDetailsHeaderViewAuthorLinkColor: UIColor {
        return .pinkColor()
    }

    var shotDetailsDescriptionViewColorTextColor: UIColor {
        return  .lessWhiteNightMode()
    }
    
    var shotDetailsCommentAuthorTextColor: UIColor {
        return .white
    }
    
    var shotDetailsCommentContentTextColor: UIColor {
        return  .lessWhiteNightMode()
    }
    
    var shotDetailsCommentLikesCountTextColor: UIColor {
        return .followeeTextGrayNightModeColor()
    }
    
    var shotDetailsCommentDateTextColor: UIColor {
        return .followeeTextGrayNightModeColor()
    }
    
    var shotDetailsCommentLinkTextColor: UIColor {
        return .pinkColor()
    }
    
    var shotDetailsCommentEditLabelTextColor: UIColor {
        return .followeeTextGrayNightModeColor()
    }
    
    var shotDetailsBucketTextColor: UIColor {
        return .white
    }
    
    var shotDetailsSeparatorColor: UIColor {
        return .darkGrayNightMode()
    }
    
    var shotDetailsEditViewBackground: UIColor {
        return .green
    }
    
    var shotBucketsActionCellBackground: UIColor {
        return .lessDarkGrayNightMode()
    }
    
    // MARK: Settings
    var settingsUsernameTextColor: UIColor {
        return  .whiteNightMode()
    }
    
    var settingsSelectedCellBackgound: UIColor {
        return .grayNightMode()
    }
    
    // MARK: Date Picker
    var datePickerBackgroundColor: UIColor {
        return .darkGrayNightMode()
    }
    
    var datePickerTextColor: UIColor {
        return .white
    }
    
    // MARK: Date Picker View
    var datePickerViewBackgroundColor: UIColor {
        return .darkGrayNightMode()
    }
    
    var datePickerViewSeparatorColor: UIColor {
        return .darkGrayNightMode()
    }
    
    // MARK: Logo
    var logoImageName: String {
        return "logo-type-home-night"
    }
    
    // MARK: Status Bar
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Comment Composer
    var commentComposerViewBackground: UIColor {
        return .black
    }
    
    //MARK: Flash Message
    var flashMessageTextColor: UIColor = .black
    var flashMessageBackgroundColor: UIColor = DayMode().windowBackgroundColor
    
    // MARK: Common
    var shadowColor: UIColor {
        return UIColor(white: 1, alpha: 0.15)
    }
    
    var cellSeparator: UIColor {
        return .black
    }
    
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        return .white
    }
    
    var visualEffectBlurType: UIBlurEffectStyle {
        return .dark
    }

    var collectionViewBackgroundColor: UIColor {
        return .darkGrayNightMode()
    }
    
    func isEqualTo(_ other: ColorModeType) -> Bool {
        return other is NightMode
    }
}
