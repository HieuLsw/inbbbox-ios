//
//  ProfileBucketsViewController.swift
//  Inbbbox
//
//  Created by Robert Abramczyk on 25/01/2017.
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

class ProfileBucketsViewController: UITableViewController {

    fileprivate var currentColorMode = ColorModeProvider.current()
    fileprivate var viewModel: BucketsViewModel
    
    /// Initialize ProfileBucketsViewController.
    ///
    /// - parameter viewModel: ProfileInfoViewModel for the presented user
    init(user: UserType) {
        viewModel = BucketsViewModel()
        super.init(nibName: nil, bundle: nil)
        //viewModel.delegate = self
    }
    
    @available(*, unavailable, message: "Use init(user:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    @available(*, unavailable, message: "Use init(user:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        
        tableView.registerClass(CollectionCell.self)
    }
}

// MARK: - Table view data source

extension ProfileBucketsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(CollectionCell.self) as CollectionCell
        
        cell.adaptColorMode(currentColorMode)
        cell.selectionStyle = .none
        cell.titleLabel.text = "Title"
        cell.backgroundLabel.text = "Title"
        cell.counterLabel.text = "8"
        
        return cell
    }
    
}
