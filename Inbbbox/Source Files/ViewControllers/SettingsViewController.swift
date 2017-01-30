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

    fileprivate var viewModel: SettingsViewModel!
    fileprivate var authenticator: Authenticator?
    fileprivate var currentColorMode =  ColorModeProvider.current()
    
    convenience init() {
        self.init(style: UITableViewStyle.grouped)
        viewModel = SettingsViewModel(delegate: self)
        viewModel.settingsViewController = self
        title = viewModel.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLogoutButton()

        tableView.registerClass(SwitchCell.self)
        tableView.registerClass(DetailsCell.self)
        tableView.registerClass(LabelCell.self)

        tableView?.hideSeparatorForEmptyCells()
        tableView?.tableHeaderView = SettingsTableHeaderView(size: CGSize (width: 0, height: 250))

        provideDataForHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshViewAccordingToAuthenticationStatus()
        viewModel.updateStatus()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.trackScreen(.settingsView)
    }
}

// MARK: ModelUpdatable

extension SettingsViewController: ModelUpdatable {

    func didChangeItemsAtIndexPaths(_ indexPaths: [IndexPath]) {
        indexPaths.forEach {
            if let cell = tableView?.cellForRow(at: $0) {
                let item = viewModel[$0.section][$0.row]
                configureSettingCell(cell, forItem: item)
            }
        }
    }
}

// MARK: AlertDisplayable

extension SettingsViewController: AlertDisplayable {

    func displayAlert(_ alert: AOAlertController) {
        tabBarController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: FlashMessageDisplayable

extension SettingsViewController: FlashMessageDisplayable {
    func displayFlashMessage(_ model: FlashMessageViewModel) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: model.title, canBeDismissedByUser: true, shouldBeDisplayedInViewController: false)
    }
}

// MARK: UITableViewDataSource

extension SettingsViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsCount()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel[indexPath.section][indexPath.row]
        let cell = tableView.cellForItemCategory(item.category)

        configureSettingCell(cell, forItem: item)

        return cell
    }
}

// MARK: UITableViewDelegate

