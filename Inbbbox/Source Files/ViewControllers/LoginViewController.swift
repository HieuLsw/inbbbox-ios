//
//  LoginViewController.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 16/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit
import SafariServices

class LoginViewController: UIViewController {

    fileprivate lazy var __once: () = {
            self.shotsAnimator.scrollToMiddleInstantly()
        }()

    var centerButtonTabBarController: CenterButtonTabBarController

    fileprivate var shotsAnimator: AutoScrollableShotsAnimator!
    fileprivate weak var aView: LoginView?
    fileprivate var viewAnimator: LoginViewAnimator?
    fileprivate var authenticator: Authenticator?
    fileprivate var onceTokenForScrollToMiddleInstantly = Int(0)
    fileprivate var logoTappedCount = 0
    fileprivate var statusBarStyle: UIStatusBarStyle = .lightContent {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    init(tabBarController: CenterButtonTabBarController) {
        centerButtonTabBarController = tabBarController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "Use init(tabBarController:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        aView = loadViewWithClass(LoginView.self)
        viewAnimator = LoginViewAnimator(view: aView, delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let bindForAnimation = aView?.shotsView.collectionViews.map {
            (collectionView: $0, shots: ShotsStorage().shotsFromAssetCatalog.shuffle())
        } ?? []

        shotsAnimator = AutoScrollableShotsAnimator(bindForAnimation: bindForAnimation)
        aView?.loginButton.addTarget(self,
                                     action: #selector(loginButtonDidTap(_:)),
                                     for: .touchUpInside)
        aView?.loginAsGuestButton.addTarget(self,
                                            action: #selector(loginAsGuestButtonDidTap(_:)),
                                            for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logoTapped(_:)))
        aView?.logoImageView.addGestureRecognizer(tapGesture)
        aView?.logoImageView.isUserInteractionEnabled = true
        aView?.loadingLabel.alpha = 0
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        _ = self.__once
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shotsAnimator.startScrollAnimationInfinitely()
        AnalyticsManager.trackScreen(.loginView)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    deinit {
        shotsAnimator?.stopAnimation()
    }
}

// MARK: Actions

extension LoginViewController {

    func loginButtonDidTap(_: UIButton) {

        viewAnimator?.startLoginAnimation()

        let interactionHandler: ((SFSafariViewController) -> Void) = { controller in
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }

        let success: ((Void) -> Void) = {
            self.dismiss(animated: true) {
                self.viewAnimator?.stopAnimationWithType(.continue) {
                    self.aView?.loadingLabel.alpha = 0
                    self.aView?.copyrightlabel.alpha = 0
                    self.presentNextViewController()
                }
            }
        }

        let failure: ((Error) -> Void) = { error in
            self.viewAnimator?.stopAnimationWithType(.undo)
            self.dismiss(animated: true, completion: nil)
        }

        authenticator = Authenticator(service: .dribbble,
                                      interactionHandler: interactionHandler,
                                      success: success,
                                      failure: failure)
        authenticator?.login()
    }

    func loginAsGuestButtonDidTap(_: UIButton) {
        Authenticator.logout()
        UserStorage.storeGuestUser()
        AnalyticsManager.trackLoginEvent(AnalyticsLoginEvent.loginAsGuest)
        viewAnimator?.startLoginAnimation(stopAfterShrink: true)
    }

    func logoTapped(_ sender: UITapGestureRecognizer) {
        logoTappedCount += 1
        if logoTappedCount == 5 {
            viewAnimator?.showLoginAsGuest()
            sender.isEnabled = false
        }
    }
}

extension LoginViewController: LoginViewAnimatorDelegate {

    func tabBarWillAppear() {
        statusBarStyle = .default
    }

    func shrinkAnimationDidFinish() {
        self.viewAnimator?.stopAnimationWithType(.continue) {
            self.presentNextViewController()
        }
    }
}

extension LoginViewController: SafariAuthorizable {
    func handleOpenURL(_ url: URL) {
        authenticator?.loginWithOAuthURLCallback(url)
    }
}

extension LoginViewController: SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
        after(interval: 0.5).then { result -> Void in
            self.aView?.loadingLabel.alpha = 0
            self.viewAnimator?.stopAnimationWithType(.undo)
        }
    }
}

private extension LoginViewController {

    func presentNextViewController() {
        self.present(centerButtonTabBarController, animated: false, completion: nil)
    }
}
