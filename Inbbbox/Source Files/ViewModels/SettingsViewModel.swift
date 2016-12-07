//
//  SettingsViewModel.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Async
import AOAlertController
import MessageUI

protocol ModelUpdatable: class {
    func didChangeItemsAtIndexPaths(_ indexPaths: [IndexPath])
}

protocol AlertDisplayable: class {
    func displayAlert(_ alert: AOAlertController)
}

protocol FlashMessageDisplayable: class {
    func displayFlashMessage(_ model:FlashMessageViewModel)
}

enum UserMode {
    case loggedUser, demoUser
}

class SettingsViewModel: GroupedListViewModel {

    let title = NSLocalizedString("SettingsViewModel.Account", comment: "Title for account screen")

    weak var settingsViewController: SettingsViewController?

    fileprivate(set) var userMode: UserMode
    fileprivate weak var delegate: ModelUpdatable?
    fileprivate weak var alertDelegate: AlertDisplayable?
    fileprivate weak var flashMessageDelegate: FlashMessageDisplayable?

    fileprivate let createAccountTitle = NSLocalizedString("SettingsViewModel.CreateAccount",
                                                       comment: "Button text allowing user to create new account.")
    fileprivate let reminderTitle = NSLocalizedString("SettingsViewModel.EnableDailyReminders",
                                                  comment: "User settings, enable daily reminders")
    fileprivate let reminderDateTitle = NSLocalizedString("SettingsViewModel.SendDailyReminders",
                                                      comment: "User settings, send daily reminders")
    fileprivate let followingStreamSourceTitle = NSLocalizedString("SettingsViewModel.Following",
                                                               comment: "User settings, enable following")
    fileprivate let newTodayStreamSourceTitle = NSLocalizedString("SettingsViewModel.NewToday",
                                                              comment: "User settings, enable new today.")
    fileprivate let popularTodayStreamSourceTitle = NSLocalizedString("SettingsViewModel.Popular",
                                                                  comment: "User settings, enable popular today.")
    fileprivate let debutsStreamSourceTitle = NSLocalizedString("SettingsViewModel.Debuts",
                                                            comment: "User settings, show debuts.")
    fileprivate let shotAuthorTitle = NSLocalizedString("SettingsViewModel.DisplayAuthor",
                                                    comment: "User Settings, show author.")
    fileprivate let nightModeTitle = NSLocalizedString("SettingsViewModel.NightMode", comment: "User Settings, night mode.")
    fileprivate let autoNightModeTitle = NSLocalizedString("SettingsViewModel.AutoNightMode", comment: "User Settings, auto night mode.")
    fileprivate let sendFeedbackTitle = NSLocalizedString("SettingsViewModel.SendFeedback",
                                                    comment: "User Settings, send settings.")

    fileprivate let createAccountItem: LabelItem
    fileprivate let reminderItem: SwitchItem
    fileprivate let reminderDateItem: DateItem
    fileprivate let followingStreamSourceItem: SwitchItem
    fileprivate let newTodayStreamSourceItem: SwitchItem
    fileprivate let popularTodayStreamSourceItem: SwitchItem
    fileprivate let debutsStreamSourceItem: SwitchItem
    fileprivate let showAuthorItem: SwitchItem
    fileprivate let nightModeItem: SwitchItem
    fileprivate let autoNightModeItem: SwitchItem
    fileprivate let acknowledgementItem: LabelItem
    fileprivate let sendFeedbackItem: LabelItem
    
    var loggedInUser: User? {
        return UserStorage.currentUser
    }

