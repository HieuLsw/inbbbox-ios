//
//  DayMode.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 26.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct DayMode: ColorModeType {
    
    // MARK: Window
    var windowBackgroundColor: UIColor {
        return .RGBA(246, 248, 248, 1)
    }

    // MARK: Tab Bar
    var tabBarTint: UIColor {
        return .white
    }
    
    var tabBarNormalItemTextColor: UIColor {
        return .tabBarGrayColor()
    }
    
    var tabBarSelectedItemTextColor: UIColor {
        return .pinkColor()
    }
    
    var tabBarCenterButtonBackground: UIColor {
        return .white
    }
    
    var tabBarCenterButtonShadowOffset: CGSize {
        return CGSize(width: 0, height: 2)
    }
    
    var tabBarLikesNormalImageName: String {
        return "ic-likes"
    }
    
    var tabBarLikesSelectedImageName: String {
        return "ic-likes-active"
    }
    
    var tabBarBucketsNormalImageName: String {
        return "ic-buckets"
    }
    
    var tabBarBucketsSelectedImageName: String {
        return "ic-buckets-active"
    }
    
    var tabBarCenterButtonNormalImageName: String {
        return "ic-ball-inactive"
    }
    
    var tabBarCenterButtonSelectedImageName: String {
        return "ic-ball-active"
    }
    
    var tabBarFollowingNormalImageName: String {
        return "ic-following"
    }
    
    var tabBarFollowingSelectedImageName: String {
        return "ic-following-active"
    }
    
    var tabBarSettingsNormalImageName: String {
        return "ic-settings"
    }
    
    var tabBarSettingsSelectedImageName: String { 
        return "ic-settings-active"
    }

    // MARK: Navigation Bar
    var navigationBarTint: UIColor {
        return .pinkColor()
    }

    // MARK: Shots Collection
    var shotsCollectionBackground: UIColor {
        return .backgroundGrayColor()
    }
    
    // MARK: Shot Cell
    var shotViewCellBackground: UIColor {
        return .cellBackgroundColor()
    }
    
    // MARK: Table View
    var tableViewBlurColor: UIColor {
        return .clear
    }

    var tableViewBackground: UIColor {
        return .backgroundGrayColor()
    }

    // MARK: Table View Cell
    var tableViewCellBackground: UIColor {
        return .white
    }
    
    var tableViewCellTextColor: UIColor {
        return .black
    }
    
    // MARK: Switch Cell
    var switchCellTintColor: UIColor {
        return .RGBA(143, 142, 148, 1)
    }

    var shotBucketsAddCollectionViewCellBackground: UIColor {
        return .white
    }

    var shotBucketsHeaderViewBackground: UIColor {
        return .RGBA(246, 248, 248, 1)
    }

    var shotBucketsFooterViewBackground: UIColor {
        return .white
    }

    var shotBucketsSeparatorCollectionViewCellBackground: UIColor {
        return UIColor.RGBA(246, 248, 248, 1)
    }
    
    var bucketsCollectionViewBackground: UIColor {
        return .backgroundGrayColor()
    }
    
    var emptyBucketImageName: String {
        return "ic-bucket-emptystate-night"
    }

    var shotDetailsHeaderViewBackground: UIColor {
        return .RGBA(246, 248, 248, 1)
    }
    
    var shotDetailsAttachmentViewBackground: UIColor {
        return .RGBA(43, 49, 51, 1)
    }

    var shotDetailsOperationViewBackground: UIColor {
        return .RGBA(246, 248, 248, 1)
    }

    var shotDetailsDescriptionCollectionViewCellBackground: UIColor {
        return .white
    }

    var shotDetailsCommentCollectionViewCellBackground: UIColor {
        return .white
    }

    var profileHeaderViewBackground: UIColor {
        return .pinkColor()
    }

    // MARK: Profile Menu Bar
    var menuBackground: UIColor {
        return .white
    }

    var activeMenuButtonTitle: UIColor {
        return .RGBA(26, 26, 26, 1)
    }

    var activeMenuButtonBadge: UIColor {
        return .RGBA(26, 26, 26, 1)
    }

    var inactiveMenuButtonTitle: UIColor {
        return .RGBA(148, 147, 153, 1)
    }

    var inactiveMenuButtonBadge: UIColor {
        return .RGBA(148, 147, 153, 1)
    }

    // MARK: TwoLayout Collection View Controller
    var twoLayoutsCollectionViewBackground: UIColor {
        return .backgroundGrayColor()
    }
    
    // MARK: Shot Detail
    var shotDetailsHeaderViewTitleLabelTextColor: UIColor {
        return .black
    }
    
    var shotDummySpaceBackground: UIColor {
        return .white
    }
    
    var shotDetailsHeaderViewOverlappingTitleLabelTextColor: UIColor {
        return .white
    }
    
    var shotDetailsHeaderViewAuthorNotLinkColor: UIColor {
        return .gray
    }
    
    var shotDetailsHeaderViewAuthorLinkColor: UIColor {
        return .pinkColor()
    }
    
    var shotDetailsCommentContentTextColor: UIColor {
        return .gray
    }
    
    var shotDetailsDescriptionViewColorTextColor: UIColor {
        return .gray
    }
    
    var shotDetailsCommentAuthorTextColor: UIColor {
        return .textDarkColor()
    }
    
    var shotDetailsCommentLikesCountTextColor: UIColor {
        return .followeeTextGrayColor()
    }
    
    var shotDetailsCommentDateTextColor: UIColor {
        return .followeeTextGrayColor()
    }
    
    var shotDetailsCommentLinkTextColor: UIColor {
        return .pinkColor()
    }
    
    var shotDetailsCommentEditLabelTextColor: UIColor {
        return .followeeTextGrayColor()
    }
    
    var shotDetailsBucketTextColor: UIColor {
        return .RGBA(87, 98, 103, 1)
    }
    
    var shotDetailsSeparatorColor: UIColor {
        return .separatorGrayColor()
    }
    
    var shotDetailsEditViewBackground: UIColor {
        return .clear
    }
    
    var shotBucketsActionCellBackground: UIColor {
        return .white
    }

    // MARK: Profile Details

    var profileDetailsCollectionTitleLabelTextColor: UIColor {
        return .textDarkGrayColor()
    }

    var profileDetailsCollectionBackgroundLabelTextColor: UIColor {
        return .RGBA(223, 224, 226, 0.5)
    }

    var profileDetailsCollectionCounterLabelTextColor: UIColor {
        return .pinkColor()
    }

    // MARK: Settings
    var settingsUsernameTextColor: UIColor {
        return .textDarkColor()
    }
    
    var settingsSelectedCellBackgound: UIColor {
        return .RGBA(217, 217, 217, 1)
    }
    
    // MARK: Date Picker
    var datePickerBackgroundColor: UIColor {
        return .white
    }
    
    var datePickerTextColor: UIColor {
        return .black
    }
    
    // MARK: Date Picker View
    var datePickerViewBackgroundColor: UIColor {
        return .backgroundGrayColor()
    }
    
    var datePickerViewSeparatorColor: UIColor {
        return .RGBA(224, 224, 224, 1)
    }
    
    // MARK: Logo
    var logoImageName: String {
        return "logo-type-home"
    }

    // MARK: Status Bar
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    // MARK: Comment Composer
    var commentComposerViewBackground: UIColor {
        return .RGBA(246, 248, 248, 1)
    }
    
    //MARK: Flash Message
    var flashMessageTextColor: UIColor = .white
    var flashMessageBackgroundColor: UIColor = UIColor.flashMessageBackgroundColor()
    
    // MARK: Common
    var shadowColor: UIColor {
        return UIColor(white: 0, alpha: 0.1)
    }
    
    var cellSeparator: UIColor {
        return .RGBA(200, 199, 204, 1)
    }
    
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        return .gray
    }
    
    var visualEffectBlurType: UIBlurEffectStyle {
        return .light
    }

    var collectionViewBackgroundColor: UIColor {
        return .backgroundGrayColor()
    }
    
    func isEqualTo(_ other: ColorModeType) -> Bool {
        return other is DayMode
    }
}
