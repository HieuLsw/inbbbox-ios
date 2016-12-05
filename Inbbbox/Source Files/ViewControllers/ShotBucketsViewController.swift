//
//  ShotBucketsViewController.swift
//  Inbbbox
//
//  Created by Peter Bruz on 24/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import TTTAttributedLabel
import ImageViewer
import DZNEmptyDataSet

enum ShotBucketsViewControllerMode {
    case AddToBucket
    case RemoveFromBucket
}

class ShotBucketsViewController: UIViewController {

    var shotBucketsView: ShotBucketsView! {
        return view as? ShotBucketsView
    }

    var willDismissViewControllerClosure: (() -> Void)?
    var didDismissViewControllerClosure: (() -> Void)?
    var alertView: UIAlertController?

    private var header: ShotBucketsHeaderView?
    private var footer: ShotBucketsFooterView?
    private let viewModel: ShotBucketsViewModel

    init(shot: ShotType, mode: ShotBucketsViewControllerMode) {
        viewModel = ShotBucketsViewModel(shot: shot, mode: mode)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message="Use init(shot:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable, message="Use init(shot:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = loadViewWithClass(ShotBucketsView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        shotBucketsView.collectionView.emptyDataSetSource = self

        firstly {
            viewModel.loadBuckets()
        }.then {
            self.shotBucketsView.collectionView.reloadData()
        }.then {
            self.setEstimatedSizeIfNeeded()
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
        shotBucketsView.viewController = self
        shotBucketsView.collectionView.delegate = self
        shotBucketsView.collectionView.dataSource = self
        shotBucketsView.collectionView.registerClass(ShotBucketsAddCollectionViewCell.self, type: .Cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsSelectCollectionViewCell.self, type: .Cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsActionCollectionViewCell.self, type: .Cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsSeparatorCollectionViewCell.self, type: .Cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsHeaderView.self, type: .Header)
        shotBucketsView.collectionView.registerClass(ShotBucketsFooterView.self, type: .Footer)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.trackScreen(.ShotBucketsView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        (shotBucketsView.collectionView.collectionViewLayout as?
                ShotDetailsCollectionCollapsableHeader)?.collapsableHeight =
                heightForCollapsedCollectionViewHeader
    }

    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {

        header?.imageView.startAnimating()
        super.dismissViewControllerAnimated(flag) {
            self.didDismissViewControllerClosure?()
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return ColorModeProvider.current().preferredStatusBarStyle
    }
}

// MARK: UICollectionViewDataSource
extension ShotBucketsViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if viewModel.isSeparatorAtIndex(indexPath.item) {
            return configureSeparatorCell(collectionView, atIndexPath: indexPath)
        }

        switch viewModel.shotBucketsViewControllerMode {
        case .AddToBucket:
            if viewModel.isActionItemAtIndex(indexPath.item) {
                return configureActionCell(collectionView, atIndexPath: indexPath,
                        selector: #selector(addNewBucketButtonDidTap(_:)))
            } else {
                return configureAddToBucketCell(collectionView, atIndexPath: indexPath)
            }
        case .RemoveFromBucket:
            if viewModel.isActionItemAtIndex(indexPath.item) {
                return configureActionCell(collectionView, atIndexPath: indexPath,
                        selector: #selector(removeButtonDidTap(_:)))
            } else {
                return configureRemoveFromBucketCell(collectionView, atIndexPath: indexPath)
            }
        }
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            if header == nil && kind == UICollectionElementKindSectionHeader {
                header = collectionView.dequeueReusableClass(ShotBucketsHeaderView.self, forIndexPath: indexPath,
                        type: .Header)
                if viewModel.shot.animated {
                    if let url = viewModel.shot.shotImage.hidpiURL {
                        header?.setAnimatedImageWithUrl(url)
                    } else {
                        header?.setAnimatedImageWithUrl(viewModel.shot.shotImage.normalURL)
                    }
                } else {
                    header?.setImageWithShotImage(viewModel.shot.shotImage)
                }
                header?.maxHeight = sizeForExpandedCollectionViewHeader(collectionView).height
                header?.minHeight = heightForCollapsedCollectionViewHeader

                header?.setAttributedTitle(viewModel.attributedShotTitleForHeader)
                header?.setHeaderTitle(viewModel.titleForHeader)
                header?.avatarView.imageView.loadImageFromURL(viewModel.shot.user.avatarURL)
                header?.avatarView.delegate = self
                header?.closeButtonView.closeButton.addTarget(self, action: #selector(closeButtonDidTap(_:)),
                forControlEvents: .TouchUpInside)
                if let url = viewModel.urlForUser(viewModel.shot.user) {
                    header?.setLinkInTitle(url, range: viewModel.userLinkRange, delegate: self)
                }
                if let team = viewModel.shot.team, url = viewModel.urlForTeam(team) {
                    header?.setLinkInTitle(url, range: viewModel.teamLinkRange, delegate: self)
                }
                header?.imageDidTap = { [weak self] in
                    self?.presentShotFullscreen()
                }
            }
            return header!
        } else {
            if footer == nil {
                footer = collectionView.dequeueReusableClass(ShotBucketsFooterView.self, forIndexPath: indexPath,
                        type: .Footer)
            }
            return footer!
        }
    }
}

// MARK: UICollectionViewDelegate
extension ShotBucketsViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShotBucketsSelectCollectionViewCell {
            cell.selectBucket(viewModel.selectBucketAtIndex(indexPath.item))
            setRemoveFromSelectedBucketsButtonActive(viewModel.selectedBucketsIndexes.count > 0)
        } else if let _ = collectionView.cellForItemAtIndexPath(indexPath) as? ShotBucketsAddCollectionViewCell {
            addShotToBucketAtIndex(indexPath.item)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ShotBucketsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sizeForExpandedCollectionViewHeader(collectionView)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: floor(collectionView.bounds.width), height: 20)
    }
}

// MARK: Actions
extension ShotBucketsViewController {

    func closeButtonDidTap(_: UIButton) {
        self.willDismissViewControllerClosure?()
        dismissViewControllerAnimated(true, completion: nil)
    }

    func removeButtonDidTap(_: UIButton) {
        firstly {
            viewModel.removeShotFromSelectedBuckets()
        }.then { () -> Void in
            self.willDismissViewControllerClosure?()
            self.dismissViewControllerAnimated(true, completion: nil)
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketProcessingFailed, canBeDismissedByUser: true)
        }
    }

    func addNewBucketButtonDidTap(_: UIButton) {

        let alert = AlertViewController.provideBucketName { bucketName in
            self.createBucketAndAddShot(bucketName)
        }
        alert.show()
        
    }

    func setRemoveFromSelectedBucketsButtonActive(active: Bool) {
        let removeCellIndexPath =  NSIndexPath(forItem: viewModel.indexForRemoveFromSelectedBucketsActionItem(),
                inSection: 0)
        if let cell = shotBucketsView.collectionView.cellForItemAtIndexPath(removeCellIndexPath)
                as? ShotBucketsActionCollectionViewCell {
            cell.button.enabled = active
        }
    }
}

private extension ShotBucketsViewController {

