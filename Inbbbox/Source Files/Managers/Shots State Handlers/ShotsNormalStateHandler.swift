//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import ZFDragableModalTransition

class ShotsNormalStateHandler: NSObject, ShotsStateHandler, Vibratable {

    let shotsRequester =  ShotsRequester()
    let likesProvider = ShotsProvider()
    var modalTransitionAnimator: ZFModalTransitionAnimator?
    var likedShots = [ShotType]()

    weak var shotsCollectionViewController: ShotsCollectionViewController?
    weak var delegate: ShotsStateHandlerDelegate?

    var state: ShotsCollectionViewController.State {
        return .normal
    }

    var nextState: ShotsCollectionViewController.State? {
        return nil
    }

    var tabBarInteractionEnabled: Bool {
        return true
    }

    var tabBarAlpha: CGFloat {
        return 1.0
    }

    var collectionViewLayout: UICollectionViewLayout = ShotsCollectionViewFlowLayout()

    var collectionViewInteractionEnabled: Bool {
        return true
    }

    var collectionViewScrollEnabled: Bool {
        return true
    }
    
    var shouldShowNoShotsView: Bool {
        return shotsCollectionViewController?.shots.count == 0 && Settings.areAllStreamSourcesOff()
    }

    var didLikeShotCompletionHandler: (() -> Void)?
    var didAddShotToBucketCompletionHandler: (() -> Void)?
    var willDismissDetailsCompletionHandler: ((Int) -> Void)?

    fileprivate var indexPathsNeededImageUpdate = [UpdateableIndex]()
    fileprivate let connectionsRequester = APIConnectionsRequester()

    func prepareForPresentingData() {
        if !UserStorage.isUserSignedIn {
            updateAuthorData()
            return
        }

        firstly {
            fetchLikedShots()
        }.then { () -> Void in
            self.updateLikeImage()
        }.then { () -> Void  in
            self.updateAuthorData()
        }.catch { error in
            self.delegate?.shotsStateHandlerDidFailToFetchItems(error)
        }
    }

    func presentData() {
        self.reloadFirstCell()
    }
}

// MARK: UICollecitonViewDataSource
extension ShotsNormalStateHandler {
    func collectionView(_ collectionView: UICollectionView,
            numberOfItemsInSection section: Int) -> Int {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return 0
        }
        return shotsCollectionViewController.shots.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt
            indexPath: IndexPath) -> UICollectionViewCell {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return UICollectionViewCell()
        }

        let cell: ShotCollectionViewCell =  collectionView.dequeueReusableClass(ShotCollectionViewCell.self,
                                                                                forIndexPath: indexPath,
                                                                                type: .cell)

        let shot = shotsCollectionViewController.shots[indexPath.item]

        cell.shotImageView.activityIndicatorView.startAnimating()
        cell.shotImageView.backgroundColor = ColorModeProvider.current().shotViewCellBackground

        load(shot.shotImage, for: indexPath)

        cell.gifLabel.isHidden = !shot.animated
        cell.liked = self.isShotLiked(shot)

        if let user = shot.user.name, let url = shot.user.avatarURL {
            let likes = shot.likesCount, comments = shot.commentsCount
            cell.authorView.viewData = ShotAuthorCompactView
                .ViewData(author: user,
                          avatarURL: url,
                          liked: cell.liked,
                          likesCount: likes,
                          commentsCount: comments)
        }

        cell.delegate = self
        cell.swipeCompletion = { [weak self] action in

            guard let certainSelf = self else { return }

            switch action {
            case .like:
                firstly {
                    certainSelf.likeShot(shot, at: indexPath.row)
                }.then {
                    cell.liked = true
                }.then {
                    self?.didLikeShotCompletionHandler?()
                }.catch { error in
                    cell.liked = false
                }
            case .bucket:
                firstly {
                    certainSelf.likeShot(shot, at: indexPath.row)
                }.then {
                    cell.liked = true
                }.catch { error in
                    cell.liked = false
                }
                certainSelf.presentShotBucketsViewController(shot)
            case .comment:
                let shotUpdated = self?.shotDummyRecent(shot)
                certainSelf.presentShotDetailsViewController(shotUpdated ?? shot, index: indexPath.item, scrollToMessages: true, focusOnInput: true)
            case .follow:
                firstly {
                    certainSelf.followAuthorOfShot(shot)
                }.catch { _ in }
            case .doNothing:
                break
            }
        }
        return cell
    }
}

