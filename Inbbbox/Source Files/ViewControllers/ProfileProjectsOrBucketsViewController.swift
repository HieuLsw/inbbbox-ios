//
//  ProfileProjectsOrBucketsViewController.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import PeekPop
import Async

class ProfileProjectsOrBucketsViewController: UITableViewController, Support3DTouch, ContainingScrollableView {

    /// Defines which view model should be loaded
    enum ProfileProjectsOrBucketsType: String {
        case projects, buckets
    }

    var scrollableView: UIScrollView {
        return tableView
    }

    var scrollContentOffset: (() -> CGPoint)?

    fileprivate var currentColorMode = ColorModeProvider.current()
    fileprivate var viewModel: ProfileProjectsOrBucketsViewModel!
    fileprivate var rowsOffset = [Int: CGFloat]()
    fileprivate var currentContainer = [ShotType]()

    fileprivate var modalTransitionAnimator: ZFModalTransitionAnimator?

    internal var peekPop: PeekPop?
    internal var didCheckedSupport3DForOlderDevices = false

    /// Initialize ProfileProjectsOrBucketsViewController.
    ///
    /// - parameter user: User to initialize view controller with.
    init(user: UserType, type: ProfileProjectsOrBucketsType) {
        super.init(nibName: nil, bundle: nil)

        viewModel = type == .projects ? ProfileProjectsViewModel(user: user) : ProfileBucketsViewModel(user: user)
        viewModel.delegate = self
    }

    @available(*, unavailable, message: "Use init(user: type:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(user: type:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorStyle = .none
        tableView.registerClass(CarouselCell.self)
        tableView.updateInsets(top: ProfileView.headerInitialHeight)

        viewModel.downloadInitialItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if viewModel.itemsCount == 0 {
            tableView.updateInsets(bottom: tableView.frame.height)
        }

        if let offset = scrollContentOffset?() {
            tableView.contentOffset = offset
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addSupport3DForOlderDevicesIfNeeded(with: self, viewController: self, sourceView: tableView!)
    }
}

// MARK: - Table view data source

extension ProfileProjectsOrBucketsViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prepareCell(at: indexPath, in: tableView)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        if indexPath.row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let carouselCell = cell as? CarouselCell else { return }
        rowsOffset[indexPath.row] = carouselCell.collectionView.contentOffset.x
    }
}

// MARK: Private extension

private extension ProfileProjectsOrBucketsViewController {

    func prepareCell(at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(CarouselCell.self)
        cell.adaptColorMode(currentColorMode)
        cell.selectionStyle = .none
        if let offset = rowsOffset[indexPath.row] {
            cell.collectionView.contentOffset = CGPoint(x: offset, y: 0)
        } else {
            cell.collectionView.contentOffset = CGPoint.zero
        }

        if let viewModel = viewModel as? ProfileBucketsViewModel {
            let cellData = viewModel.bucketTableViewCellViewData(indexPath)
            cell.titleLabel.text = cellData.name
            cell.backgroundLabel.text = cellData.name
            cell.counterLabel.text = cellData.numberOfShots
            cell.shots = cellData.shots
        }

        if let viewModel = viewModel as? ProfileProjectsViewModel {
            let cellData = viewModel.projectTableViewCellViewData(indexPath)
            cell.titleLabel.text = cellData.name
            cell.backgroundLabel.text = cellData.name
            cell.counterLabel.text = cellData.numberOfShots
            cell.shots = cellData.shots
        }

        if (!cell.isRegisteredTo3DTouch) {
            cell.isRegisteredTo3DTouch = registerTo3DTouch(cell)
        }

        return cell
    }

    func adjustTableView() {
        if viewModel.itemsCount == 0 {
            tableView.updateInsets(bottom: tableView.frame.height)
        } else {
            if tableView.contentSize.height < tableView.frame.height {
                tableView.updateInsets(bottom: tableView.frame.height - tableView.contentSize.height)
            } else {
                tableView.updateInsets(bottom: 0)
            }
        }
        if let offset = scrollContentOffset?() {
            tableView.contentOffset = offset
        }
    }
}

// MARK: BaseCollectionViewViewModelDelegate

extension ProfileProjectsOrBucketsViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        tableView?.reloadData()

        Async.main(after: 0.01) {
            self.adjustTableView()
        }
    }

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        tableView?.reloadData()

        Async.main(after: 0.01) {
            if let offset = self.scrollContentOffset?() {
                self.tableView?.contentOffset = offset
            }
        }
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

extension ProfileProjectsOrBucketsViewController: UIViewControllerPreviewingDelegate {

    fileprivate func peekPopPresent(viewController: UIViewController) {
        guard let detailsViewController = viewController as? ShotDetailsViewController else { return }

        detailsViewController.customizeFor3DTouch(false)
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: currentContainer, initialViewController: detailsViewController)
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
            let carouselCell = tableView.cellForRow(at: tableIndexPath) as? CarouselCell,
            let collectionIndexPath = carouselCell.collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: carouselCell.collectionView)),
            let cell = carouselCell.collectionView.cellForItem(at: collectionIndexPath)
        else {
            return nil
        }

        if let viewModel = viewModel as? ProfileBucketsViewModel {
            guard
                let bucket = viewModel.bucketsIndexedShots[tableIndexPath.row],
                bucket.count > collectionIndexPath.item
            else {
                return nil
            }
            currentContainer = bucket
        } else if let viewModel = viewModel as? ProfileProjectsViewModel {
            guard
                let project = viewModel.projectsIndexedShots[tableIndexPath.row],
                project.count > collectionIndexPath.item
            else {
                return nil
            }
            currentContainer = project
        }

        let shot = currentContainer[collectionIndexPath.item]
        let viewPoint = carouselCell.convert(cell.frame.origin, from: carouselCell.collectionView)
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

extension ProfileProjectsOrBucketsViewController: PeekPopPreviewingDelegate {

    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let tableIndexPath = tableView.indexPathForRow(at: previewingContext.sourceView.convert(location, to: tableView)),
            let carouselCell = tableView.cellForRow(at: tableIndexPath) as? CarouselCell,
            let collectionIndexPath = carouselCell.collectionView.indexPathForItem(at: previewingContext.sourceView.convert(location, to: carouselCell.collectionView)),
            let cell = carouselCell.collectionView.cellForItem(at: collectionIndexPath)
        else {
            return nil
        }

        if let viewModel = viewModel as? ProfileBucketsViewModel {
            guard
                let bucket = viewModel.bucketsIndexedShots[tableIndexPath.row],
                bucket.count > collectionIndexPath.item
            else {
                return nil
            }
            currentContainer = bucket
        } else if let viewModel = viewModel as? ProfileProjectsViewModel {
            guard
                let project = viewModel.projectsIndexedShots[tableIndexPath.row],
                project.count > collectionIndexPath.item
            else {
                return nil
            }
            currentContainer = project
        }

        let shot = currentContainer[collectionIndexPath.item]
        let sourceCellOrigin = carouselCell.collectionView.convert(cell.frame.origin, to: tableView)
        let sourceFrame = CGRect(origin: sourceCellOrigin, size: cell.frame.size)
        previewingContext.sourceRect = sourceFrame

        let controller = ShotDetailsViewController(shot: shot)
        controller.customizeFor3DTouch(true)
        controller.shotIndex = collectionIndexPath.item

        return controller
    }

    func previewingContext(_ previewingContext: PreviewingContext, commit viewControllerToCommit: UIViewController) {
        peekPopPresent(viewController: viewControllerToCommit)
    }
}