    init(delegate: ModelUpdatable) {

        // MARK: Parameters

        self.delegate = delegate
        alertDelegate = delegate as? AlertDisplayable
        flashMessageDelegate = delegate as? FlashMessageDisplayable
        userMode = UserStorage.isUserSignedIn ? .loggedUser : .demoUser

        // MARK: Create items

        createAccountItem = LabelItem(title: createAccountTitle)

        reminderItem = SwitchItem(title: reminderTitle, enabled: Settings.Reminder.Enabled)
        reminderDateItem = DateItem(title: reminderDateTitle, date: Settings.Reminder.Date)

        followingStreamSourceItem = SwitchItem(title: followingStreamSourceTitle,
                enabled: Settings.StreamSource.Following)
        newTodayStreamSourceItem = SwitchItem(title: newTodayStreamSourceTitle,
                enabled: Settings.StreamSource.NewToday)
        popularTodayStreamSourceItem = SwitchItem(title: popularTodayStreamSourceTitle,
                                                  enabled: Settings.StreamSource.PopularToday)

        debutsStreamSourceItem = SwitchItem(title: debutsStreamSourceTitle, enabled: Settings.StreamSource.Debuts)

        showAuthorItem = SwitchItem(title: shotAuthorTitle, enabled: Settings.Customization.ShowAuthor)
        nightModeItem = SwitchItem(title: nightModeTitle, enabled: Settings.Customization.NightMode)
        autoNightModeItem = SwitchItem(title: autoNightModeTitle, enabled: Settings.Customization.AutoNightMode)
        sendFeedbackItem = LabelItem(title: sendFeedbackTitle)

        let aTitle = NSLocalizedString("SettingsViewModel.AcknowledgementsButton", comment: "Acknowledgements button")
        acknowledgementItem = LabelItem(title: aTitle)
        var items: [[GroupItem]]
        if userMode == .loggedUser {
            items = [[reminderItem, reminderDateItem],
                     [followingStreamSourceItem, newTodayStreamSourceItem,
                      popularTodayStreamSourceItem, debutsStreamSourceItem],
                     [showAuthorItem, nightModeItem, autoNightModeItem],
                     [sendFeedbackItem],
                     [acknowledgementItem]]
        } else {
            items = [[createAccountItem],
                     [reminderItem, reminderDateItem],
                     [newTodayStreamSourceItem, popularTodayStreamSourceItem, debutsStreamSourceItem],
                     [showAuthorItem, nightModeItem, autoNightModeItem],
                     [sendFeedbackItem],
                     [acknowledgementItem]]
        }

        // MARK: Super init

        super.init(items: items as [[GroupItem]])

        configureItemsActions()

        // MARK: add observer
        NotificationCenter.default.addObserver(self,
                selector: #selector(didProvideNotificationSettings),
        name: NSNotification.Name(rawValue: NotificationKey.UserNotificationSettingsRegistered.rawValue), object: nil)
    }
    
    required init(_ items: [T]) {
        fatalError("init has not been implemented")
    }
    
    required init(sections: [Section<T>]) {
        fatalError("init(sections:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    dynamic func didProvideNotificationSettings() {
        Settings.Reminder.LocalNotificationSettingsProvided = true
        registerLocalNotification()
    }

    func updateStatus() {
        reminderItem.enabled = Settings.Reminder.Enabled
        if let date = Settings.Reminder.Date {
            reminderDateItem.date = date
        }
        followingStreamSourceItem.enabled = Settings.StreamSource.Following
        newTodayStreamSourceItem.enabled = Settings.StreamSource.NewToday
        popularTodayStreamSourceItem.enabled = Settings.StreamSource.PopularToday
        debutsStreamSourceItem.enabled = Settings.StreamSource.Debuts
        showAuthorItem.enabled = Settings.Customization.ShowAuthor
    }
}

// MARK: Private extension

private extension SettingsViewModel {

