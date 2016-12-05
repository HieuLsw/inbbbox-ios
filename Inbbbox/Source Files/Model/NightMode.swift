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
        return .blackColor()
    }
    
    var tabBarNormalItemTextColor: UIColor {
        return .whiteColor()
    }
    
    var tabBarSelectedItemTextColor: UIColor {
        return .pinkColor()
    }
    
    var tabBarCenterButtonBackground: UIColor {
        return .blackColor()
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
        return .blackColor()
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
        return .whiteColor()
    }
    
    // MARK: Swich Cell
    var switchCellTintColor: UIColor {
        return .blackColor()
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
    
    var bucketsCollectionViewBackground: UIColor {
        return .darkGrayNightMode()
    }
    
    var emptyBucketImageName: String {
        return "ic-bucket-emptystate-night"
    }

    var shotDetailsHeaderViewBackground: UIColor {
        return .darkGrayNightMode()
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
        return .blackColor()
    }

    // MARK: TwoLayout Collection View Controller
    var twoLayoutsCollectionViewBackground: UIColor {
        return .darkGrayNightMode()
    }
    
    // MARK: Shot Detail
    var shotDetailsHeaderViewTitleLabelTextColor: UIColor {
        return .whiteColor()
    }
    
    var shotDummySpaceBackground: UIColor {
        return .lessDarkGrayNightMode()
    }
    
    var shotDetailsHeaderViewOverlappingTitleLabelTextColor: UIColor {
        return .whiteColor()
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
        return .whiteColor()
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
        return .whiteColor()
    }
    
    var shotDetailsSeparatorColor: UIColor {
        return .darkGrayNightMode()
    }
    
    var shotDetailsEditViewBackground: UIColor {
        return .greenColor()
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
        return .whiteColor()
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
        return .LightContent
    }
    
    // MARK: Comment Composer
    var commentComposerViewBackground: UIColor {
        return .blackColor()
    }
    
    //MARK: Flash Message
    var flashMessageTextColor: UIColor = .blackColor()
    var flashMessageBackgroundColor: UIColor = DayMode().windowBackgroundColor
    
    // MARK: Common
    var shadowColor: UIColor {
        return UIColor(white: 1, alpha: 0.15)
    }
    
    var cellSeparator: UIColor {
        return .blackColor()
    }
    
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        return .White
    }
    
    var visualEffectBlurType: UIBlurEffectStyle {
        return .Dark
    }
    
    func isEqualTo(other: ColorModeType) -> Bool {
        return other is NightMode
    }
}
