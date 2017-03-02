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
        title = Localized("Zablokowani", comment: "nvm") // NGRTodo: fix before CR
    }

    @available(*, unavailable, message: "Use init(languages:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(BlockedUsersTableViewCell.self, forCellReuseIdentifier: BlockedUsersTableViewCell.identifier)
        tableView.allowsSelection = false

        firstly {
            usersProvider.provideBlockedUsers()
        }.then { users -> Void in
            if let blockedUsers = users {
                self.users = blockedUsers
                self.tableView.reloadData()
            }
        }.catch { error in print(error) } // NGRTodo: remove printing before CR
    }
}

// MARK: UITableViewDataSource

extension BlockedUsersViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlockedUsersTableViewCell.identifier, for: indexPath) as! BlockedUsersTableViewCell
        cell.avatarView.imageView.loadImageFromURL(users[indexPath.row].avatarURL, placeholderImage: UIImage(named: "ic-comments-nopicture"))
        cell.titleLabel.text = users[indexPath.row].name ?? users[indexPath.row].username
        cell.titleLabel.textColor = colorModeProvider.tableViewCellTextColor
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            users.remove(at: indexPath.row) // NGRTodo: fix before CR - remove from DB
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: UITableViewDelegate

extension BlockedUsersViewController {

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