    func configureItemsActions() {
        createAccountItem.onSelect = {
            [weak self] in
            self?.settingsViewController?.authenticateUser()
        }

        acknowledgementItem.onSelect = {
            [weak self] in
            self?.settingsViewController?.presentAcknowledgements()
        }
        
        sendFeedbackItem.onSelect = {
            [weak self] in
            if MFMailComposeViewController.canSendMail() {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self?.settingsViewController
                mailComposer.setToRecipients(["inbbbox@netguru.co"])
                // Localization missing on purpose, so we will sugest user to write in English.
                mailComposer.setSubject("Inbbbox Feedback")
                mailComposer.navigationBar.tintColor = .white
                self?.settingsViewController?.present(mailComposer, animated: true, completion: nil)
            } else {
                self?.settingsViewController?.present(UIAlertController.cantSendFeedback(), animated: true, completion: nil)
            }
        }

        // MARK: onValueChanged blocks

        reminderItem.valueChanged = {
            newValue in
            Settings.Reminder.Enabled = newValue
            if newValue == true {
                self.registerUserNotificationSettings()

                if Settings.Reminder.LocalNotificationSettingsProvided == true {
                    self.registerLocalNotification()
                }
            } else {
                self.unregisterLocalNotification()
            }
            AnalyticsManager.trackSettingChanged(.dailyRemainderEnabled, state: newValue)
        }

        reminderDateItem.onValueChanged = { date -> Void in
            if self.reminderItem.enabled {
                self.registerLocalNotification()
            }
            Settings.Reminder.Date = date
        }

        followingStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.Following = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.followingStreamSource, state: newValue)
        }

        newTodayStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.NewToday = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.newTodayStreamSource, state: newValue)
        }

        popularTodayStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.PopularToday = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.popularTodayStreamSource, state: newValue)
        }

        debutsStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.Debuts = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.debutsStreamSource, state: newValue)
        }

        showAuthorItem.valueChanged = { newValue in
            Settings.Customization.ShowAuthor = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.authorOnHomeScreen, state: newValue)
        }
        
        nightModeItem.valueChanged = { newValue in
            Settings.Customization.NightMode = newValue
            ColorModeProvider.change(to: newValue ? .nightMode : .dayMode)
            AnalyticsManager.trackSettingChanged(.nightMode, state: newValue)
        }
        
        autoNightModeItem.valueChanged = { newValue in
            Settings.Customization.AutoNightMode = newValue
            AnalyticsManager.trackSettingChanged(.autoNightMode, state: newValue)
        }
    }
    
    func checkStreamsSource() {
        if Settings.areAllStreamSourcesOff() {
            let title = NSLocalizedString("SettingsViewModel.AllSources",
                                          comment: "Title of flash message, when user turn off all sources")
            flashMessageDelegate?.displayFlashMessage(FlashMessageViewModel(title: title))
        }
    }

    func registerUserNotificationSettings() {
        UIApplication.shared.registerUserNotificationSettings(
        UIUserNotificationSettings(types: [.alert, .sound], categories: nil))
    }

    func registerLocalNotification() {

        let localNotification = LocalNotificationRegistrator.registerNotification(
        forUserID: loggedInUser?.identifier ?? "userID", time: reminderDateItem.date)

        if localNotification == nil {

            alertDelegate?.displayAlert(preparePermissionsAlert())

            reminderItem.enabled = false
            Settings.Reminder.Enabled = false
            delegate?.didChangeItemsAtIndexPaths(indexPathsForItems([reminderItem])!)
        }
    }

    func unregisterLocalNotification() {
        LocalNotificationRegistrator.unregisterNotification(forUserID: loggedInUser?.identifier ?? "userID")
    }

    // MARK: Prepare alert

    func preparePermissionsAlert() -> AOAlertController {
        let message = NSLocalizedString("SettingsViewModel.AccessToNotifications",
                                        comment: "Body of alert, asking user to grant notifications permission.")
        let alert = AOAlertController(title: nil, message: message, style: .alert)

        let settingsActionTitle = NSLocalizedString("SettingsViewModel.Settings",
                                                    comment: "Redirect user to Settings app")
        let settingsAction = AOAlertAction(title: settingsActionTitle, style: .default) { _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }

        let cancelActionTitle = NSLocalizedString("SettingsViewModel.Dismiss",
                                                  comment: "Notifications alert, dismiss button.")
        let cancelAction = AOAlertAction(title: cancelActionTitle, style: .default, handler: nil)

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        return alert
    }
}
