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
    fileprivate var viewModel: ProfileBucketsViewModel!
    
    /// Initialize ProfileBucketsViewController.
    ///
    /// - parameter user: User to initialize view controller with.
    init(user: UserType) {
        super.init(nibName: nil, bundle: nil)
        
        viewModel = ProfileBucketsViewModel(user: user)
        viewModel.delegate = self
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
        
        viewModel.downloadInitialItems()
    }
}

// MARK: - Table view data source

extension ProfileBucketsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prepareBucketCell(at: indexPath, in: tableView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }
}

// MARK: Private extension

private extension ProfileBucketsViewController {
    
    func prepareBucketCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(CollectionCell.self)
        let cellData = viewModel.bucketTableViewCellViewData(indexPath)
        
        cell.adaptColorMode(currentColorMode)
        cell.selectionStyle = .none
        cell.titleLabel.text = cellData.name
        cell.backgroundLabel.text = cellData.name
        cell.counterLabel.text = cellData.numberOfShots
        cell.shots = cellData.shots
        
        return cell
    }
}

// MARK: BaseCollectionViewViewModelDelegate

extension ProfileBucketsViewController: BaseCollectionViewViewModelDelegate {
    
    func viewModelDidLoadInitialItems() {
        tableView?.reloadData()
    }
    
    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        tableView?.reloadData()
    }
    
    func viewModelDidFailToLoadItems(_ error: Error) {
        guard let visibleViewController = navigationController?.visibleViewController else { return }
        FlashMessage.sharedInstance.showNotification(inViewController: visibleViewController, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }
    
    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        tableView?.insertRows(at: indexPaths, with: .automatic)
    }
    
    func viewModel(_ viewModel: BaseCollectionViewViewModel, didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        tableView?.reloadRows(at: [indexPath], with: .automatic)
    }
}