// MARK: UICollectionViewDataSourcePrefetching
extension ShotsNormalStateHandler: UICollectionViewDataSourcePrefetching {
    
    @available(iOS 10.0, *)
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }
        
        indexPaths.forEach {
            let shot = shotsCollectionViewController.shots[$0.item]
            load(shot.shotImage, for: $0 as IndexPath)
        }
    }
    
    @available(iOS 10.0, *)
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPathsNeededImageUpdate.removeAll()
    }
}

// MARK: UICollectionViewDelegate
extension ShotsNormalStateHandler {

    func collectionView(_ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }

        let shot = shotsCollectionViewController.shots[indexPath.item]
        let shotUpdated = self.shotDummyRecent(shot)
        shotsCollectionViewController.modalPresentationStyle = .overFullScreen
        presentShotDetailsViewController(shotUpdated, index: indexPath.item, scrollToMessages: false)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ShotCollectionViewCell {
            cell.displayAuthor(Settings.Customization.ShowAuthor, animated: true)

            if let shotsCollectionViewController = shotsCollectionViewController {
                let shot = shotsCollectionViewController.shots[indexPath.item]
                load(shot.shotImage, for: indexPath)
            }
        }

        downloadNextPageIfNeeded(for: indexPath)
    }

}

// MARK: UIScrollViewDelegate
extension ShotsNormalStateHandler {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
            AnalyticsManager.trackUserActionEvent(.swipeDown)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = shotsCollectionViewController?.collectionView else { return }

        let blur = min(scrollView.contentOffset.y.truncatingRemainder(dividingBy: scrollView.bounds.height),
                scrollView.bounds.height - scrollView.contentOffset.y.truncatingRemainder(dividingBy: scrollView.bounds.height)) / (scrollView.bounds.height / 2)

        for cell in collectionView.visibleCells {
            if let shotCell = cell as? ShotCollectionViewCell {
                if !DeviceInfo.shouldDowngrade() {
                    shotCell.shotImageView.applyBlur(blur)
                }
            }
        }
    }
}

// MARK: ShotCollectionViewCellDelegate

extension ShotsNormalStateHandler: ShotCollectionViewCellDelegate {

    func shotCollectionViewCellDidStartSwiping(_: ShotCollectionViewCell) {
        shotsCollectionViewController?.collectionView?.isScrollEnabled = false
        shotsCollectionViewController?.collectionView?.allowsSelection = false
    }

    func shotCollectionViewCellDidEndSwiping(_: ShotCollectionViewCell) {
        shotsCollectionViewController?.collectionView?.isScrollEnabled = true
        shotsCollectionViewController?.collectionView?.allowsSelection = true
    }
}

// MARK: 3DTouch

extension ShotsNormalStateHandler {
    
    func getShotDetailsViewController(atIndexPath indexPath: IndexPath) -> UIViewController? {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return nil }
        
        let shot = shotsCollectionViewController.shots[indexPath.item]
        let shotDetailsViewController = ShotDetailsViewController(shot: shot)
        shotDetailsViewController.customizeFor3DTouch(true)
        shotDetailsViewController.shotIndex = indexPath.item
        
        return shotDetailsViewController
    }
    
    func popViewController(_ controller: UIViewController) {
        guard let detailsViewController = controller as? ShotDetailsViewController,
            let shotsCollectionViewController = shotsCollectionViewController else { return }
        
        detailsViewController.customizeFor3DTouch(false)
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: shotsCollectionViewController.shots, initialViewController: detailsViewController)
        shotDetailsPageDataSource.delegate = self
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
        modalTransitionAnimator?.behindViewScale = 1
        
        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .custom
        
        shotsCollectionViewController.tabBarController?.present(pageViewController, animated: true, completion: nil)
    }
}

// MARK: Private methods
private extension ShotsNormalStateHandler {

    func presentShotBucketsViewController(_ shot: ShotType) {
        let shotBucketsViewController = ShotBucketsViewController(shot: shot, mode: .addToBucket)
        shotBucketsViewController.didDismissViewControllerClosure = { [weak self] in
            self?.didAddShotToBucketCompletionHandler?()
        }
        
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(shotBucketsViewController)

        shotBucketsViewController.transitioningDelegate = modalTransitionAnimator
        shotBucketsViewController.modalPresentationStyle = .custom
        shotsCollectionViewController?.tabBarController?.present(
                shotBucketsViewController, animated: true, completion: nil)
    }

