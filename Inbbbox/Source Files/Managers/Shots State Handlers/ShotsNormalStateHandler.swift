//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import PromiseKit
import ZFDragableModalTransition

class ShotsNormalStateHandler: NSObject, ShotsStateHandler {

    let shotsRequester =  ShotsRequester()
    let likesProvider = APIShotsProvider(page: 1, pagination: 100)
    var modalTransitionAnimator: ZFModalTransitionAnimator?
    var likedShots = [ShotType]()
    private let likesToFetch: UInt = 200

    weak var shotsCollectionViewController: ShotsCollectionViewController?
    weak var delegate: ShotsStateHandlerDelegate?

    var state: ShotsCollectionViewController.State {
        return .Normal
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
    var willDismissDetailsCompletionHandler: (Int -> Void)?

    private var indexPathsNeededImageUpdate = [UpdateableIndex]()
    private let connectionsRequester = APIConnectionsRequester()

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
        }.error { error in
            self.delegate?.shotsStateHandlerDidFailToFetchItems(error)
        }
    }

    func presentData() {
        self.reloadFirstCell()
    }
}

// MARK: UICollecitonViewDataSource
extension ShotsNormalStateHandler {
    func collectionView(collectionView: UICollectionView,
            numberOfItemsInSection section: Int) -> Int {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return 0
        }
        return shotsCollectionViewController.shots.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath
            indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return UICollectionViewCell()
        }

        let cell: ShotCollectionViewCell =  collectionView.dequeueReusableClass(ShotCollectionViewCell.self,
                                                                                forIndexPath: indexPath,
                                                                                type: .Cell)

        let shot = shotsCollectionViewController.shots[indexPath.item]

        cell.shotImageView.activityIndicatorView.startAnimating()
        cell.shotImageView.backgroundColor = ColorModeProvider.current().shotViewCellBackground

        load(shot.shotImage, for: indexPath)

        cell.gifLabel.hidden = !shot.animated
        cell.liked = self.isShotLiked(shot)

        if let user = shot.user.name, url = shot.user.avatarURL {
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
            case .Like:
                firstly {
                    certainSelf.likeShot(shot)
                }.then {
                    cell.liked = true
                }.then {
                    self?.didLikeShotCompletionHandler?()
                }.error { error in
                    cell.liked = false
                }
            case .Bucket:
                firstly {
                    certainSelf.likeShot(shot)
                }.then {
                    cell.liked = true
                }.error { error in
                    cell.liked = false
                }
                certainSelf.presentShotBucketsViewController(shot)
            case .Comment:
                let shotUpdated = self?.shotDummyRecent(shot)
                certainSelf.presentShotDetailsViewController(shotUpdated ?? shot, index: indexPath.item, scrollToMessages: true, focusOnInput: true)
            case .Follow:
                firstly {
                    certainSelf.followAuthorOfShot(shot)
                }
            case .DoNothing:
                break
            }
        }
        return cell
    }
}

// MARK: UICollectionViewDataSourcePrefetching

// NGRTodo: iOS 10 only API. Remove after updating project.
#if swift(>=2.3)
extension ShotsNormalStateHandler: UICollectionViewDataSourcePrefetching {

    func collectionView(collectionView: UICollectionView, prefetchItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }

        indexPaths.forEach {
            let shot = shotsCollectionViewController.shots[$0.item]
            load(shot.shotImage, for: $0)
        }
    }

    func collectionView(collectionView: UICollectionView, cancelPrefetchingForItemsAtIndexPaths indexPaths: [NSIndexPath]) {
        indexPathsNeededImageUpdate.removeAll()
    }
}
#endif

// MARK: UICollectionViewDelegate
extension ShotsNormalStateHandler {

    func collectionView(collectionView: UICollectionView,
            didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }

