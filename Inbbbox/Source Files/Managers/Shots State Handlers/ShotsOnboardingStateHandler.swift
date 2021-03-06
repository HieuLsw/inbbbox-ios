//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import PromiseKit

class ShotsOnboardingStateHandler: NSObject, ShotsStateHandler {

    fileprivate let connectionsRequester = APIConnectionsRequester()
    fileprivate let userProvider = APIUsersProvider()
    fileprivate let netguruIdentifier = "netguru"
    
    weak var shotsCollectionViewController: ShotsCollectionViewController?
    weak var delegate: ShotsStateHandlerDelegate?
    weak var skipDelegate: OnboardingSkipButtonHandlerDelegate?
    let onboardingSteps: [(image: UIImage?, action: ShotCollectionViewCell.Action)]


    var scrollViewAnimationsCompletion: (() -> Void)?

    var state: ShotsCollectionViewController.State {
        return .onboarding
    }

    var nextState: ShotsCollectionViewController.State? {
        return .normal
    }

    var tabBarInteractionEnabled: Bool {
        return false
    }

    var tabBarAlpha: CGFloat {
        return 0.3
    }

    var collectionViewLayout: UICollectionViewLayout {
        return ShotsCollectionViewFlowLayout()
    }

    var collectionViewInteractionEnabled: Bool {
        return true
    }

    var collectionViewScrollEnabled: Bool {
        return false
    }
    
    var shouldShowNoShotsView: Bool {
        return false
    }

    func prepareForPresentingData() {
        self.disablePrefetching()
    }

    func presentData() {
        shotsCollectionViewController?.collectionView?.reloadData()
    }

    override init() {
        let step1 = Localized("ShotsOnboardingStateHandler.Onboarding-Step1", comment: "")
        let step2 = Localized("ShotsOnboardingStateHandler.Onboarding-Step2", comment: "")
        let step3 = Localized("ShotsOnboardingStateHandler.Onboarding-Step3", comment: "")
        let step4 = Localized("ShotsOnboardingStateHandler.Onboarding-Step4", comment: "")
        let step5 = Localized("ShotsOnboardingStateHandler.Onboarding-Step5", comment: "")
        onboardingSteps = [
            (image: UIImage(named: step1), action: ShotCollectionViewCell.Action.like),
            (image: UIImage(named: step2), action: ShotCollectionViewCell.Action.bucket),
            (image: UIImage(named: step3), action: ShotCollectionViewCell.Action.comment),
            (image: UIImage(named: step4), action: ShotCollectionViewCell.Action.follow),
            (image: UIImage(named: step5), action: ShotCollectionViewCell.Action.doNothing),
        ]
    }
    
    func skipOnboardingStep() {
        guard let collectionView = shotsCollectionViewController?.collectionView else { return }
        collectionView.animateToNextCell()
    }
}

// MARK: UICollectionViewDataSource
extension ShotsOnboardingStateHandler {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return onboardingSteps.count
        }
        return onboardingSteps.count + shotsCollectionViewController.shots.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < onboardingSteps.count {
            return cellForOnboardingShot(collectionView, indexPath: indexPath)
        } else {
            return cellForShot(collectionView, indexPath: indexPath)
        }
    }
}

// MARK: UICollectionViewDelegate
extension ShotsOnboardingStateHandler {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row == onboardingSteps.count - 1 else {
            return
        }
        scrollViewAnimationsCompletion = {
            Defaults[.onboardingPassed] = true
            self.enablePrefetching()
            self.delegate?.shotsStateHandlerDidInvalidate(self)
        }
        skipOnboardingStep()
    }
}

// MARK: UIScrollViewDelegate
extension ShotsOnboardingStateHandler {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewAnimationsCompletion?()
        scrollViewAnimationsCompletion = nil
    }
}

// MARK: Private methods
private extension ShotsOnboardingStateHandler {

    func cellForShot(_ collectionView: UICollectionView, indexPath: IndexPath) -> ShotCollectionViewCell {
        guard let shotsCollectionViewController = shotsCollectionViewController else {
            return ShotCollectionViewCell()
        }
        let shot = shotsCollectionViewController.shots[0]
        let cell = collectionView.dequeueReusableClass(ShotCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)
        cell.shotImageView.loadShotImageFromURL(shot.shotImage.normalURL)
        cell.displayAuthor(Settings.Customization.ShowAuthor, animated: false)
        cell.gifLabel.isHidden = !shot.animated
        return cell
    }

    func cellForOnboardingShot(_ collectionView: UICollectionView, indexPath: IndexPath) -> ShotCollectionViewCell {
        let cell = collectionView.dequeueReusableClass(ShotCollectionViewCell.self,
                forIndexPath: indexPath, type: .cell)
        let stepImage = onboardingSteps[indexPath.row].image
        cell.shotImageView.image = stepImage
        cell.gifLabel.isHidden = true
        cell.enabledActions = [self.onboardingSteps[indexPath.row].action]
        cell.swipeCompletion = { [weak self] action in
            guard let certainSelf = self, action == certainSelf.onboardingSteps[indexPath.row].action else {
                return
            }
            collectionView.animateToNextCell()
            if action == .follow {
                certainSelf.followNetguru()
            }
            
        }

        let currentStep = onboardingSteps[indexPath.row].action

        switch currentStep {
        case .follow: skipDelegate?.shouldSkipButtonAppear()
        default: skipDelegate?.shouldSkipButtonDisappear()
        }
        
        return cell
    }
    
    func followNetguru() {
        firstly {
            userProvider.provideUser(netguruIdentifier)
        }.then { user in
            self.connectionsRequester.followUser(user)
        }.catch { _ in }
    }

    func enablePrefetching() {
        if #available(iOS 10.0, *) {
            self.shotsCollectionViewController?.collectionView?.isPrefetchingEnabled = true
        }
    }

    func disablePrefetching() {
        if #available(iOS 10.0, *) {
            self.shotsCollectionViewController?.collectionView?.isPrefetchingEnabled = false
        }
    }
}

private extension UICollectionView {
    func animateToNextCell() {
        var newContentOffset = contentOffset
        newContentOffset.y += bounds.height
        setContentOffset(newContentOffset, animated: true)
    }
}
