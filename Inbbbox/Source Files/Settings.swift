//
//  Settings.swift
//  Inbbbox
//
//  Created by Peter Bruz on 04/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

/// Provides interface for application settings kept in user defaults.
class Settings {

    /// Manages settings related to streams' sources.
    struct StreamSource {

        /// Indicates if streams' sources are initially set.
        static var IsSet: Bool {
            get { return Settings.boolForKey(.streamSourceIsSet) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .streamSourceIsSet) }
        }

        /// Indicates if stream's source for Following is on.
        static var Following: Bool {
            get { return Settings.boolForKey(.followingStreamSourceOn) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .followingStreamSourceOn) }
        }

        /// Indicates if stream's source for NewToday is on.
        static var NewToday: Bool {
            get { return Settings.boolForKey(.newTodayStreamSourceOn) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .newTodayStreamSourceOn) }
        }

        /// Indicates if stream's source for PopularToday is on.
        static var PopularToday: Bool {
            get { return Settings.boolForKey(.popularTodayStreamSourceOn) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .popularTodayStreamSourceOn) }
        }

        /// Indicates if stream's source for Debuts is on.
        static var Debuts: Bool {
            get { return Settings.boolForKey(.debutsStreamSourceOn) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .debutsStreamSourceOn) }
        }
        
        /// Indicates if stream's source My set is on.
        static var MySet: Bool {
            get { return Defaults[StreamSourceKey.mySetStreamSourceOn.rawValue].bool ?? true }
            set { Settings.setValue(newValue as AnyObject?, forKey: .mySetStreamSourceOn) }
        }
        
        /// Indicates which one stream source is selected
        static var SelectedStreamSource: StreamSourceKey? {
            get { return Settings.streamForKey(.selectedStreamSource) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .selectedStreamSource) }
        }
        
    }

    /// Manages settings related to reminder.
    struct Reminder {

        /// Indicates if reminder is enabled.
        static var Enabled: Bool {
            get { return Settings.boolForKey(.ReminderOn) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .ReminderOn) }
        }

        /// Indicates date that reminder should appear.
        static var Date: Date? {
            get { return Settings.dateForKey(.ReminderDate) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .ReminderDate) }
        }

        /// Indicates if settings for local notifications are provided.
        static var LocalNotificationSettingsProvided: Bool {
            get { return Settings.boolForKey(.LocalNotificationSettingsProvided) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .LocalNotificationSettingsProvided) }
        }
    }

    /// Manages settings related to customization.
    struct Customization {

        /// Indicates if "showing author on homescreen" is enabled.
        static var ShowAuthor: Bool {
            get { return Settings.boolForKey(.showAuthorOnHomeScreen) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .showAuthorOnHomeScreen) }
        }
        
        /// Indicates if "showing author on homescreen" is enabled.
        static var NightMode: Bool {
            get { return Settings.boolForKey(.nightMode) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .nightMode) }
        }
        
        /// Indicates if "showing author on homescreen" is enabled.
        static var AutoNightMode: Bool {
            get { return Settings.boolForKey(.autoNightMode) }
            set { Settings.setValue(newValue as AnyObject?, forKey: .autoNightMode) }
        }

        /// Indicates what color mode is currently set.
        /// - SeeAlso: `ColorMode`
        static var CurrentColorMode: ColorMode {
            get {
                let savedSetting = Settings.stringForKey(.colorMode)
                let colorMode = ColorMode(rawValue: savedSetting)
                return colorMode != nil ? colorMode! : .dayMode
            }
            set { Settings.setValue(newValue.rawValue as AnyObject?, forKey: .colorMode) }
        }
    }
}

private extension Settings {

    // MARK: NotificationKey

    static func boolForKey(_ key: NotificationKey) -> Bool {
        return boolForKey(key.rawValue)
    }

    static func dateForKey(_ key: NotificationKey) -> Date? {
        return Defaults[key.rawValue].date
    }

    static func setValue(_ value: AnyObject?, forKey key: NotificationKey) {
        Defaults[key.rawValue] = value
        NotificationCenter.default.post(
        name: Notification.Name(rawValue: InbbboxNotificationKey.UserDidChangeNotificationsSettings.rawValue), object: self)
    }

    // MARK: StreamSourceKey

    static func boolForKey(_ key: StreamSourceKey) -> Bool {
        return boolForKey(key.rawValue)
    }

    static func setValue(_ value: AnyObject?, forKey key: StreamSourceKey) {
        Defaults[key.rawValue] = value
        NotificationCenter.default.post(
        name: Notification.Name(rawValue: InbbboxNotificationKey.UserDidChangeStreamSourceSettings.rawValue), object: self)
    }

    // MARK: CusotmizationKey

    static func boolForKey(_ key: CustomizationKey) -> Bool {
        return boolForKey(key.rawValue)
    }

    static func stringForKey(_ key: CustomizationKey) -> String {
        return stringForKey(key.rawValue)
    }

    static func streamForKey(_ key: CustomizationKey) -> StreamSourceKey? {
        return streamForKey(key.rawValue)
    }
    
    static func setValue(_ value: AnyObject?, forKey key: CustomizationKey) {
        Defaults[key.rawValue] = value
    }

    // MARK: General

    static func boolForKey(_ key: String) -> Bool {
        return Defaults[key].bool ?? false
    }

    static func stringForKey(_ key: String) -> String {
        return Defaults[key].string ?? ""
    }
    
    static func streamForKey(_ key: String) -> StreamSourceKey? {
        return Defaults[key].object as! StreamSourceKey?
    }
}

extension Settings {
    
    /**
     Returns information if all stream sources are turned off in Settings
     */
    static func areAllStreamSourcesOff() -> Bool {
        return (!Settings.StreamSource.Following &&
            !Settings.StreamSource.NewToday &&
            !Settings.StreamSource.PopularToday &&
            !Settings.StreamSource.Debuts)
    }
}