    func presentProfileViewControllerForUser(user: UserType) {

        let profileViewController = ProfileViewController(user: user)
        let navigationController = UINavigationController(rootViewController: profileViewController)

        animateHeader(start: false)
        profileViewController.dismissClosure = { [weak self] in
            self?.animateHeader(start: true)
        }
        presentViewController(navigationController, animated: true, completion: nil)
    }

    func presentShotFullscreen() {

        guard let header = header else { return }

        var imageViewer: ImageViewer {
            if viewModel.shot.animated {
                let url = viewModel.shot.shotImage.hidpiURL ?? viewModel.shot.shotImage.normalURL
                return ImageViewer(imageProvider: self, displacedView: header.imageView, animatedUrl: url)
            } else {
                return ImageViewer(imageProvider: self, displacedView: header.imageView)
            }
        }

        presentImageViewer(imageViewer)
    }

    func animateHeader(start start: Bool) {
        start ? header?.imageView.startAnimating() : header?.imageView.stopAnimating()
    }

    var heightForCollapsedCollectionViewHeader: CGFloat {

        let margin = CGFloat(5)
        let maxWidth = abs((shotBucketsView.collectionView.frame.size.width ?? 0) -
                (header?.availableWidthForTitle ?? 0))
        let height = viewModel.attributedShotTitleForHeader.boundingHeightUsingAvailableWidth(maxWidth) + 2 * margin

        return max(70, height)
    }