extension SettingsViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let item = viewModel[indexPath.section][indexPath.row]

        if let item = item as? SwitchItem, let cell = cell as? SwitchCell {
            item.bindSwitchControl(cell.switchControl)
        }
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        let cellIndexPath = tableView.indexPath(for: cell) ?? indexPath
        let section = cellIndexPath.section
        let row = cellIndexPath.row
        if section < viewModel.sectionsCount() && row < viewModel[section].count {
            let item = viewModel[section][row]

            if let item = item as? SwitchItem, cell is SwitchCell {
                item.unbindSwitchControl()
            }
        }

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleFor(section: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = viewModel[indexPath.section][indexPath.row]

        if let item = item as? DateItem {

            let completion: ((Date) -> Void) = { date in
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

        if let _ = item as? DetailsItem {
            navigationController?.pushViewController(LanguageViewController(), animated: true)
        }
        tableView.deselectRowIfSelectedAnimated(true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeaderIn(section: section)
    }
}

// MARK: Configure cells

private extension SettingsViewController {

    func configureSettingCell(_ cell: UITableViewCell, forItem item: GroupItem) {
        if let item = item as? SwitchItem, let switchCell = cell as? SwitchCell {
            configureSwitchCell(switchCell, forItem: item, withMode: currentColorMode)
        } else if let item = item as? DateItem, let dateCell = cell as? DetailsCell {
            configureDateCell(dateCell, forItem: item, withMode: currentColorMode)
        } else if let item = item as? DetailsItem, let dateCell = cell as? DetailsCell {
            configureDetailsCell(dateCell, forItem: item, withMode: currentColorMode)
        } else if let item = item as? LabelItem, let labelCell = cell as? LabelCell {
            configureLabelCell(labelCell, forItem: item, withMode: currentColorMode)
        }
    }

    func configureSwitchCell(_ cell: SwitchCell, forItem item: SwitchItem, withMode mode: ColorModeType) {
        cell.titleLabel.text = item.title
        cell.switchControl.isOn = item.enabled
        cell.selectionStyle = .none
        cell.adaptColorMode(mode)
    }

    func configureDateCell(_ cell: DetailsCell, forItem item: DateItem, withMode mode: ColorModeType) {
        cell.titleLabel.text = item.title
        cell.setDetailText(item.dateString)
        cell.adaptColorMode(mode)
    }

    func configureDetailsCell(_ cell: DetailsCell, forItem item: DetailsItem, withMode mode: ColorModeType) {
        cell.titleLabel.text = item.title
        cell.setDetailText(item.detailString)
        cell.adaptColorMode(mode)
    }

    func configureLabelCell(_ cell: LabelCell, forItem item: LabelItem, withMode mode: ColorModeType) {
        cell.titleLabel.text = item.title
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.adaptColorMode(mode)
    }

}

// MARK: Configuration

private extension SettingsViewController {

    func configureLogoutButton() {
        navigationItem.rightBarButtonItem = viewModel.loggedInUser != nil ? UIBarButtonItem(
            title: Localized("SettingsViewController.LogOut", comment: "Log out button"),
            style: .plain,
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
            header.usernameLabel.text = Localized("SettingsViewController.Guest",
                    comment: "Is user a guest without account?")
        }
        var avatarUrl: URL? = nil
        if let url = viewModel.loggedInUser?.avatarURL, !(url.absoluteString.contains("avatar-default-")) {
            avatarUrl = url as URL
        }
        header.avatarView.imageView.loadImageFromURL(avatarUrl,
                placeholderImage: UIImage(named: "ic-guest-avatar"))
    }
}

// MARK: SafariAuthorizable

extension SettingsViewController: SafariAuthorizable {
    func handleOpenURL(_ url: URL) {
        authenticator?.loginWithOAuthURLCallback(url)
    }
}

// MARK: Authentication

extension SettingsViewController {

    func authenticateUser() {
        let interactionHandler: ((SFSafariViewController) -> Void) = { controller in
            self.present(controller, animated: true, completion: nil)
        }

        let success: ((Void) -> Void) = {
            self.dismiss(animated: true, completion: nil)
            self.refreshViewAccordingToAuthenticationStatus()
        }

        let failure: ((Error) -> Void) = { error in
            self.dismiss(animated: true, completion: nil)
        }

        authenticator = Authenticator(service: .dribbble,
                                      interactionHandler: interactionHandler,
                                      success: success,
                                      failure: failure)
        authenticator?.login()
    }

    func refreshViewAccordingToAuthenticationStatus() {
        let userMode = UserStorage.isUserSignedIn ? UserMode.loggedUser : .demoUser
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
        let delegate = UIApplication.shared.delegate as? AppDelegate
        delegate?.rollbackToLoginViewController()
    }

    func presentAcknowledgements() {
        let acknowledgementsNavigationController =
        UINavigationController(rootViewController: AcknowledgementsViewController())
        present(acknowledgementsNavigationController, animated: true, completion: nil)
    }
}

// MARK: Mail Composer Delegate

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) { [unowned self] in
            if (result == MFMailComposeResult.sent) {
                let message = FlashMessageViewModel(title: Localized("SettingsViewModel.FeedbackSent", comment: "User Settings, feedback sent."))
                self.displayFlashMessage(message)
            }
        }
    }
}

private extension UITableView {

    func cellForItemCategory(_ category: GroupItem.Category) -> UITableViewCell {

        switch category {
            case .details: return dequeueReusableCell(DetailsCell.self)
            case .date: return dequeueReusableCell(DetailsCell.self)
            case .boolean: return dequeueReusableCell(SwitchCell.self)
            case .string: return dequeueReusableCell(LabelCell.self)
        }
    }
}

extension SettingsViewController: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        currentColorMode = mode
        tableView.reloadData()
        updateUsernameColorForMode(mode)
    }
    
    fileprivate func updateUsernameColorForMode(_ mode: ColorModeType) {
        guard let header = tableView?.tableHeaderView as? SettingsTableHeaderView else {
            return
        }
        
        header.adaptColorMode(mode)
    }
}
