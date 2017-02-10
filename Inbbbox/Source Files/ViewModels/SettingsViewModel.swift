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
    func displayFlashMessage(_ model: FlashMessageViewModel)
}

enum UserMode {
    case loggedUser, demoUser
}

class SettingsViewModel: GroupedListViewModel {

    let title = Localized("SettingsViewModel.Account", comment: "Title for account screen")

    weak var settingsViewController: SettingsViewController?

    fileprivate(set) var userMode: UserMode
    fileprivate weak var delegate: ModelUpdatable?
    fileprivate weak var alertDelegate: AlertDisplayable?
    fileprivate weak var flashMessageDelegate: FlashMessageDisplayable?
    
    fileprivate let allItems = SettingsItemsProvider()
    
    var loggedInUser: User? {
        return UserStorage.currentUser
    }

    init(delegate: ModelUpdatable) {

        // MARK: Parameters

        self.delegate = delegate
        alertDelegate = delegate as? AlertDisplayable
        flashMessageDelegate = delegate as? FlashMessageDisplayable
        userMode = UserStorage.isUserSignedIn ? .loggedUser : .demoUser

        var items: [[GroupItem]]
        if userMode == .loggedUser {
            items = [[allItems.showMyProfileItem],
                     [allItems.reminderItem, allItems.reminderDateItem],
                     [allItems.followingStreamSourceItem, allItems.newTodayStreamSourceItem,
                      allItems.popularTodayStreamSourceItem, allItems.debutsStreamSourceItem],
                     [allItems.showAuthorItem, allItems.changeLanguageItem, allItems.nightModeItem, allItems.autoNightModeItem],
                     [allItems.sendFeedbackItem],
                     [allItems.acknowledgementItem]]
        } else {
            items = [[allItems.createAccountItem],
                     [allItems.reminderItem, allItems.reminderDateItem],
                     [allItems.newTodayStreamSourceItem, allItems.popularTodayStreamSourceItem, allItems.debutsStreamSourceItem],
                     [allItems.showAuthorItem, allItems.changeLanguageItem, allItems.nightModeItem, allItems.autoNightModeItem],
                     [allItems.sendFeedbackItem],
                     [allItems.acknowledgementItem]]
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
        allItems.reminderItem.enabled = Settings.Reminder.Enabled
        if let date = Settings.Reminder.Date {
            allItems.reminderDateItem.date = date
        }
        allItems.followingStreamSourceItem.enabled = Settings.StreamSource.Following
        allItems.newTodayStreamSourceItem.enabled = Settings.StreamSource.NewToday
        allItems.popularTodayStreamSourceItem.enabled = Settings.StreamSource.PopularToday
        allItems.debutsStreamSourceItem.enabled = Settings.StreamSource.Debuts
        allItems.showAuthorItem.enabled = Settings.Customization.ShowAuthor
    }
    
    func titleFor(section: Int) -> String? {
        let notificationsTitle = Localized("SettingsViewController.Notifications",
                                                   comment: "Title of group of buttons for notifications settings")
        let streamSourcesTitle = Localized("SettingsViewController.StreamSource",
                                                   comment: "Title of group of buttons for stream source settings")
        let customizationTitle = Localized("SettingsViewController.Customization",
                                                   comment: "Title of group of buttons for customization settings")
        let feedbackTitle = Localized("SettingsViewModel.Feedback",
                                              comment: "Title of group of buttons for sending feedback")
        
        switch section {
            case 1: return notificationsTitle
            case 2: return streamSourcesTitle
            case 3: return customizationTitle
            case 4: return feedbackTitle
            default: return nil
        }
    }
    
    func heightForHeaderIn(section: Int) -> CGFloat {
        return userMode == .loggedUser && section == 0 ? 0 : 44.0
    }
}

// MARK: Private extension

private extension SettingsViewModel {

    func configureItemsActions() {
        allItems.createAccountItem.onSelect = {
            [weak self] in
            self?.settingsViewController?.authenticateUser()
        }
        
        allItems.showMyProfileItem.onSelect = { [weak self] in
            if let user = self?.loggedInUser {
                let viewController = ProfileViewController(user: user)
                self?.settingsViewController?.navigationController?.pushViewController(viewController, animated: true)
            }
        }

        allItems.acknowledgementItem.onSelect = {
            [weak self] in
            self?.settingsViewController?.presentAcknowledgements()
        }
        
        allItems.sendFeedbackItem.onSelect = {
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

        allItems.reminderItem.valueChanged = {
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

        allItems.reminderDateItem.onValueChanged = { date -> Void in
            if self.allItems.reminderItem.enabled {
                self.registerLocalNotification()
            }
            Settings.Reminder.Date = date
        }

        allItems.followingStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.Following = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.followingStreamSource, state: newValue)
        }

        allItems.newTodayStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.NewToday = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.newTodayStreamSource, state: newValue)
        }

        allItems.popularTodayStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.PopularToday = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.popularTodayStreamSource, state: newValue)
        }

        allItems.debutsStreamSourceItem.valueChanged = { newValue in
            Settings.StreamSource.Debuts = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.debutsStreamSource, state: newValue)
        }

        allItems.showAuthorItem.valueChanged = { newValue in
            Settings.Customization.ShowAuthor = newValue
            self.checkStreamsSource()
            AnalyticsManager.trackSettingChanged(.authorOnHomeScreen, state: newValue)
        }
        
        allItems.nightModeItem.valueChanged = { newValue in
            Settings.Customization.NightMode = newValue
            ColorModeProvider.change(to: newValue ? .nightMode : .dayMode)
            AnalyticsManager.trackSettingChanged(.nightMode, state: newValue)
        }
        
        allItems.autoNightModeItem.valueChanged = { newValue in
            Settings.Customization.AutoNightMode = newValue
            ColorModeProvider.setup()
            AnalyticsManager.trackSettingChanged(.autoNightMode, state: newValue)
        }
    }
    
    func checkStreamsSource() {
        if Settings.areAllStreamSourcesOff() {
            let title = Localized("SettingsViewModel.AllSources",
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
        forUserID: loggedInUser?.identifier ?? "userID", time: allItems.reminderDateItem.date)

        if localNotification == nil {

            alertDelegate?.displayAlert(preparePermissionsAlert())

            allItems.reminderItem.enabled = false
            Settings.Reminder.Enabled = false
            delegate?.didChangeItemsAtIndexPaths(indexPathsForItems([allItems.reminderItem])!)
        }
    }

    func unregisterLocalNotification() {
        LocalNotificationRegistrator.unregisterNotification(forUserID: loggedInUser?.identifier ?? "userID")
    }

    // MARK: Prepare alert

    func preparePermissionsAlert() -> AOAlertController {
        let message = Localized("SettingsViewModel.AccessToNotifications",
                                        comment: "Body of alert, asking user to grant notifications permission.")
        let alert = AOAlertController(title: nil, message: message, style: .alert)

        let settingsActionTitle = Localized("SettingsViewModel.Settings",
                                                    comment: "Redirect user to Settings app")
        let settingsAction = AOAlertAction(title: settingsActionTitle, style: .default) { _ in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }

        let cancelActionTitle = Localized("SettingsViewModel.Dismiss",
                                                  comment: "Notifications alert, dismiss button.")
        let cancelAction = AOAlertAction(title: cancelActionTitle, style: .default, handler: nil)

        alert.addAction(settingsAction)
        alert.addAction(cancelAction)

        return alert
    }
}
