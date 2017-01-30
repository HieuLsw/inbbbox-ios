//
//  LanguageViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class LanguageViewController: UITableViewController {

    fileprivate let languages: [Language]
    fileprivate let colorModeProvider = ColorModeProvider.current()

    init(languages: [Language] = Language.allOptions) {
        self.languages = languages
        super.init(style: UITableViewStyle.grouped)
        title = "Choose language" // NGRTodo: fix this
    }

    @available(*, unavailable, message: "Use init(languages:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: UITableViewDataSource

extension LanguageViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = languages[indexPath.row].localizedName
        cell.textLabel?.textColor = colorModeProvider.tableViewCellTextColor
        return cell
    }
}

// MARK: UITableViewDelegate

extension LanguageViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        LanguageManager.shared.set(language: languages[indexPath.row])
        UIApplication.shared.keyWindow?.rootViewController = CenterButtonTabBarController()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}
