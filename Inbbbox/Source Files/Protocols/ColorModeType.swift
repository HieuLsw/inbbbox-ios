//
//  ColorModeType.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 26.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

protocol ColorModeType {
    
    // MARK: Window
    var windowBackgroundColor: UIColor { get }

    // MARK: UITabBar
    var tabBarTint: UIColor { get }
    var tabBarNormalItemTextColor: UIColor { get }
    var tabBarSelectedItemTextColor: UIColor { get }
    var tabBarCenterButtonBackground: UIColor { get }
    var tabBarCenterButtonShadowOffset: CGSize { get }
    var tabBarLikesNormalImageName: String { get }
    var tabBarLikesSelectedImageName: String { get }
    var tabBarBucketsNormalImageName: String { get }
    var tabBarBucketsSelectedImageName: String { get }
    var tabBarCenterButtonNormalImageName: String { get }
    var tabBarCenterButtonSelectedImageName: String { get }
    var tabBarFollowingNormalImageName: String { get }
    var tabBarFollowingSelectedImageName: String { get }
    var tabBarSettingsNormalImageName: String { get }
    var tabBarSettingsSelectedImageName: String { get }

    // MARK: Navigation Bar
    var navigationBarTint: UIColor { get }

    // MARK: Shots Collection
    var shotsCollectionBackground: UIColor { get }
    
    // MARK: Shot Cell
    var shotViewCellBackground: UIColor { get }

    // MARK: Table View
    var tableViewBlurColor: UIColor { get }
    var tableViewBackground: UIColor { get }

    // MARK: Table View Cell
    var tableViewCellBackground: UIColor { get }
    var tableViewCellTextColor: UIColor { get }
    
    // MARK: Swich Cell
    var switchCellTintColor: UIColor { get }

    // MARK: Shot Buckets
    var shotBucketsAddCollectionViewCellBackground: UIColor { get }
    var shotBucketsHeaderViewBackground: UIColor { get }
    var shotBucketsFooterViewBackground: UIColor { get }
    var shotBucketsSeparatorCollectionViewCellBackground: UIColor { get }
    var bucketsCollectionViewBackground: UIColor { get }
    var emptyBucketImageName: String { get }

    // MARK: Shot Details
    var shotDetailsHeaderViewBackground: UIColor { get }
    var shotDetailsAttachmentViewBackground: UIColor { get }
    var shotDummySpaceBackground: UIColor { get }
    var shotDetailsOperationViewBackground: UIColor { get }
    var shotDetailsDescriptionCollectionViewCellBackground: UIColor { get }
    var shotDetailsCommentCollectionViewCellBackground: UIColor { get }
    var shotDetailsHeaderViewTitleLabelTextColor: UIColor { get }
    var shotDetailsHeaderViewOverlappingTitleLabelTextColor: UIColor { get }
    var shotDetailsHeaderViewAuthorNotLinkColor: UIColor { get }
    var shotDetailsHeaderViewAuthorLinkColor: UIColor { get }
    var shotDetailsDescriptionViewColorTextColor: UIColor { get }
    var shotDetailsCommentAuthorTextColor: UIColor { get }
    var shotDetailsCommentContentTextColor: UIColor { get }
    var shotDetailsCommentLikesCountTextColor: UIColor { get }
    var shotDetailsCommentDateTextColor: UIColor { get }
    var shotDetailsCommentLinkTextColor: UIColor { get }
    var shotDetailsCommentEditLabelTextColor: UIColor { get }
    var shotDetailsBucketTextColor: UIColor { get }
    var shotDetailsSeparatorColor: UIColor { get }
    var shotDetailsEditViewBackground: UIColor { get }
    var shotBucketsActionCellBackground: UIColor { get }
    
    // MARK: Settings
    var settingsUsernameTextColor: UIColor { get }
    var settingsSelectedCellBackgound: UIColor { get }
    
    // MARK: Date Picker
    var datePickerBackgroundColor: UIColor { get }
    var datePickerTextColor: UIColor { get }
    
    // MARK: Date Picker View
    var datePickerViewBackgroundColor: UIColor { get }
    var datePickerViewSeparatorColor: UIColor { get }

    /// Profile Header View
    var profileHeaderViewBackground: UIColor { get }

    // MARK: TwoLayout Collection View Controller
    var twoLayoutsCollectionViewBackground: UIColor { get }
    
    // MARK: Logo
    var logoImageName: String { get }
    
    // MARK: StatusBar
    var preferredStatusBarStyle: UIStatusBarStyle { get }
    
    // MARK: Comment Composer
    var commentComposerViewBackground: UIColor { get }
    
    // MARK: Flash Message
    var flashMessageTextColor: UIColor { get }
    var flashMessageBackgroundColor: UIColor { get }
    
    // MARK: Common
    var shadowColor: UIColor { get }
    var cellSeparator: UIColor { get }
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle { get }
    var visualEffectBlurType: UIBlurEffectStyle { get }
    var collectionViewBackgroundColor: UIColor { get }
    
    func isEqualTo(_ other: ColorModeType) -> Bool
}

func ==(lhs: ColorModeType, rhs: ColorModeType) -> Bool {
    return lhs.isEqualTo(rhs)
}
