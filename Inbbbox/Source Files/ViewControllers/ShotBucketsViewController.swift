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
    case addToBucket
    case removeFromBucket
}

class ShotBucketsViewController: UIViewController {

    var shotBucketsView: ShotBucketsView! {
        return view as? ShotBucketsView
    }

    var willDismissViewControllerClosure: (() -> Void)?
    var didDismissViewControllerClosure: (() -> Void)?
    var alertView: UIAlertController?

    fileprivate var header: ShotBucketsHeaderView?
    fileprivate var footer: ShotBucketsFooterView?
    fileprivate let viewModel: ShotBucketsViewModel

    init(shot: ShotType, mode: ShotBucketsViewControllerMode) {
        viewModel = ShotBucketsViewModel(shot: shot, mode: mode)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init(shot:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }

    @available(*, unavailable, message: "Use init(shot:) instead")
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
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.tryAgain, canBeDismissedByUser: true)
        }
        shotBucketsView.viewController = self
        shotBucketsView.collectionView.delegate = self
        shotBucketsView.collectionView.dataSource = self
        shotBucketsView.collectionView.registerClass(ShotBucketsAddCollectionViewCell.self, type: .cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsSelectCollectionViewCell.self, type: .cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsActionCollectionViewCell.self, type: .cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsSeparatorCollectionViewCell.self, type: .cell)
        shotBucketsView.collectionView.registerClass(ShotBucketsHeaderView.self, type: .header)
        shotBucketsView.collectionView.registerClass(ShotBucketsFooterView.self, type: .footer)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsManager.trackScreen(.ShotBucketsView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        (shotBucketsView.collectionView.collectionViewLayout as?
                ShotDetailsCollectionCollapsableHeader)?.collapsableHeight =
                heightForCollapsedCollectionViewHeader
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {

        header?.imageView.startAnimating()
        super.dismiss(animated: flag) {
            self.didDismissViewControllerClosure?()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ColorModeProvider.current().preferredStatusBarStyle
    }
}

// MARK: UICollectionViewDataSource
extension ShotBucketsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if viewModel.isSeparatorAtIndex(indexPath.item) {
            return configureSeparatorCell(collectionView, atIndexPath: indexPath)
        }

        switch viewModel.shotBucketsViewControllerMode {
        case .addToBucket:
            if viewModel.isActionItemAtIndex(indexPath.item) {
                return configureActionCell(collectionView, atIndexPath: indexPath,
                        selector: #selector(addNewBucketButtonDidTap(_:)))
            } else {
                return configureAddToBucketCell(collectionView, atIndexPath: indexPath)
            }
        case .removeFromBucket:
            if viewModel.isActionItemAtIndex(indexPath.item) {
                return configureActionCell(collectionView, atIndexPath: indexPath,
                        selector: #selector(removeButtonDidTap(_:)))
            } else {
                return configureRemoveFromBucketCell(collectionView, atIndexPath: indexPath)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            if header == nil && kind == UICollectionElementKindSectionHeader {
                header = collectionView.dequeueReusableClass(ShotBucketsHeaderView.self, forIndexPath: indexPath,
                        type: .header)
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
                for: .touchUpInside)
                if let url = viewModel.urlForUser(viewModel.shot.user) {
                    header?.setLinkInTitle(url, range: viewModel.userLinkRange, delegate: self)
                }
                if let team = viewModel.shot.team, let url = viewModel.urlForTeam(team) {
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
                        type: .footer)
            }
            return footer!
        }
    }
}

// MARK: UICollectionViewDelegate
extension ShotBucketsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ShotBucketsSelectCollectionViewCell {
            cell.selectBucket(viewModel.selectBucketAtIndex(indexPath.item))
            setRemoveFromSelectedBucketsButtonActive(viewModel.selectedBucketsIndexes.count > 0)
        } else if let _ = collectionView.cellForItem(at: indexPath) as? ShotBucketsAddCollectionViewCell {
            addShotToBucketAtIndex(indexPath.item)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ShotBucketsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sizeForExpandedCollectionViewHeader(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: floor(collectionView.bounds.width), height: 20)
    }
}

// MARK: Actions
extension ShotBucketsViewController {

    func closeButtonDidTap(_: UIButton) {
        self.willDismissViewControllerClosure?()
        dismiss(animated: true, completion: nil)
    }

    func removeButtonDidTap(_: UIButton) {
        firstly {
            viewModel.removeShotFromSelectedBuckets()
        }.then { () -> Void in
            self.willDismissViewControllerClosure?()
            self.dismiss(animated: true, completion: nil)
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketProcessingFailed, canBeDismissedByUser: true)
        }
    }

    func addNewBucketButtonDidTap(_: UIButton) {

        let alert = AlertViewController.provideBucketName { bucketName in
            self.createBucketAndAddShot(bucketName)
        }
        alert.show()
        
    }

    func setRemoveFromSelectedBucketsButtonActive(_ active: Bool) {
        let removeCellIndexPath =  IndexPath(item: viewModel.indexForRemoveFromSelectedBucketsActionItem(),
                section: 0)
        if let cell = shotBucketsView.collectionView.cellForItem(at: removeCellIndexPath)
                as? ShotBucketsActionCollectionViewCell {
            cell.button.isEnabled = active
        }
    }
}