        let shot = shotsCollectionViewController.shots[indexPath.item]
        let shotUpdated = self.shotDummyRecent(shot)
        shotsCollectionViewController.modalPresentationStyle = .OverFullScreen
        presentShotDetailsViewController(shotUpdated ?? shot, index: indexPath.item, scrollToMessages: false)
    }

    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
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

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translationInView(scrollView.superview).y < 0 {
            AnalyticsManager.trackUserActionEvent(.SwipeDown)
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let collectionView = shotsCollectionViewController?.collectionView else { return }

        let blur = min(scrollView.contentOffset.y % CGRectGetHeight(scrollView.bounds),
                CGRectGetHeight(scrollView.bounds) - scrollView.contentOffset.y %
                CGRectGetHeight(scrollView.bounds)) / (CGRectGetHeight(scrollView.bounds) / 2)

        for cell in collectionView.visibleCells() {
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
        shotsCollectionViewController?.collectionView?.scrollEnabled = false
        shotsCollectionViewController?.collectionView?.allowsSelection = false
    }

    func shotCollectionViewCellDidEndSwiping(_: ShotCollectionViewCell) {
        shotsCollectionViewController?.collectionView?.scrollEnabled = true
        shotsCollectionViewController?.collectionView?.allowsSelection = true
    }
}

// MARK: 3DTouch

extension ShotsNormalStateHandler {
    
    func getShotDetailsViewController(atIndexPath indexPath: NSIndexPath) -> UIViewController? {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return nil }
        
        let shot = shotsCollectionViewController.shots[indexPath.item]
        let shotDetailsViewController = ShotDetailsViewController(shot: shot)
        shotDetailsViewController.customizeFor3DTouch(true)
        shotDetailsViewController.shotIndex = indexPath.item
        
        return shotDetailsViewController
    }
    
    func popViewController(controller: UIViewController) {
        guard let detailsViewController = controller as? ShotDetailsViewController,
            let shotsCollectionViewController = shotsCollectionViewController else { return }
        
        detailsViewController.customizeFor3DTouch(false)
        let shotDetailsPageDataSource = ShotDetailsPageViewControllerDataSource(shots: shotsCollectionViewController.shots, initialViewController: detailsViewController)
        shotDetailsPageDataSource.delegate = self
        let pageViewController = ShotDetailsPageViewController(shotDetailsPageDataSource: shotDetailsPageDataSource)
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(pageViewController)
        modalTransitionAnimator?.behindViewScale = 1
        
        pageViewController.transitioningDelegate = modalTransitionAnimator
        pageViewController.modalPresentationStyle = .Custom
        
        shotsCollectionViewController.tabBarController?.presentViewController(pageViewController, animated: true, completion: nil)
    }
}

// MARK: Private methods
private extension ShotsNormalStateHandler {

    func presentShotBucketsViewController(shot: ShotType) {
        let shotBucketsViewController = ShotBucketsViewController(shot: shot, mode: .AddToBucket)
        shotBucketsViewController.didDismissViewControllerClosure = { [weak self] in
            self?.didAddShotToBucketCompletionHandler?()
        }
        
        modalTransitionAnimator = CustomTransitions.pullDownToCloseTransitionForModalViewController(shotBucketsViewController)

        shotBucketsViewController.transitioningDelegate = modalTransitionAnimator
        shotBucketsViewController.modalPresentationStyle = .Custom
        shotsCollectionViewController?.tabBarController?.presentViewController(
                shotBucketsViewController, animated: true, completion: nil)
    }

    func presentShotDetailsViewController(shot: ShotType, index: Int, scrollToMessages: Bool, focusOnInput: Bool = false) {
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
        pageViewController.modalPresentationStyle = .Custom
        shotsCollectionViewController.tabBarController?.modalPresentationStyle = .OverCurrentContext
        shotsCollectionViewController.tabBarController?.presentViewController(
            pageViewController, animated: true, completion: nil)
    }

    func isShotLiked(shot: ShotType) -> Bool {
        return likedShots.contains { $0.identifier == shot.identifier }
    }
    
    // shot with most recent likes/buckets count
    func shotDummyRecent(shot: ShotType) -> ShotType {
        let likedShot = likedShots.filter{ $0.identifier == shot.identifier }
        
        return likedShot.first ?? shot
    }

    func likeShot(shot: ShotType) -> Promise<Void> {
        if isShotLiked(shot) {
            return Promise()
        }

        return Promise() { fulfill, reject in
            firstly {
                shotsRequester.likeShot(shot)
            }.then {
                self.fetchLikedShots()
            }.then { () -> Void in
                self.updateAuthorData()
                fulfill()
            }.error { error in
                reject(error)
            }
        }
    }

