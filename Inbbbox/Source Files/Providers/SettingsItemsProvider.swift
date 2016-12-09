//
//  SettingsItemsProvider.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 06.12.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

fileprivate struct Titles {
    
    static let createAccountTitle = NSLocalizedString("SettingsViewModel.CreateAccount",
                                                           comment: "Button text allowing user to create new account.")
    static let showMyProfileTitle = NSLocalizedString("SettingsViewModel.ShowMyProfile",
                                                           comment: "Button text allowing user to see his profile.")
    static let reminderTitle = NSLocalizedString("SettingsViewModel.EnableDailyReminders",
                                                      comment: "User settings, enable daily reminders")
    static let reminderDateTitle = NSLocalizedString("SettingsViewModel.SendDailyReminders",
                                                          comment: "User settings, send daily reminders")
    static let followingStreamSourceTitle = NSLocalizedString("SettingsViewModel.Following",
                                                                   comment: "User settings, enable following")
    static let newTodayStreamSourceTitle = NSLocalizedString("SettingsViewModel.NewToday",
                                                                  comment: "User settings, enable new today.")
    static let popularTodayStreamSourceTitle = NSLocalizedString("SettingsViewModel.Popular",
                                                                      comment: "User settings, enable popular today.")
    static let debutsStreamSourceTitle = NSLocalizedString("SettingsViewModel.Debuts",
                                                                comment: "User settings, show debuts.")
    static let shotAuthorTitle = NSLocalizedString("SettingsViewModel.DisplayAuthor",
                                                        comment: "User Settings, show author.")
    static let nightModeTitle = NSLocalizedString("SettingsViewModel.NightMode", comment: "User Settings, night mode.")
    static let autoNightModeTitle = NSLocalizedString("SettingsViewModel.AutoNightMode", comment: "User Settings, auto night mode.")
    static let sendFeedbackTitle = NSLocalizedString("SettingsViewModel.SendFeedback",
                                                          comment: "User Settings, send settings.")
    static let acknowledgementsTitle = NSLocalizedString("SettingsViewModel.AcknowledgementsButton", comment: "Acknowledgements button")
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
    
    let nightModeItem = SwitchItem(title: Titles.nightModeTitle, enabled: Settings.Customization.NightMode)
    
    let autoNightModeItem = SwitchItem(title: Titles.autoNightModeTitle,
                                       enabled: Settings.Customization.AutoNightMode)
    
    let acknowledgementItem = LabelItem(title: Titles.acknowledgementsTitle)
    
    let sendFeedbackItem = LabelItem(title: Titles.sendFeedbackTitle)

}
