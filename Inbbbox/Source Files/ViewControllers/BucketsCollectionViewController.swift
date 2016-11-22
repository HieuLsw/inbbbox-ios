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

    fileprivate let viewModel = BucketsViewModel()
    fileprivate var shouldShowLoadingView = true

    fileprivate var cellsAnimateTimer: Timer?
    fileprivate let animationCycleInterval = 6.0

    fileprivate var currentColorMode = ColorModeProvider.current()
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
        collectionView.registerClass(BucketCollectionViewCell.self, type: .cell)
        collectionView.emptyDataSetSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.clearViewModelIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.downloadInitialItems()
        AnalyticsManager.trackScreen(.BucketsView)
        
        cellsAnimateTimer = Timer.scheduledTimer(timeInterval: animationCycleInterval, target: self, selector: #selector(BucketsCollectionViewController.makeRandomRotation), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cellsAnimateTimer?.invalidate()
        cellsAnimateTimer = nil
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView,
                    numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt
                    indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(BucketCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)
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

    override func collectionView(_ collectionView: UICollectionView,
                           willDisplay cell: UICollectionViewCell,
                   forItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == viewModel.itemsCount - 1 {
            viewModel.downloadItemsForNextPage()
        }
    }

    override func collectionView(_ collectionView: UICollectionView,
             didSelectItemAt indexPath: IndexPath) {
        let bucketContentCollectionViewController =
                SimpleShotsCollectionViewController(bucket: viewModel.buckets[(indexPath as NSIndexPath).row])
        navigationController?.pushViewController(bucketContentCollectionViewController,
                animated: true)
    }

    // MARK: Configuration

    func setupBarButtons() {
        navigationItem.rightBarButtonItem =
                UIBarButtonItem(title: NSLocalizedString("BucketsCollectionView.AddNew",
                comment: "Button for adding new bucket"), style: .plain,
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
                    self.collectionView?.insertItems(
                        at: [IndexPath(item: self.viewModel.buckets.count-1, section: 0)])
                }
            }.catch { error in
                FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketCreationFailed, canBeDismissedByUser: true)
                return
            }
        }
        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = .pinkColor()
    }

    func makeRandomRotation() {
        if let visCells = self.collectionView?.visibleCells, visCells.count > 0 {
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

    func viewModelDidFailToLoadInitialItems(_ error: Error) {
        self.shouldShowLoadingView = false
        collectionView?.reloadData()

        if viewModel.buckets.isEmpty {
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
    }

    func viewModelDidFailToLoadItems(_ error: Error) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel,
            didLoadItemsAtIndexPaths indexPaths: [IndexPath]) {
        collectionView?.insertItems(at: indexPaths)
    }

    func viewModel(_ viewModel: BaseCollectionViewViewModel,
            didLoadShotsForItemAtIndexPath indexPath: IndexPath) {
        collectionView?.reloadItems(at: [indexPath])
    }
}

extension BucketsCollectionViewController: DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {

        if shouldShowLoadingView {
            let loadingView = EmptyDataSetLoadingView.newAutoLayout()
            loadingView.startAnimating()
            return loadingView
        } else {
            let emptyDataSetView = EmptyDataSetView.newAutoLayout()
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let indexPath = collectionView?.indexPathForItem(at: previewingContext.sourceView.convert(location, to: collectionView)),
            let cell = collectionView?.cellForItem(at: indexPath)
        else { return nil }
        
        previewingContext.sourceRect = cell.contentView.bounds
        
        return SimpleShotsCollectionViewController(bucket: viewModel.buckets[(indexPath as NSIndexPath).item])
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: ColorModeAdaptable

extension BucketsCollectionViewController: ColorModeAdaptable {
    func adaptColorMode(_ mode: ColorModeType) {
        currentColorMode = mode
        collectionView?.reloadData()
    }
}