private extension ShotBucketsViewController {

    func presentProfileViewControllerForUser(_ user: UserType) {

        let profileViewController = ProfileViewController(user: user)
        let navigationController = UINavigationController(rootViewController: profileViewController)

        animateHeader(start: false)
        profileViewController.dismissClosure = { [weak self] in
            self?.animateHeader(start: true)
        }
        present(navigationController, animated: true, completion: nil)
    }

    func presentShotFullscreen() {

        guard let header = header else { return }
        
        let url = viewModel.shot.shotImage.hidpiURL ?? viewModel.shot.shotImage.normalURL
        if viewModel.shot.animated {
            let galleryProvider = GalleryViewProvider(animatedUrl: url, displacedView: header.imageView)
            presentImageGallery(galleryProvider.galleryViewController)
            
        } else {
            let galleryProvider = GalleryViewProvider(imageUrls: [url], displacedView: header.imageView)
            presentImageGallery(galleryProvider.galleryViewController)
        }
    }

    func animateHeader(start: Bool) {
        start ? header?.imageView.startAnimating() : header?.imageView.stopAnimating()
    }

    var heightForCollapsedCollectionViewHeader: CGFloat {

        let margin = CGFloat(5)
        let maxWidth = abs((shotBucketsView.collectionView.frame.size.width) -
                (header?.availableWidthForTitle ?? 0))
        let height = viewModel.attributedShotTitleForHeader.boundingHeightUsingAvailableWidth(maxWidth) + 2 * margin

        return max(70, height)
    }

    func sizeForExpandedCollectionViewHeader(_ collectionView: UICollectionView) -> CGSize {
        let dribbbleImageRatio = CGFloat(0.75)
        return CGSize(
            width: floor(collectionView.bounds.width),
            height: ceil(collectionView.bounds.width * dribbbleImageRatio + heightForCollapsedCollectionViewHeader)
        )
    }

    func setEstimatedSizeIfNeeded() {

        let width = shotBucketsView.collectionView.frame.size.width ?? 0

        if let layout = shotBucketsView.collectionView.collectionViewLayout as?
            UICollectionViewFlowLayout, layout.estimatedItemSize.width != width {
            layout.estimatedItemSize = CGSize(width: width, height: 40)
            layout.invalidateLayout()
        }
    }

    func addShotToBucketAtIndex(_ index: Int) {
        firstly {
            viewModel.addShotToBucketAtIndex(index)
        }.then { () -> Void in
            self.willDismissViewControllerClosure?()
            self.dismiss(animated: true, completion: nil)
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketProcessingFailed, canBeDismissedByUser: true)
        }
    }

    func createBucketAndAddShot(_ bucketName: String) {
        firstly {
            viewModel.createBucket(bucketName)
        }.then { () -> Void in
            self.addShotToBucketAtIndex(self.viewModel.buckets.count-1)
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.bucketCreationFailed, canBeDismissedByUser: true)
        }
    }
}

// MARK: Configuration of cells

extension ShotBucketsViewController {

    func configureSeparatorCell(_ collectionView: UICollectionView,
                                atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableClass(ShotBucketsSeparatorCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)
    }

    func configureActionCell(_ collectionView: UICollectionView, atIndexPath indexPath: IndexPath,
                             selector: Selector) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotBucketsActionCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)
        cell.button.setTitle(viewModel.titleForActionItem, for: .normal)
        cell.button.addTarget(self, action: selector, for: .touchUpInside)
        cell.button.isEnabled = viewModel.shotBucketsViewControllerMode == .addToBucket
        return cell
    }

    func configureAddToBucketCell(_ collectionView: UICollectionView,
                                  atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotBucketsAddCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)

        let bucketData = viewModel.displayableDataForBucketAtIndex(indexPath.item)
        cell.bucketNameLabel.text = bucketData.bucketName
        cell.shotsCountLabel.text = bucketData.shotsCountText
        cell.showBottomSeparator(viewModel.showBottomSeparatorForBucketAtIndex(indexPath.item))
        return cell
    }

    func configureRemoveFromBucketCell(_ collectionView: UICollectionView,
                                       atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotBucketsSelectCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)

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

    func avatarView(_ avatarView: AvatarView, didTapButton avatarButton: UIButton) {
        if avatarView.superview == header {
            let user = viewModel.shot.user
            presentProfileViewControllerForUser(user)
        }
    }
}

extension ShotBucketsViewController: TTTAttributedLabelDelegate {

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
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

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animateHeader(start: false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            animateHeader(start: true)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateHeader(start: true)
    }
}

extension ShotBucketsViewController: DZNEmptyDataSetSource {

    func customView(forEmptyDataSet scrollView: UIScrollView!) -> UIView! {
        return UIView.newAutoLayout()
    }
}
