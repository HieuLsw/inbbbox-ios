//
//  BlockedUsersViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit

class BlockedUsersViewController: UITableViewController {

    fileprivate var users: [UserType] = []
    fileprivate let colorModeProvider = ColorModeProvider.current()

    fileprivate lazy var usersProvider = UsersProvider()

    init() {
        super.init(style: UITableViewStyle.grouped)
        title = Localized("BlockedUsersViewController.Title", comment: "Title of BlockedUsersViewController")
    }

    @available(*, unavailable, message: "Use init() instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(BlockedUsersTableViewCell.self, forCellReuseIdentifier: BlockedUsersTableViewCell.identifier)
        tableView.allowsSelection = false

        provideBlockedUsers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        _ = navigationController?.popViewController(animated: true)
    }

    func provideBlockedUsers() -> Void {
        firstly {
            usersProvider.provideBlockedUsers()
        }.then { users -> Void in
            if let blockedUsers = users {
                self.users = blockedUsers
                self.tableView.reloadData()
            }
        }.catch { _ in }
    }
}

// MARK: UITableViewDataSource

extension BlockedUsersViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(BlockedUsersTableViewCell.self)
        cell.avatarView.imageView.loadImageFromURL(users[indexPath.row].avatarURL, placeholderImage: UIImage(named: "ic-comments-nopicture"))
        cell.titleLabel.text = users[indexPath.row].name ?? users[indexPath.row].username
        cell.titleLabel.textColor = colorModeProvider.tableViewCellTextColor
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            firstly {
                UsersRequester().unblock(user: users[indexPath.row])
            }.then {
                self.provideBlockedUsers()
            }.catch { _ in }
        }
    }
}

// MARK: UITableViewDelegate

extension BlockedUsersViewController {

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
