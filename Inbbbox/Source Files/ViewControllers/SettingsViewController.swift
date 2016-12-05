//
//  SettingsViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import AOAlertController
import SafariServices
import MessageUI

class SettingsViewController: UITableViewController {

    private var viewModel: SettingsViewModel!
    private var authenticator: Authenticator?
    private var currentColorMode =  ColorModeProvider.current()
    
    convenience init() {
        self.init(style: UITableViewStyle.Grouped)
        viewModel = SettingsViewModel(delegate: self)
        viewModel.settingsViewController = self
        title = viewModel.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLogoutButton()

        tableView.registerClass(SwitchCell.self)
        tableView.registerClass(DateCell.self)
        tableView.registerClass(LabelCell.self)

        tableView?.hideSeparatorForEmptyCells()
        tableView?.tableHeaderView = SettingsTableHeaderView(size: CGSize (width: 0, height: 250))

        provideDataForHeader()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshViewAccordingToAuthenticationStatus()
        viewModel.updateStatus()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.trackScreen(.SettingsView)
    }
}

// MARK: ModelUpdatable

extension SettingsViewController: ModelUpdatable {

    func didChangeItemsAtIndexPaths(indexPaths: [NSIndexPath]) {
        indexPaths.forEach {
            if let cell = tableView?.cellForRowAtIndexPath($0) {
                let item = viewModel[$0.section][$0.row]
                configureSettingCell(cell, forItem: item)
            }
        }
    }
}

extension SettingsViewController: AlertDisplayable {

    func displayAlert(alert: AOAlertController) {
        tabBarController?.presentViewController(alert, animated: true, completion: nil)
    }
}

extension SettingsViewController: FlashMessageDisplayable {
    func displayFlashMessage(model: FlashMessageViewModel) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: model.title, canBeDismissedByUser: true)
    }
}

// MARK: UITableViewDataSource

extension SettingsViewController {

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sectionsCount()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = viewModel[indexPath.section][indexPath.row]
        let cell = tableView.cellForItemCategory(item.category)

        configureSettingCell(cell, forItem: item)

        return cell ?? UITableViewCell()
    }
}

// MARK: UITableViewDelegate

extension SettingsViewController {

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        let item = viewModel[indexPath.section][indexPath.row]

        if let item = item as? SwitchItem, cell = cell as? SwitchCell {
            item.bindSwitchControl(cell.switchControl)
        }
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        let cellIndexPath = tableView.indexPathForCell(cell) ?? indexPath
        let section = cellIndexPath.section
        let row = cellIndexPath.row
        if section < viewModel.sectionsCount() && row < viewModel[section].count {
            let item = viewModel[section][row]

            if let item = item as? SwitchItem where cell is SwitchCell {
                item.unbindSwitchControl()
            }
        }

    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let notificationsTitle = NSLocalizedString("SettingsViewController.Notifications",
                                                   comment: "Title of group of buttons for notifications settings")
        let streamSourcesTitle = NSLocalizedString("SettingsViewController.StreamSource",
                                                   comment: "Title of group of buttons for stream source settings")
        let customizationTitle = NSLocalizedString("SettingsViewController.Customization",
                                                   comment: "Title of group of buttons for customization settings")
        let feedbackTitle = NSLocalizedString("SettingsViewModel.Feedback",
                                                   comment: "Title of group of buttons for sending feedback")

        switch section {
            case 0: return viewModel.userMode == .LoggedUser ? notificationsTitle : nil
            case 1: return viewModel.userMode == .LoggedUser ? streamSourcesTitle : notificationsTitle
            case 2: return viewModel.userMode == .LoggedUser ? customizationTitle : streamSourcesTitle
            case 3: return viewModel.userMode == .LoggedUser ? feedbackTitle : customizationTitle
            case 4: return viewModel.userMode == .LoggedUser ? nil : feedbackTitle
            default: return nil
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let item = viewModel[indexPath.section][indexPath.row]

        if let item = item as? DateItem {

            let completion: (NSDate -> Void) = { date in
                item.date = date
                item.update()
                self.didChangeItemsAtIndexPaths([indexPath])
            }

            navigationController?.pushViewController(DatePickerViewController(date: item.date,
                    completion: completion), animated: true)
        }
        if let labelItem = item as? LabelItem {
            labelItem.onSelect?()
        }
        tableView.deselectRowIfSelectedAnimated(true)
    }
}

// MARK: Configure cells

private extension SettingsViewController {

    func configureSettingCell(cell: UITableViewCell, forItem item: GroupItem) {
        if let item = item as? SwitchItem, switchCell = cell as? SwitchCell {
            configureSwitchCell(switchCell, forItem: item, withMode: currentColorMode)
        } else if let item = item as? DateItem, dateCell = cell as? DateCell {
            configureDateCell(dateCell, forItem: item, withMode: currentColorMode)
        } else if let item = item as? LabelItem, labelCell = cell as? LabelCell {
            configureLabelCell(labelCell, forItem: item, withMode: currentColorMode)
        }
    }

