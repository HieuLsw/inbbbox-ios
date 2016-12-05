//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

class ShotsInitialAnimationsStateHandler: NSObject, ShotsStateHandler {

    let animationManager = ShotsAnimator()
    weak var shotsCollectionViewController: ShotsCollectionViewController? {
        didSet {
            shotsCollectionViewController?.collectionView?.emptyDataSetSource = self
        }
    }

    weak var delegate: ShotsStateHandlerDelegate?

    var state: ShotsCollectionViewController.State {
        return .InitialAnimations
    }

    var nextState: ShotsCollectionViewController.State? {
        return .Normal
    }

    var tabBarInteractionEnabled: Bool {
        return false
    }

    var tabBarAlpha: CGFloat {
        return 0.3
    }

    var collectionViewLayout: UICollectionViewLayout {
        return InitialShotsCollectionViewLayout()
    }

    var collectionViewInteractionEnabled: Bool {
        return false
    }

    var collectionViewScrollEnabled: Bool {
        return false
    }
    
    var shouldShowNoShotsView: Bool {
        return shotsCollectionViewController?.shots.count == 0 && Settings.areAllStreamSourcesOff()
    }

    private let emptyDataSetLoadingView = EmptyDataSetLoadingView.newAutoLayoutView()

    override init () {
        super.init()
        animationManager.delegate = self
    }

    func prepareForPresentingData() {
        // Do nothing, all set.
    }

    func presentData() {
        hideEmptyDataSetLoadingView()
        self.animationManager.startAnimationWithCompletion() {
            self.shotsCollectionViewController?.collectionView?.emptyDataSetSource = nil
            self.delegate?.shotsStateHandlerDidInvalidate(self)
        }
    }
}

// MARK: UICollecitonViewDataSource

extension ShotsInitialAnimationsStateHandler {

    func collectionView(collectionView: UICollectionView,
            numberOfItemsInSection section: Int) -> Int {
        return self.animationManager.visibleItems.count
    }

    func collectionView(collectionView: UICollectionView,
            cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return UICollectionViewCell()
        }

        let cell = collectionView.dequeueReusableClass(ShotCollectionViewCell.self,
                forIndexPath: indexPath, type: .Cell)
        cell.configureForDisplayingAuthorView = Settings.Customization.ShowAuthor
        let shot = shotsCollectionViewController.shots[indexPath.item]
        let shouldBlurShotImage = indexPath.row != 0
        let blur = shouldBlurShotImage ? CGFloat(1) : CGFloat(0)
        cell.shotImageView.loadShotImageFromURL(shot.shotImage.normalURL, blur: blur)
        cell.shotImageView.applyBlur(blur)
        cell.gifLabel.hidden = !shot.animated

        let imageCompletion: UIImage -> Void = { image in
            cell.shotImageView.image = image
            cell.shotImageView.applyBlur(blur)
        }

        LazyImageProvider.lazyLoadImageFromURLs(
            (shot.shotImage.teaserURL, shot.shotImage.normalURL, nil),
            teaserImageCompletion: imageCompletion,
            normalImageCompletion: imageCompletion
        )
        
        return cell
    }
}

extension ShotsInitialAnimationsStateHandler: ShotsAnimatorDelegate {

    func collectionViewForShotsAnimator(animator: ShotsAnimator) -> UICollectionView? {
        return shotsCollectionViewController?.collectionView
    }

    func itemsForShotsAnimator(animator: ShotsAnimator) -> [ShotType] {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return []
        }
        return Array(shotsCollectionViewController.shots.prefix(3))
    }
}

extension ShotsInitialAnimationsStateHandler: DZNEmptyDataSetSource {

    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        emptyDataSetLoadingView.startAnimating()
        return emptyDataSetLoadingView
    }
}

// MARK: Private methods

private extension ShotsInitialAnimationsStateHandler {

    // NGRHack: DZNEmptyDataSet does not react on `insertItemsAtIndexPaths`
    // so we need to manually hide loading view
    func hideEmptyDataSetLoadingView() {
        emptyDataSetLoadingView.hidden = true
        emptyDataSetLoadingView.stopAnimating()
    }
}