    func fetchLikedShots() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            firstly {
                likesProvider.provideLikedShots(likesToFetch)
            }.then { shots -> Void in
                if let shots = shots {
                    self.likedShots = shots
                }
            }.then(fulfill).error(reject)
        }
    }

    func updateLikeImage() {

        let visibleShot = self.visibleShot()
        let visibleCell = self.visibleCell()

        if let shot = visibleShot, cell = visibleCell {
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

            if let user = shot.user.name, url = shot.user.avatarURL {
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
        guard let collectionView = collectionViewLayout.collectionView where shotsCollectionViewController?.shots.count != 0 else {
            return
        }
        
        collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)])
    }

    func visibleShot() -> ShotType? {
        guard let
            viewController = shotsCollectionViewController,
            collectionView = viewController.collectionView else {
                return nil
        }

        return collectionView.indexPathsForVisibleItems().map { return viewController.shots[$0.item] }.first
    }

    func visibleCell() -> ShotCollectionViewCell? {
        guard let
            viewController = shotsCollectionViewController,
            collectionView = viewController.collectionView else {
                return nil
        }

        return collectionView.visibleCells().first as? ShotCollectionViewCell
    }

    func load(image: ShotImageType, for indexPath: NSIndexPath) {
        lazyLoadImage(image, for: indexPath)
    }

    func downloadNextPageIfNeeded(for indexPath: NSIndexPath) {
        guard let shotsCollectionViewController = shotsCollectionViewController else { return }

        if indexPath.item == shotsCollectionViewController.shots.count - 6 {

            firstly {
                shotsCollectionViewController.shotsProvider.nextPage()
                }.then { [weak self] shots -> Void in
                    if let shots = shots, shotsCollectionViewController = self?.shotsCollectionViewController {
                        shotsCollectionViewController.shots.appendContentsOf(shots)
                        shotsCollectionViewController.collectionView?.reloadData()
                    }
                }.error { error in
                    self.delegate?.shotsStateHandlerDidFailToFetchItems(error)
            }
        }
    }
    
    func followAuthorOfShot(shot: ShotType) -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            
            firstly {
                connectionsRequester.followUser(shot.user)
            }.then(fulfill).error(reject)
        }
    }
}

// MARK: Lazy loading of image

private extension ShotsNormalStateHandler {

    /// Returns UpdateableIndex object that matches given NSIndexPath (if any)
    /// - parameter indexPath: indexPath to match.
    /// - returns: Matched UpdateableIndexes object.
    func updateableIndexPath(for indexPath: NSIndexPath) -> UpdateableIndex? {
        let toCompare = indexPath.item
        return indexPathsNeededImageUpdate.filter { $0.index == toCompare }.first
    }

    func lazyLoadImage(shotImage: ShotImageType, for indexPath: NSIndexPath) {
        let teaserImageLoadingCompletion: UIImage -> Void = { [weak self] image in
            guard let certainSelf = self else { return }
            guard let _ = certainSelf.updateableIndexPath(for: indexPath) else { return }

            if let collectionView = certainSelf.shotsCollectionViewController?.collectionView {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShotCollectionViewCell {
                    cell.shotImageView.activityIndicatorView.stopAnimating()
                    cell.shotImageView.originalImage = image
                    cell.shotImageView.image = image
                }
            }
        }
        let imageLoadingCompletion: UIImage -> Void = { [weak self] image in
            guard let certainSelf = self else {return}
            guard var indexPathToUpdate = certainSelf.updateableIndexPath(for: indexPath) else { return }

            if let index = certainSelf.indexPathsNeededImageUpdate.indexOf({$0 == indexPathToUpdate}) {
                indexPathToUpdate.status = .Updated
                certainSelf.indexPathsNeededImageUpdate[index] = indexPathToUpdate
            }

            if let collectionView = certainSelf.shotsCollectionViewController?.collectionView {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ShotCollectionViewCell {
                    cell.shotImageView.activityIndicatorView.stopAnimating()
                    cell.shotImageView.originalImage = image
                    cell.shotImageView.image = image
                }
            }
        }

        if let indexPathToUpdate = updateableIndexPath(for: indexPath) where indexPathToUpdate.status == .InProgress {
            return
        } else {
            indexPathsNeededImageUpdate.append(UpdateableIndex(index: indexPath.item, status: .InProgress))
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