    func presentShotDetailsViewController(_ shot: ShotType, index: Int, scrollToMessages: Bool, focusOnInput: Bool = false) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }
        
        shotsCollectionViewController.definesPresentationContext = true
        
        let detailsViewController = ShotDetailsViewController(shot: shot)
        detailsViewController.shotIndex = index
        detailsViewController.updatedShotInfo = { [weak self] shot in
                self?.shotsCollectionViewController?.shots[index] = shot
        }
        detailsViewController.shouldShowKeyboardAtStart = focusOnInput
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: shotsCollectionViewController.shots, initialViewController: detailsViewController)
        shotDetailsPageDataSource.delegate = self
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
        
        modalTransitionAnimator =
            CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
        
        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .custom
        shotsCollectionViewController.tabBarController?.modalPresentationStyle = .overCurrentContext
        shotsCollectionViewController.tabBarController?.present(
            pageViewController, animated: true, completion: nil)
    }

    func isShotLiked(_ shot: ShotType) -> Bool {
        return likedShots.contains { $0.identifier == shot.identifier }
    }
    
    // shot with most recent likes/buckets count
    func shotDummyRecent(_ shot: ShotType) -> ShotType {
        let likedShot = likedShots.filter{ $0.identifier == shot.identifier }
        
        return likedShot.first ?? shot
    }

    func likeShot(_ shot: ShotType, at index: Int) -> Promise<Void> {
        if isShotLiked(shot) {
            return Promise<Void> { fulfill, _ in
                fulfill()
            }
        }

        return Promise() { fulfill, reject in
            firstly {
                shotsRequester.likeshot(shot)
            }.then { likedShotTuple in
                return self.shotsRequester.fetchShotDetails(shot).then{ ($0, likedShotTuple) }
            }.then { (shotDetails, likeDetails) -> Void in

                if let updatedShot = shotDetails as? Shot {
                    let likedShot = LikedShot(likeIdentifier: likeDetails.likeIdentifier, createdAt: likeDetails.createdAt, shot: updatedShot)

                    SharedCache.likedShots.append(likedShot)
                }
                _ = self.updateShots(with: shotDetails, at: index)
            }.then {
                self.fetchLikedShots()
            }.then { () -> Void in
                self.updateAuthorData()
                fulfill()
            }.catch { error in
                reject(error)
            }
        }
    }

    func updateShots(with shot: ShotType, at index: Int) -> Promise<Void> {
        shotsCollectionViewController?.shots[index] = shot
        return Promise(value: Void())
    }

    func fetchLikedShots() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            firstly {
                likesProvider.provideMyLikedShots()
            }.then { shots -> Void in
                if let shots = shots {
                    self.likedShots = shots.map { $0.shot }
                }
            }.then(execute: fulfill).catch(execute: reject)
        }
    }

    func updateLikeImage() {

        let visibleShot = self.visibleShot()
        let visibleCell = self.visibleCell()

        if let shot = visibleShot, let cell = visibleCell {
            cell.liked = isShotLiked(shot)
        }
    }

    func updateAuthorData() {

        let visibleShot = self.visibleShot()
        let visibleCell = self.visibleCell()

        if let cell = visibleCell, var shot = visibleShot {
            cell.displayAuthor(Settings.Customization.ShowAuthor, animated: true)
            cell.liked = self.isShotLiked(shot)

            if cell.liked {
                shot = likedShots.filter({ $0.identifier == shot.identifier }).first ?? shot
            }

            if let user = shot.user.name, let url = shot.user.avatarURL {
                let likes = shot.likesCount, comments = shot.commentsCount
                cell.authorView.viewData = ShotAuthorCompactView
                    .ViewData(author: user,
                              avatarURL: url,
                              liked: cell.liked,
                              likesCount: likes,
                              commentsCount: comments)
            }
        }
    }
    
    func reloadFirstCell() {
        guard let collectionView = collectionViewLayout.collectionView, shotsCollectionViewController?.shots.count != 0 else {
            return
        }

        collectionView.reloadData()
    }

    func visibleShot() -> ShotType? {
        guard let
            viewController = shotsCollectionViewController,
            let collectionView = viewController.collectionView else {
                return nil
        }

        return collectionView.indexPathsForVisibleItems.map { return viewController.shots[$0.item] }.first
    }

    func visibleCell() -> ShotCollectionViewCell? {
        guard let
            viewController = shotsCollectionViewController,
            let collectionView = viewController.collectionView else {
                return nil
        }

        return collectionView.visibleCells.first as? ShotCollectionViewCell
    }

    func load(_ image: ShotImageType, for indexPath: IndexPath) {
        lazyLoadImage(image, for: indexPath)
    }

    func downloadNextPageIfNeeded(for indexPath: IndexPath) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }

        if indexPath.item == shotsCollectionViewController.shots.count - 6 {

            firstly {
                shotsCollectionViewController.shotsProvider.nextPage()
                }.then { [weak self] shots -> Void in
                    if let shots = shots, let shotsCollectionViewController = self?.shotsCollectionViewController {
                        shotsCollectionViewController.shots.append(contentsOf: shots)
                        shotsCollectionViewController.collectionView?.reloadData()
                    }
                }.catch { error in
                    self.delegate?.shotsStateHandlerDidFailToFetchItems(error)
            }
        }
    }
    
    func followAuthorOfShot(_ shot: ShotType) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            
            firstly {
                connectionsRequester.followUser(shot.user)
            }.then {
                self.vibrate(feedbackType: .success)
            }.then(execute: fulfill).catch(execute: reject)
        }
    }
}

