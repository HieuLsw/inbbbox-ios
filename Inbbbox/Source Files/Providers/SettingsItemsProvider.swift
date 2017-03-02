//
//  SettingsItemsProvider.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 06.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

fileprivate struct Titles {

    static var createAccountTitle: String {
        return Localized("SettingsViewModel.CreateAccount", comment: "Button text allowing user to create new account.")
    }

    static var showMyProfileTitle: String {
        return Localized("SettingsViewModel.ShowMyProfile", comment: "Button text allowing user to see his profile.")
    }

    static var reminderTitle: String {
        return Localized("SettingsViewModel.EnableDailyReminders", comment: "User settings, enable daily reminders")
    }

    static var reminderDateTitle: String {
        return Localized("SettingsViewModel.SendDailyReminders", comment: "User settings, send daily reminders")
    }

    static var followingStreamSourceTitle: String {
        return Localized("SettingsViewModel.Following", comment: "User settings, enable following")
    }

    static var newTodayStreamSourceTitle: String {
        return Localized("SettingsViewModel.NewToday", comment: "User settings, enable new today.")
    }

    static var popularTodayStreamSourceTitle: String {
        return Localized("SettingsViewModel.Popular", comment: "User settings, enable popular today.")
    }

    static var debutsStreamSourceTitle: String {
        return Localized("SettingsViewModel.Debuts", comment: "User settings, show debuts.")
    }

    static var shotAuthorTitle: String {
        return Localized("SettingsViewModel.DisplayAuthor", comment: "User Settings, show author.")
    }

    static var changeLanguageTitle: String {
        return Localized("SettingsViewModel.Language", comment: "User Settings, language.")
    }

    static var nightModeTitle: String {
        return Localized("SettingsViewModel.NightMode", comment: "User Settings, night mode.")
    }

    static var autoNightModeTitle: String {
        return Localized("SettingsViewModel.AutoNightMode", comment: "User Settings, auto night mode.")
    }

    static var sendFeedbackTitle: String {
        return Localized("SettingsViewModel.SendFeedback", comment: "User Settings, send settings.")
    }

    static var acknowledgementsTitle: String {
        return Localized("SettingsViewModel.AcknowledgementsButton", comment: "Acknowledgements button")
    }
}

struct SettingsItemsProvider {
    
    let createAccountItem = LabelItem(title: Titles.createAccountTitle)
    
    let showMyProfileItem = LabelItem(title: Titles.showMyProfileTitle)
    
    let reminderItem = SwitchItem(title: Titles.reminderTitle, enabled: Settings.Reminder.Enabled)
    
    let reminderDateItem = DateItem(title: Titles.reminderDateTitle, date: Settings.Reminder.Date)
    
    let followingStreamSourceItem = SwitchItem(title: Titles.followingStreamSourceTitle,
                                               enabled: Settings.StreamSource.Following)
    
    let newTodayStreamSourceItem = SwitchItem(title: Titles.newTodayStreamSourceTitle,
                                              enabled: Settings.StreamSource.NewToday)
    
    let popularTodayStreamSourceItem = SwitchItem(title: Titles.popularTodayStreamSourceTitle,
                                                  enabled: Settings.StreamSource.PopularToday)
    
    let debutsStreamSourceItem = SwitchItem(title: Titles.debutsStreamSourceTitle,
                                            enabled: Settings.StreamSource.Debuts)
    
    let showAuthorItem = SwitchItem(title: Titles.shotAuthorTitle,
                                    enabled: Settings.Customization.ShowAuthor)

    let changeLanguageItem = DetailsItem(title: Titles.changeLanguageTitle, detailString: Settings.Customization.AppLanguage.localizedName)
    
    let nightModeItem = SwitchItem(title: Titles.nightModeTitle, enabled: Settings.Customization.NightMode)
    
    let autoNightModeItem = SwitchItem(title: Titles.autoNightModeTitle,
                                       enabled: Settings.Customization.AutoNightMode)

    let blockedUsersItem = DetailsItem(title: "Blocked users", detailString: "") // NGRTodo: fix before CR
    
    let acknowledgementItem = LabelItem(title: Titles.acknowledgementsTitle)
    
    let sendFeedbackItem = LabelItem(title: Titles.sendFeedbackTitle)

}
