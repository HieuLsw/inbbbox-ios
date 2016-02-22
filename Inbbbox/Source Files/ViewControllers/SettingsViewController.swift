//
//  SettingsViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import KFSwiftImageLoader
import PromiseKit

class SettingsViewController: UITableViewController {

    private var viewModel: SettingsViewModel!

    convenience init() {
        self.init(style: UITableViewStyle.Grouped)
        viewModel = SettingsViewModel(delegate: self, logedIn: UserStorage.logedIn)
        title = viewModel.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Log Out", comment: ""),
            style: .Plain,
            target: self,
            action: "didTapLogOutButton:"
        )
        
        tableView.registerClass(SwitchCell.self)
        tableView.registerClass(DateCell.self)
        tableView.registerClass(LabelCell.self)

        tableView?.hideSeparatorForEmptyCells()
        tableView?.backgroundColor = UIColor.backgroundGrayColor()
        tableView?.tableHeaderView = SettingsTableHeaderView(size: CGSize (width: 0, height: 250))

        provideDataForHeader()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshViewAccordingToAuthenticationStatus()
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

    func displayAlert(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.blackColor()
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

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let item = viewModel[indexPath.section][indexPath.row]

        if let item = item as? SwitchItem, cell = cell as? SwitchCell {
            item.bindSwitchControl(cell.switchControl)
        }
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
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
        switch section {
            case 0: return nil
            case 1: return NSLocalizedString("NOTIFICATIONS", comment: "")
            case 2: return NSLocalizedString("INBBBOX STREAM SOURCE", comment: "")
            default: return ""
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

            navigationController?.pushViewController(DatePickerViewController(date: item.date, completion: completion), animated: true)
        }
        if item is LabelItem {
            authenticateUser()
        }
        tableView.deselectRowIfSelectedAnimated(true)
    }
}

// MARK: Configure cells

private extension SettingsViewController {

    func configureSettingCell(cell: UITableViewCell, forItem item: GroupItem) {
        if let item = item as? SwitchItem {
            configureSwitchCell(cell as! SwitchCell, forItem: item)
        } else if let item = item as? DateItem {
            configureDateCell(cell as! DateCell, forItem: item)
        } else if let item = item as? LabelItem {
            configureLabelCell(cell as! LabelCell, forItem: item)
        }
    }

    func configureSwitchCell(cell: SwitchCell, forItem item: SwitchItem) {
        cell.textLabel?.text = item.title
        cell.switchControl.on = item.on
        cell.selectionStyle = .None
    }

    func configureDateCell(cell: DateCell, forItem item: DateItem) {
        cell.textLabel?.text = item.title
        cell.setDateText(item.dateString)
    }
    
    func configureLabelCell(cell: LabelCell, forItem item: LabelItem) {
        cell.titleLabel.text = item.title
    }
    
}

// MARK: Configuration

private extension SettingsViewController {

    func provideDataForHeader() {

        guard let header = tableView?.tableHeaderView as? SettingsTableHeaderView else {
            return
        }
        if let user = viewModel.loggedInUser {
            header.usernameLabel.text = user.username
        } else {
            header.usernameLabel.text = NSLocalizedString("Guest?", comment: "")
        }

        if let urlString = viewModel.loggedInUser?.avatarString {
            header.avatarView.imageView.loadImageFromURLString(urlString)
        } else {
            //NGRToDo: provide placeholder
            header.avatarView.imageView.image = UIImage(named: "avatar_placeholder")
        }
    }
}

// MARK: Authentication

private extension SettingsViewController {
    
    func authenticateUser() {
        let interactionHandler: (UIViewController -> Void) = { controller in
            self.presentViewController(controller, animated: true, completion: nil)
        }
        let authenticator = Authenticator(interactionHandler: interactionHandler)
        
        firstly {
            authenticator.loginWithService(.Dribbble)
        }.then { result -> Void in
            self.refreshViewAccordingToAuthenticationStatus()
        }
    }
    
    func refreshViewAccordingToAuthenticationStatus() {
        let setupType = UserStorage.logedIn ? SettingsViewModel.SetupType.LogedUser : .DemoUser
        if setupType != self.viewModel.setupType {
            self.viewModel = SettingsViewModel(delegate: self, logedIn: UserStorage.logedIn)
            self.provideDataForHeader()
            self.tableView.reloadData()
        }
    }
}

// MARK: Actions

extension SettingsViewController {

    func didTapLogOutButton(_: UIBarButtonItem) {
        Authenticator.logout()
        refreshViewAccordingToAuthenticationStatus()
        //NGRToDo: Remember to hide settings when user is logged out
    }
}

private extension UITableView {

    func cellForItemCategory(category: GroupItem.Category) -> UITableViewCell {

        switch category {
            case .Date: return dequeueReusableCell(DateCell.self)
            case .Boolean: return dequeueReusableCell(SwitchCell.self)
            case .String: return dequeueReusableCell(LabelCell.self)
        }
    }
}
