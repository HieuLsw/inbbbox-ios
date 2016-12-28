//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyUserDefaults
import PeekPop

class ShotsCollectionViewController: UICollectionViewController, Vibratable, Support3DTouch {

    enum State {
        case onboarding, initialAnimations, normal
    }

    let initialState: State = Defaults[.onboardingPassed] ? .initialAnimations : .onboarding
    var stateHandler: ShotsStateHandler
    var backgroundAnimator: MainScreenStreamSourcesAnimator?
    var skipButtonAnimator: OnboardingSkipButtonAnimator?
    let shotsProvider = ShotsProvider()
    var shots = [ShotType]()
    fileprivate var emptyShotsView: UIView?
    fileprivate var didSetupAnimation = false
    internal var peekPop: PeekPop?
    internal var didCheckedSupport3DForOlderDevices = false

    // MARK: Life cycle

    @available(*, unavailable, message: "Use init() method instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     Initializer which creates ShotsCollectionViewController,
     with proper collection view layout, according to current state
     */

    init() {
        stateHandler = ShotsStateHandlersProvider().shotsStateHandlerForState(initialState)
        super.init(collectionViewLayout: stateHandler.collectionViewLayout)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UIViewController

extension ShotsCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.isPagingEnabled = true
        if #available(iOS 10.0, *) {
            collectionView?.prefetchDataSource = self
        }
        let backgroundView = ShotsCollectionBackgroundView()
        collectionView?.backgroundView = backgroundView
        backgroundAnimator = MainScreenStreamSourcesAnimator(view: backgroundView)
        skipButtonAnimator = OnboardingSkipButtonAnimator(view: backgroundView)
        collectionView?.registerClass(ShotCollectionViewCell.self, type: .cell)

        configureForCurrentStateHandler()
        registerToSettingsNotifications()
        setupStreamSourcesAnimators()
        setupSkipButton()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stateHandler.prepareForPresentingData()
        stateHandler.collectionViewLayout.prepare()
        handleEmptyShotsView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addSupport3DForOlderDevicesIfNeeded(with: self, viewController: self, sourceView: collectionView!)
        
        AnalyticsManager.trackScreen(.shotsView)

        if (!didSetupAnimation) {
            firstly {
                self.refreshShotsData()
            }.then {
                self.stateHandler.presentData()
            }.catch { error in
                let alertController = UIAlertController.willSignOutUser()
                self.tabBarController?.present(alertController, animated: true, completion: nil)
            }
        } else {
            AsyncWrapper().main(after: 1) { [unowned self] in
                self.showStreamSources()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideStreamSources()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return ColorModeProvider.current().preferredStatusBarStyle
    }
    
    fileprivate func handleEmptyShotsView() {
        if (stateHandler.shouldShowNoShotsView && emptyShotsView == nil) {
            let empty = EmptyShotsCollectionView()
            view.addSubview(empty)
            empty.autoPinEdgesToSuperviewEdges()
            emptyShotsView = empty
        } else if let emptyShotsView = emptyShotsView, !stateHandler.shouldShowNoShotsView {
            emptyShotsView.removeFromSuperview()
            self.emptyShotsView = nil
        }
    }
}

// MARK: UICollectionViewDataSource

extension ShotsCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stateHandler.collectionView(collectionView, numberOfItemsInSection: section)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = stateHandler.collectionView(collectionView, cellForItemAt: indexPath) as? ShotCollectionViewCell {
            if !cell.isRegisteredTo3DTouch {
                cell.isRegisteredTo3DTouch = registerTo3DTouch(cell.contentView)
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: UICollectionViewDelegate

extension ShotsCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        stateHandler.collectionView?(collectionView, didSelectItemAt: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        stateHandler.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if stateHandler is ShotsNormalStateHandler {
            stateHandler.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        }
    }
}

extension ShotsCollectionViewController: UICollectionViewDataSourcePrefetching {
    @available(iOS 10.0, *)
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let stateHandler = stateHandler as? ShotsNormalStateHandler {
            stateHandler.collectionView(collectionView, prefetchItemsAt: indexPaths)
        }
    }
    @available(iOS 10.0, *)
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        if let stateHandler = stateHandler as? ShotsNormalStateHandler {
            stateHandler.collectionView(collectionView, cancelPrefetchingForItemsAt: indexPaths)
        }
    }
}

// MARK: UIScrollViewDelegate

extension ShotsCollectionViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stateHandler.scrollViewDidEndDecelerating?(scrollView)
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stateHandler.scrollViewDidScroll?(scrollView)
    }

    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        stateHandler.scrollViewDidEndScrollingAnimation?(scrollView)
    }
}

