//
//  ProfileBucketsViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PeekPop

class ProfileBucketsViewController: UITableViewController, Support3DTouch {

    fileprivate var currentColorMode = ColorModeProvider.current()
    fileprivate var viewModel: ProfileBucketsViewModel!
    fileprivate var rowsOffset = [Int:CGFloat]()
    fileprivate var currentBucket = [ShotType]()
    
    fileprivate var modalTransitionAnimator: ZFModalTransitionAnimator?
    
    internal var peekPop: PeekPop?
    internal var didCheckedSupport3DForOlderDevices = false
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addSupport3DForOlderDevicesIfNeeded(with: self, viewController: self, sourceView: tableView!)
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
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let collectionCell = cell as? CollectionCell else { return }
        rowsOffset[indexPath.row] = collectionCell.collectionView.contentOffset.x
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
        if let offset = rowsOffset[indexPath.row] {
            cell.collectionView.contentOffset = CGPoint(x: offset, y: 0)
        } else {
            cell.collectionView.contentOffset = CGPoint.zero
        }
        
        if (!cell.isRegisteredTo3DTouch) {
            cell.isRegisteredTo3DTouch = registerTo3DTouch(cell)
        }
        
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

// MARK: UIViewControllerPreviewingDelegate

extension ProfileBucketsViewController: UIViewControllerPreviewingDelegate {
    
    fileprivate func peekPopPresent(viewController: UIViewController) {
        guard let detailsViewController = viewController as? ShotDetailsViewController else { return }
        
        detailsViewController.customizeFor3DTouch(false)
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: currentBucket, initialViewController: detailsViewController)
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
        modalTransitionAnimator?.behindViewScale = 1
        
        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .custom
        
        present(pageViewController, animated: true, completion: nil)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let tableIndexPath = tableView.indexPathForRow(at: previewingContext.sourceView.convert(location, to: tableView)),
            let collectionCell = tableView.cellForRow(at: tableIndexPath) as? CollectionCell
        else {
            return nil
        }
        
        let collectionView = collectionCell.collectionView
        guard
            let collectionIndexPath = collectionCell.collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView.cellForItem(at: collectionIndexPath),
            let bucket = viewModel.bucketsIndexedShots[tableIndexPath.row],
            bucket.count > collectionIndexPath.item
        else {
            return nil
        }
        
        currentBucket = bucket
        let shot = bucket[collectionIndexPath.item]
        let viewPoint = collectionCell.convert(cell.frame.origin, from: collectionCell.collectionView)
        previewingContext.sourceRect = CGRect(origin: viewPoint, size: cell.frame.size)
        
        let controller = ShotDetailsViewController(shot: shot)
        controller.customizeFor3DTouch(true)
        controller.shotIndex = collectionIndexPath.item
        
        return controller
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}

// MARK: PeekPopPreviewingDelegate

extension ProfileBucketsViewController: PeekPopPreviewingDelegate {
    
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let tableIndexPath = tableView.indexPathForRow(at: tableView.convert(location, to: tableView)),
            let collectionCell = tableView.cellForRow(at: tableIndexPath) as? CollectionCell
        else {
            return nil
        }
        
        let collectionView = collectionCell.collectionView
        guard
            let collectionIndexPath = collectionCell.collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView.cellForItem(at: collectionIndexPath),
            let bucket = viewModel.bucketsIndexedShots[tableIndexPath.row],
            bucket.count > collectionIndexPath.item
        else {
            return nil
        }
        
        currentBucket = bucket
        let shot = bucket[collectionIndexPath.item]
        let viewPoint = collectionView.convert(cell.bounds.origin, to: view)
        previewingContext.sourceRect = CGRect(origin: viewPoint, size: cell.frame.size)
        
        let controller = ShotDetailsViewController(shot: shot)
        controller.customizeFor3DTouch(true)
        controller.shotIndex = collectionIndexPath.item
        
        return controller
    }
    
    func previewingContext(_ previewingContext: PreviewingContext, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}