// MARK: Lazy loading of image

private extension ShotsNormalStateHandler {

    /// Returns UpdateableIndex object that matches given NSIndexPath (if any)
    /// - parameter indexPath: indexPath to match.
    /// - returns: Matched UpdateableIndexes object.
    func updateableIndexPath(for indexPath: IndexPath) -> UpdateableIndex? {
        let toCompare = indexPath.item
        return indexPathsNeededImageUpdate.filter { $0.index == toCompare }.first
    }

    func lazyLoadImage(_ shotImage: ShotImageType, for indexPath: IndexPath) {
        let teaserImageLoadingCompletion: (UIImage) -> Void = { [weak self] image in
            guard let certainSelf = self else { return }
            guard let _ = certainSelf.updateableIndexPath(for: indexPath) else { return }

            if let collectionView = certainSelf.shotsCollectionViewController?.collectionView {
                if let cell = collectionView.cellForItem(at: indexPath) as? ShotCollectionViewCell {
                    cell.shotImageView.activityIndicatorView.stopAnimating()
                    cell.shotImageView.originalImage = image
                    cell.shotImageView.image = image
                }
            }
        }
        let imageLoadingCompletion: (UIImage) -> Void = { [weak self] image in
            guard let certainSelf = self else {return}
            guard var indexPathToUpdate = certainSelf.updateableIndexPath(for: indexPath) else { return }

            if let index = certainSelf.indexPathsNeededImageUpdate.index(where: {$0 == indexPathToUpdate}) {
                indexPathToUpdate.status = .updated
                certainSelf.indexPathsNeededImageUpdate[index] = indexPathToUpdate
            }

            if let collectionView = certainSelf.shotsCollectionViewController?.collectionView {
                if let cell = collectionView.cellForItem(at: indexPath) as? ShotCollectionViewCell {
                    cell.shotImageView.activityIndicatorView.stopAnimating()
                    cell.shotImageView.originalImage = image
                    cell.shotImageView.image = image
                }
            }
        }

        if let indexPathToUpdate = updateableIndexPath(for: indexPath), indexPathToUpdate.status == .inProgress {
            return
        } else {
            indexPathsNeededImageUpdate.append(UpdateableIndex(index: indexPath.item, status: .inProgress))
        }

        LazyImageProvider.lazyLoadImageFromURLs(
            (shotImage.teaserURL, shotImage.normalURL, nil),
            teaserImageCompletion: teaserImageLoadingCompletion,
            normalImageCompletion: imageLoadingCompletion
        )
    }
}

// MARK: ShotDetailsPageDelegate

extension ShotsNormalStateHandler: ShotDetailsPageDelegate {
    
    func shotDetailsDismissed(atIndex index: Int) {
        willDismissDetailsCompletionHandler?(index)
    }
}