extension ShotsCollectionViewController: ShotsStateHandlerDelegate {

    func shotsStateHandlerDidInvalidate(_ shotsStateHandler: ShotsStateHandler) {
        if shotsStateHandler is ShotsInitialAnimationsStateHandler {
            AsyncWrapper().main(after: 1) { [unowned self] in
                self.showStreamSources()
            }
        }
        if let newState = shotsStateHandler.nextState {
            stateHandler = ShotsStateHandlersProvider().shotsStateHandlerForState(newState)
            configureForCurrentStateHandler()
            stateHandler.prepareForPresentingData()
            stateHandler.presentData()
        }
    }

    func shotsStateHandlerDidFailToFetchItems(_ error: Error) {
        FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
    }
}

// MARK: Private methods

fileprivate extension ShotsCollectionViewController {

    func configureForCurrentStateHandler() {
        stateHandler.shotsCollectionViewController = self
        stateHandler.delegate = self
        tabBarController?.tabBar.isUserInteractionEnabled = stateHandler.tabBarInteractionEnabled
        tabBarController?.tabBar.alpha = stateHandler.tabBarAlpha
        collectionView?.isUserInteractionEnabled = stateHandler.collectionViewInteractionEnabled
        collectionView?.isScrollEnabled = stateHandler.collectionViewScrollEnabled
        collectionView?.setCollectionViewLayout(stateHandler.collectionViewLayout, animated: false)
        collectionView?.setContentOffset(CGPoint.zero, animated: false)

        if let normalStateHandler = stateHandler as? ShotsNormalStateHandler, let centerButtonTabBarController = tabBarController as? CenterButtonTabBarController {
            normalStateHandler.didLikeShotCompletionHandler = {
                centerButtonTabBarController.animateTabBarItem(.likes)
                self.vibrate(with: .success)
            }
            normalStateHandler.didAddShotToBucketCompletionHandler = {
                centerButtonTabBarController.animateTabBarItem(.buckets)
                self.vibrate(with: .success)
            }
            normalStateHandler.willDismissDetailsCompletionHandler = { [unowned self] index in
                self.scrollToShotAtIndex(index, animated: false)
            }
        } else if let onboardingStateHandler = stateHandler as? ShotsOnboardingStateHandler {
            onboardingStateHandler.skipDelegate = self
        }
    }

    func registerToSettingsNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStreamSourceSettings(_:)),
        name: NSNotification.Name(rawValue: InbbboxNotificationKey.UserDidChangeStreamSourceSettings.rawValue), object: nil)
    }

    dynamic func didChangeStreamSourceSettings(_ notification: Notification) {
        firstly {
            refreshShotsData()
        }.then { () -> Void in
            self.collectionView?.reloadData()
            self.collectionView?.setContentOffset(CGPoint.zero, animated: true)
        }.catch { error in
            FlashMessage.sharedInstance.showNotification(inViewController: self, title: FlashMessageTitles.downloadingShotsFailed, canBeDismissedByUser: true)
        }
    }

    func refreshShotsData() -> Promise<Void> {
        return Promise<Void> { fulfill, reject in
            firstly {
                self.shotsProvider.provideShots()
            }.then { shots -> Void in
                self.shots = shots ?? []
            }.then(execute: fulfill).catch(execute: reject)
        }
    }
    
    func scrollToShotAtIndex(_ index: Int, animated: Bool = true) {
        collectionView?.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredVertically, animated: animated)
    }
}

