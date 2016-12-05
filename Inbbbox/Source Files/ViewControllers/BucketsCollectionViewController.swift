//
//  BucketsCollectionViewController.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 22.01.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import DZNEmptyDataSet

class BucketsCollectionViewController: UICollectionViewController {

    private let viewModel = BucketsViewModel()
    private var shouldShowLoadingView = true

    private var cellsAnimateTimer: NSTimer?
    private let animationCycleInterval = 6.0

    private var currentColorMode = ColorModeProvider.current()
    // MARK: - Lifecycle

    convenience init() {
        let flowLayout = TwoColumnsCollectionViewFlowLayout()
        flowLayout.itemHeightToWidthRatio = BucketCollectionViewCell.heightToWidthRatio
        self.init(collectionViewLayout: flowLayout)
        navigationItem.title = viewModel.title
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtons()
        guard let collectionView = collectionView else {
            return
        }
        collectionView.registerClass(BucketCollectionViewCell.self, type: .Cell)
        collectionView.emptyDataSetSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.clearViewModelIfNeeded()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.downloadInitialItems()
        AnalyticsManager.trackScreen(.BucketsView)
        
        cellsAnimateTimer = NSTimer.scheduledTimerWithTimeInterval(animationCycleInterval, target: self, selector: #selector(BucketsCollectionViewController.makeRandomRotation), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        cellsAnimateTimer?.invalidate()
        cellsAnimateTimer = nil
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView,
                    numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath
                    indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(BucketCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)
        cell.clearImages()
        let cellData = viewModel.bucketCollectionViewCellViewData(indexPath)
        cell.nameLabel.text = cellData.name
        cell.numberOfShotsLabel.text = cellData.numberOfShots
        if let shotImagesURLs = cellData.shotsImagesURLs {
            cell.firstShotImageView.loadImageFromURL(shotImagesURLs[0])
            cell.secondShotImageView.loadImageFromURL(shotImagesURLs[1])
            cell.thirdShotImageView.loadImageFromURL(shotImagesURLs[2])
            cell.fourthShotImageView.loadImageFromURL(shotImagesURLs[3])
        }
        if !cell.isRegisteredTo3DTouch {
            cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
        }
        cell.adaptColorMode(currentColorMode)
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView,
                           willDisplayCell cell: UICollectionViewCell,
                   forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func collectionView(collectionView: UICollectionView,
             didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let bucketContentCollectionViewController =
                SimpleShotsCollectionViewController(bucket: viewModel.buckets[indexPath.row])
        navigationController?.pushViewController(bucketContentCollectionViewController,
                animated: true)
    }

    // MARK: Configuration

    func setupBarButtons() {
        navigationItem.rightBarButtonItem =
                UIBarButtonItem(title: NSLocalizedString("BucketsCollectionView.AddNew",
                comment: "Button for adding new bucket"), style: .Plain,
                target: self, action: #selector(didTapAddNewBucketButton(_:)))
    }

    // MARK: Actions:

    func didTapAddNewBucketButton(_: UIBarButtonItem) {
        let alert = UIAlertController.provideBucketName { bucketName in

            firstly {
                self.viewModel.createBucket(bucketName)
            }.then { () -> Void in
                if self.viewModel.buckets.count == 1 {
                    self.collectionView?.reloadData()
                } else {
                    self.collectionView?.insertItemsAtIndexPaths(
                        [NSIndexPath(forItem: self.viewModel.buckets.count-1, inSection: 0)])
                }
            }.error { error in
                FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketCreationFailed, canBeDismissedByUser: true)
                return
            }
        }
        self.presentViewController(alert, animated: true, completion: nil)
        alert.view.tintColor = .pinkColor()
    }

    func makeRandomRotation() {
        if let visCells = self.collectionView?.visibleCells() where visCells.count > 0 {
            let randomIndex = Int(arc4random_uniform(UInt32(visCells.count)))
            if let randomCell = visCells[randomIndex] as? BucketCollectionViewCell {
                randomCell.makeRotationOnImages()
            }
        }
    }
}

extension BucketsCollectionViewController: BaseCollectionViewViewModelDelegate {

    func viewModelDidLoadInitialItems() {
        shouldShowLoadingView = false
        collectionView?.reloadData()
    }

    func viewModelDidFailToLoadInitialItems(error: ErrorType) {
        self.shouldShowLoadingView = false
        collectionView?.reloadData()

        if viewModel.buckets.isEmpty {
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(error: ErrorType) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }

    func viewModel(viewModel: BaseCollectionViewViewModel,
            didLoadItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        collectionView?.insertItemsAtIndexPaths(indexPaths)
    }

    func viewModel(viewModel: BaseCollectionViewViewModel,
            didLoadShotsForItemAtIndexPath indexPath: NSIndexPath) {
        collectionView?.reloadItemsAtIndexPaths([indexPath])
    }
}

extension BucketsCollectionViewController: DZNEmptyDataSetSource {

    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {

        if shouldShowLoadingView {
            let loadingView = EmptyDataSetLoadingView.newAutoLayoutView()
            loadingView.startAnimating()
            return loadingView
        } else {
            let emptyDataSetView = EmptyDataSetView.newAutoLayoutView()
            emptyDataSetView.setDescriptionText(
                firstLocalizedString:
                NSLocalizedString("BucketsCollectionViewController.EmptyData.FirstLocalizedString",
                        comment: "Displayed when empty data in view"),
                attachmentImage: UIImage(named: currentColorMode.emptyBucketImageName),
                imageOffset: CGPoint(x: 0, y: -4),
                lastLocalizedString: NSLocalizedString("BucketsCollectionViewController.EmptyData.LastLocalizedString",
                    comment: "Displayed when empty data in view")
            )
            return emptyDataSetView
        }
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension BucketsCollectionViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let indexPath = collectionView?.indexPathForItemAtPoint(previewingContext.sourceView.convertPoint(location, toView: collectionView)),
            let cell = collectionView?.cellForItemAtIndexPath(indexPath)
        else { return nil }
        
        previewingContext.sourceRect = cell.contentView.bounds
        
        return SimpleShotsCollectionViewController(bucket: viewModel.buckets[indexPath.item])
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: ColorModeAdaptable

extension BucketsCollectionViewController: ColorModeAdaptable {
    func adaptColorMode(mode: ColorModeType) {
        currentColorMode = mode
        collectionView?.reloadData()
    }
}