    func configureSwitchCell(cell: SwitchCell, forItem item: SwitchItem, withMode mode:ColorModeType) {
        cell.titleLabel.text = item.title
        cell.switchControl.on = item.enabled
        cell.selectionStyle = .None
        cell.adaptColorMode(mode)
    }

    func configureDateCell(cell: DateCell, forItem item: DateItem, withMode mode:ColorModeType) {
        cell.titleLabel.text = item.title
        cell.setDateText(item.dateString)
        cell.adaptColorMode(mode)
    }

    func configureLabelCell(cell: LabelCell, forItem item: LabelItem, withMode mode: ColorModeType) {
        cell.titleLabel.text = item.title
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.adaptColorMode(mode)
    }

}

// MARK: Configuration

private extension SettingsViewController {

    func configureLogoutButton() {
        navigationItem.rightBarButtonItem = viewModel.loggedInUser != nil ? UIBarButtonItem(
            title: NSLocalizedString("SettingsViewController.LogOut", comment: "Log out button"),
            style: .Plain,
            target: self,
            action: #selector(didTapLogOutButton(_:))
        ) : nil
    }

    func provideDataForHeader() {

        guard let header = tableView?.tableHeaderView as? SettingsTableHeaderView else {
            return
        }
        if let user = viewModel.loggedInUser {
            header.usernameLabel.text = user.name ?? user.username
        } else {
            header.usernameLabel.text = NSLocalizedString("SettingsViewController.Guest",
                    comment: "Is user a guest without account?")
        }
        var avatarUrl: NSURL? = nil
        if let url = viewModel.loggedInUser?.avatarURL where !url.absoluteString.containsString("avatar-default-") {
            avatarUrl = url
        }
        header.avatarView.imageView.loadImageFromURL(avatarUrl,
                placeholderImage: UIImage(named: "ic-guest-avatar"))
    }
}

// MARK: SafariAuthorizable

extension SettingsViewController: SafariAuthorizable {
    func handleOpenURL(url: NSURL) {
        authenticator?.loginWithOAuthURLCallback(url)
    }
}

// MARK: Authentication

extension SettingsViewController {

    func authenticateUser() {
        let interactionHandler: (SFSafariViewController -> Void) = { controller in
            self.presentViewController(controller, animated: true, completion: nil)
        }

        let success: (Void -> Void) = {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.refreshViewAccordingToAuthenticationStatus()
        }

        let failure: (ErrorType -> Void) = { error in
            self.dismissViewControllerAnimated(true, completion: nil)
        }

        authenticator = Authenticator(service: .Dribbble,
                                      interactionHandler: interactionHandler,
                                      success: success,
                                      failure: failure)
        authenticator?.login()
    }

    func refreshViewAccordingToAuthenticationStatus() {
        let userMode = UserStorage.isUserSignedIn ? UserMode.LoggedUser : .DemoUser
        if userMode != viewModel.userMode {
            viewModel = SettingsViewModel(delegate: self)
            viewModel.settingsViewController = self
            provideDataForHeader()
            tableView.reloadData()
            configureLogoutButton()
        }
    }
}

// MARK: Actions

extension SettingsViewController {

    func didTapLogOutButton(_: UIBarButtonItem) {
        Authenticator.logout()
        let delegate = UIApplication.sharedApplication().delegate as? AppDelegate
        delegate?.rollbackToLoginViewController()
    }

    func presentAcknowledgements() {
        let acknowledgementsNavigationController =
        UINavigationController(rootViewController: AcknowledgementsViewController())
        presentViewController(acknowledgementsNavigationController, animated: true, completion: nil)
    }
}

// MARK: Mail Composer Delegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true) { [unowned self] in
            if (result == MFMailComposeResultSent) {
                let message = FlashMessageViewModel(title: NSLocalizedString("SettingsViewModel.FeedbackSent", comment: "User Settings, feedback sent."))
                self.displayFlashMessage(message)
            }
        }
    }
}

private extension UITableView {

    func cellForItemCategory(category: GroupItem.Category) -> UITableViewCell {

        switch category {
            case .Date: return dequeueReusableCell(DateCell)
            case .Boolean: return dequeueReusableCell(SwitchCell)
            case .String: return dequeueReusableCell(LabelCell)
        }
    }
}

extension SettingsViewController: ColorModeAdaptable {
    func adaptColorMode(mode: ColorModeType) {
        currentColorMode = mode
        tableView.reloadData()
        updateUsernameColorForMode(mode)
    }
    
    private func updateUsernameColorForMode(mode: ColorModeType) {
        guard let header = tableView?.tableHeaderView as? SettingsTableHeaderView else {
            return
        }
        
        header.adaptColorMode(mode)
    }
}