// MARK: UIViewControllerPreviewingDelegate

extension ShotsCollectionViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard
            let visibleCell = collectionView?.visibleCells.first,
            let normalStateHandler = stateHandler as? ShotsNormalStateHandler,
            let indexPath = collectionView?.indexPathsForVisibleItems.first
        else { return nil }
        
        previewingContext.sourceRect = visibleCell.contentView.bounds
        
        return normalStateHandler.getShotDetailsViewController(atIndexPath: indexPath)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let normalStateHandler = stateHandler as? ShotsNormalStateHandler {
            normalStateHandler.popViewController(viewControllerToCommit)
        }
    }
}

// MARK: PeekPopPreviewingDelegate

extension ShotsCollectionViewController: PeekPopPreviewingDelegate {

    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let collectionView = collectionView,
            let visibleCell = collectionView.visibleCells.first,
            let normalStateHandler = stateHandler as? ShotsNormalStateHandler,
            let indexPath = collectionView.indexPathsForVisibleItems.first
        else { return nil }

        previewingContext.sourceRect = visibleCell.frame

        return normalStateHandler.getShotDetailsViewController(atIndexPath: indexPath)
    }

    func previewingContext(_ previewingContext: PreviewingContext, commit viewControllerToCommit: UIViewController) {
        if let normalStateHandler = stateHandler as? ShotsNormalStateHandler {
            normalStateHandler.popViewController(viewControllerToCommit)
        }
    }
}


// MARK: Stream sources animations

private extension ShotsCollectionViewController {
    
    func setupStreamSourcesAnimators() {
        // Invisible button on top of collection view is used to not block touch events 
        // on collection view and simplify dealing with clicking on logo 
        let invisibleButton = UIButton()
        invisibleButton.addTarget(self, action: #selector(logoTapped), for: .touchUpInside)
        view.addSubview(invisibleButton)
        invisibleButton.autoPinEdge(toSuperviewEdge: .top, withInset: ShotsCollectionBackgroundViewSpacing.logoDefaultVerticalInset)
        invisibleButton.autoSetDimension(.height, toSize: ShotsCollectionBackgroundViewSpacing.logoHeight)
        invisibleButton.autoPinEdge(toSuperviewEdge: .left)
        invisibleButton.autoPinEdge(toSuperviewEdge: .right)
        
    }
    
    func showStreamSources() {
        guard !stateHandler.shouldShowNoShotsView else {
            return
        }
        backgroundAnimator?.startFadeInAnimation()
        AsyncWrapper().main(after: 4) { [unowned self] in
            self.backgroundAnimator?.startFadeOutAnimation()
        }
    }
    
    func hideStreamSources() {
        backgroundAnimator?.startFadeOutAnimation()
    }
    
    @objc func logoTapped() {
        if let condition = backgroundAnimator?.areStreamSourcesShown, condition == true {
            hideStreamSources()
        } else {
            let vc = StreamSourceViewController()
            vc.modalPresentationStyle = .overCurrentContext
            present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: OnboardingSkipable

extension ShotsCollectionViewController: OnboardingSkipButtonHandlerDelegate {
    
    func shouldSkipButtonAppear() {
        skipButtonAnimator?.showButton()
    }
    
    func shouldSkipButtonDisappear() {
        skipButtonAnimator?.hideButton()
    }
}

private extension ShotsCollectionViewController {
    
    func setupSkipButton() {
        guard let background = collectionView?.backgroundView as? ShotsCollectionBackgroundView else { return }
        background.skipButton.addTarget(self, action: #selector(skipStep), for: .touchUpInside)
    }
    
    @objc func skipStep() {
        guard let onboardingHandler = stateHandler as? ShotsOnboardingStateHandler else { return }
        onboardingHandler.skipOnboardingStep()
    }
}