    func sizeForExpandedCollectionViewHeader(collectionView: UICollectionView) -> CGSize {
        let dribbbleImageRatio = CGFloat(0.75)
        return CGSize(
            width: floor(collectionView.bounds.width),
            height: ceil(collectionView.bounds.width * dribbbleImageRatio + heightForCollapsedCollectionViewHeader)
        )
    }

    func setEstimatedSizeIfNeeded() {

        let width = shotBucketsView.collectionView.frame.size.width ?? 0

        if let layout = shotBucketsView.collectionView.collectionViewLayout as?
            UICollectionViewFlowLayout where layout.estimatedItemSize.width != width {
            layout.estimatedItemSize = CGSize(width: width, height: 40)
            layout.invalidateLayout()
        }
    }

    func addShotToBucketAtIndex(index: Int) {
        firstly {
            viewModel.addShotToBucketAtIndex(index)
        }.then { () -> Void in
            self.willDismissViewControllerClosure?()
            self.dismissViewControllerAnimated(true, completion: nil)
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketProcessingFailed, canBeDismissedByUser: true)
        }
    }

    func createBucketAndAddShot(bucketName: String) {
        firstly {
            viewModel.createBucket(bucketName)
        }.then { () -> Void in
            self.addShotToBucketAtIndex(self.viewModel.buckets.count-1)
        }.error { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketCreationFailed, canBeDismissedByUser: true)
        }
    }
}

// MARK: Configuration of cells

extension ShotBucketsViewController {

    func configureSeparatorCell(collectionView: UICollectionView,
                                atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableClass(ShotBucketsSeparatorCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)
    }

    func configureActionCell(collectionView: UICollectionView, atIndexPath indexPath: NSIndexPath,
                             selector: Selector) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotBucketsActionCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)
        cell.button.setTitle(viewModel.titleForActionItem, forState: .Normal)
        cell.button.addTarget(self, action: selector, forControlEvents: .TouchUpInside)
        cell.button.enabled = viewModel.shotBucketsViewControllerMode == .AddToBucket
        return cell
    }

    func configureAddToBucketCell(collectionView: UICollectionView,
                                  atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotBucketsAddCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)

        let bucketData = viewModel.displayableDataForBucketAtIndex(indexPath.item)
        cell.bucketNameLabel.text = bucketData.bucketName
        cell.shotsCountLabel.text = bucketData.shotsCountText
        cell.showBottomSeparator(viewModel.showBottomSeparatorForBucketAtIndex(indexPath.item))
        return cell
    }

    func configureRemoveFromBucketCell(collectionView: UICollectionView,
                                       atIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotBucketsSelectCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)

        let bucketData = viewModel.displayableDataForBucketAtIndex(indexPath.item)
        cell.bucketNameLabel.text = bucketData.bucketName
        cell.selectBucket(viewModel.bucketShouldBeSelectedAtIndex(indexPath.item))
        cell.showBottomSeparator(viewModel.showBottomSeparatorForBucketAtIndex(indexPath.item))
        return cell
    }
}

extension ShotBucketsViewController: ModalByDraggingClosable {
    var scrollViewToObserve: UIScrollView {
        return shotBucketsView.collectionView
    }
}

extension ShotBucketsViewController: AvatarViewDelegate {

    func avatarView(avatarView: AvatarView, didTapButton avatarButton: UIButton) {
        if avatarView.superview == header {
            let user = viewModel.shot.user
            presentProfileViewControllerForUser(user)
        }
    }
}

extension ShotBucketsViewController: TTTAttributedLabelDelegate {

    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if let user = viewModel.userForURL(url) {
            presentProfileViewControllerForUser(user)
        } else {
            firstly {
                viewModel.userForId(url.absoluteString)
            }.then { [weak self] user in
                self?.presentProfileViewControllerForUser(user)
            }
        }
    }
}

extension ShotBucketsViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        animateHeader(start: false)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            animateHeader(start: true)
        }
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        animateHeader(start: true)
    }
}

extension ShotBucketsViewController: ImageProvider {

    func provideImage(completion: UIImage? -> Void) {
        if !viewModel.shot.animated {
            if let image = header?.imageView.image {
                completion(image)
            }
        }
    }

    func provideImage(atIndex index: Int, completion: UIImage? -> Void) { /* empty by design */ }
}

extension ShotBucketsViewController: DZNEmptyDataSetSource {

    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        return UIView.newAutoLayoutView()
    }
}
