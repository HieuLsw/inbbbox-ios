//
//  AnalyticsManager.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 10.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Defines which views can be tracked.
enum AnalyticsScreen: String {
    case loginView, followeesView, shotsView, settingsView,
            bucketsView, likesView, shotDetailsView, shotBucketsView
}

/// Defines which login events can be tracked.
enum AnalyticsLoginEvent: String {
    case loginSucceeded, loginFailed, loginAsGuest
}

/// Defines which user actions can be tracked.
enum AnalyticsUserActionEvent: String {
    case like, addToBucket, comment, swipeDown, follow
}

/// Defines which settings change can be tracked.
enum SettingsValueChangedEvent: String {
    case dailyRemainderEnabled, followingStreamSource,
            newTodayStreamSource, popularTodayStreamSource, debutsStreamSource,
            authorOnHomeScreen, nightMode, autoNightMode
}

class AnalyticsManager {

    /// Setup analytics using Tracking ID.
    class func setupAnalytics() {
        guard let trackingId = Dribbble.GATrackingId else {
            return
        }
        GAI.sharedInstance().tracker(withTrackingId: trackingId)
    }

    /// Method to track specific screen.
    ///
    /// - parameter screen: Screen to track.
    class func trackScreen(_ screen: AnalyticsScreen) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        tracker.set(kGAIScreenName, value: screen.rawValue)

        if let screenView = GAIDictionaryBuilder.createScreenView().build() as NSDictionary as? [AnyHashable: Any] {
            tracker.send(screenView)
        }
    }

    /// Method to track login event.
    ///
    /// - parameter loginEvent: Login event to track.
    class func trackLoginEvent(_ loginEvent: AnalyticsLoginEvent) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        if let event = GAIDictionaryBuilder.createEvent(withCategory: "Login",
                        action: loginEvent.rawValue, label: nil, value: nil).build() as NSDictionary as? [AnyHashable: Any] {
            
            tracker.send(event)
        }
    }

    /// Method to track user action event.
    ///
    /// - parameter userActionEvent: action to track.
    class func trackUserActionEvent(_ userActionEvent: AnalyticsUserActionEvent) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        if let event = GAIDictionaryBuilder.createEvent(withCategory: "UserAction",
                action: userActionEvent.rawValue, label: nil, value: nil).build() as NSDictionary as? [AnyHashable: Any] {
            
            tracker.send(event)
        }
    }

    /// Method to track settings change events.
    ///
    /// - parameter changedSetting: setting change to track.
    class func trackSettingChanged(_ changedSetting: SettingsValueChangedEvent, state: Bool) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        if let event = GAIDictionaryBuilder.createEvent(withCategory: "SettingsChange",
                        action: changedSetting.rawValue, label: state ? "on" : "off", value: nil).build() as NSDictionary as? [AnyHashable: Any] {
            
            tracker.send(event)
        }
    }
    
    /// Method to track Dribbble API Rate Limit (X-RateLimit-Remaining).
    ///
    /// - parameter requests: The number of requests remaining in the current rate limit window (per minute).
    class func trackRemaining(_ requests: UInt) {
        guard let tracker = GAI.sharedInstance().defaultTracker else {
            return
        }
        if let event = GAIDictionaryBuilder.createEvent(withCategory: "API",
                action: "X-RateLimit-Remaining", label: nil, value: requests as NSNumber!).build() as NSDictionary as? [AnyHashable: Any] {
            
            tracker.send(event)
        }
    }
}
