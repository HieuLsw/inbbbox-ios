//
//  Defines.swift
//  Inbbbox
//
//  Created by Peter Bruz on 04/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

/// Keys related to reminders and notifications.
enum NotificationKey: String {
    case ReminderOn = "ReminderOn"
    case ReminderDate = "ReminderDate"
    case UserNotificationSettingsRegistered = "UserNotificationSettingsRegistered"
    case LocalNotificationSettingsProvided = "LocalNotificationSettingsProvided"
}

/// Keys related to streams sources.
enum StreamSourceKey: String {
    case StreamSourceIsSet = "StreamSourceIsSet"
    case FollowingStreamSourceOn = "FollowingStreamSourceOn"
    case NewTodayStreamSourceOn = "NewTodayStreamSourceOn"
    case PopularTodayStreamSourceOn = "PopularTodayStreamSourceOn"
    case DebutsStreamSourceOn = "DebutsStreamSourceOn"
}

/// Keys related to customization settings.
enum CustomizationKey: String {
    case ShowAuthorOnHomeScreen = "ShowAuthorOnHomeScreen"
    case NightMode = "NightModeStatus"
    case AutoNightMode = "AutoNightMode"
    case ColorMode = "CurrentColorMode"
}

extension DefaultsKeys {
    static let onboardingPassed = DefaultsKey<Bool>("onboardingPassed")
}

/// Keys for NSNotifications about changing settings.
enum InbbboxNotificationKey: String {
    case UserDidChangeStreamSourceSettings
    case UserDidChangeNotificationsSettings
}
