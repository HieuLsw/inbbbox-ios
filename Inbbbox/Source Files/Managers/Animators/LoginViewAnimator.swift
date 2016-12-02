//
//  LoginViewAnimator.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PromiseKit

protocol LoginViewAnimatorDelegate: class {
    func tabBarWillAppear()
    func shrinkAnimationDidFinish()
}

class LoginViewAnimator {

    enum StopAnimationType {
        case `continue`, undo
    }

    fileprivate weak var view: LoginView?
    fileprivate var animations = LoginViewAnimations()
    fileprivate weak var delegate: LoginViewAnimatorDelegate?

    fileprivate var loginButtonTitle: String?
    fileprivate let loopDuration = TimeInterval(1)
    fileprivate var loginAsGuestShown = false

    init(view: LoginView?, delegate: LoginViewAnimatorDelegate?) {
        self.view = view
        self.delegate = delegate
    }

    func startLoginAnimation(stopAfterShrink stop: Bool = false) {

        guard let view = view, !view.isAnimating else { return }

        firstly {
            prepareCanvas()
        }.then {
            self.shrinkToBallWithRotation()
        }.then {
            if stop {
                self.delegate?.shrinkAnimationDidFinish()
                // break chain:
                throw NSError(domain: "", code: 0, message: "")
            }
            return when(fulfilled: [self.ballBounce(), self.loadingFade(fade: .fadeIn)])
        }.then {
            self.loadingBlink()
        }.catch { _ in }

    }

    func stopAnimationWithType(_ type: StopAnimationType, completion: (() -> Void)? = nil) {

        animations.stop()

        guard let view = view, view.isAnimating else { return }
        if type == .undo {
            firstly {
                when(fulfilled: [self.extendToButtonWithRotation(), self.loadingFade(fade: .fadeOut)])
            }.then { _ -> Void in
                self.restoreInitialState()
                completion?()
            }.catch { _ in }

        } else {
            firstly {
                when(fulfilled: [self.loadingFade(fade: .fadeOut), self.slideInterfaceUp(),
                        self.sloganFadeOut(), self.saturateBackground()])
            }.then {
                self.delegate?.tabBarWillAppear()
                return when(fulfilled: [self.animateTabBar(), self.slideOutBallWithFadingOut(),
                        self.addInbbboxLogo(fromTop: 60)])
            }.then {
                completion?()
            }.catch { _ in }
        }
    }

    func showLoginAsGuest() {
        loginAsGuestShown = true
        animations.moveAnimation([view!.loginButton, view!.dribbbleLogoImageView], duration: 0.5,
                fade: .fadeIn, easeFunction: .curveEaseInOut, transition: CGPoint(x: 0, y: -32))
        animations.moveAnimation([view!.orLabel, view!.loginAsGuestButton], duration: 0.5,
                fade: .fadeIn, easeFunction: .curveEaseInOut, transition: CGPoint(x: 0, y: -200))
    }
}

private extension LoginViewAnimator {

    func prepareCanvas() -> Promise<Void> {
        animations.prepare()
        loginButtonTitle = view!.loginButton.title(for: UIControlState())
        view!.isAnimating = true
        view!.loginButton.setTitle(nil, for: UIControlState())
        view!.loginButton.isEnabled = false
        return Promise<Void>(value: Void())
    }

    func restoreInitialState() {
        loginButtonTitle = nil
        view!.isAnimating = false
        view!.loginButton.isEnabled = true
    }

    func ballBounce() -> Promise<Void> {
        animations.bounceAnimation([view!.loginButton, view!.dribbbleLogoImageView],
                                    duration: loopDuration, additionalYOffset: loginAsGuestShown)
        return Promise<Void>(value: Void())
    }

    func loadingFade(fade: LoginViewAnimations.FadeStyle) -> Promise<Void> {
        return Promise<Void> { fulfill, _ in
                animations.moveAnimation([view!.loadingLabel, view!.copyrightlabel], duration: 0.4,
                                 fade: fade, transition: CGPoint.zero) {
                    fulfill()
            }
            
        }
    }

    func loadingBlink() -> Promise<Void> {
        animations.blinkAnimation([view!.loadingLabel], duration: loopDuration)
        return Promise<Void>(value: Void())
    }

    func shrinkToBallWithRotation() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            // logo rotation animation:
            animations.rotationAnimation([view!.dribbbleLogoImageView], duration: 0.8, cycles: 5)

            // fade out button + label animation:
            animations.moveAnimation([view!.orLabel, view!.loginAsGuestButton], duration: 0.8,
                    fade: .fadeOut, transition: CGPoint(x: 0, y: 200))

            // login button corner radius animation
            animations.animateCornerRadiusForthAndBack(view!.loginButton)

            // spring animation uibutton and logo
            animations.animateSpringShrinkingToBall(view!.loginButton,
                    logo: view!.dribbbleLogoImageView) {
                fulfill()
            }
        }
    }

    func extendToButtonWithRotation() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            // logo rotation animation:
            animations.rotationAnimation([view!.dribbbleLogoImageView], duration: 0.8, cycles: 5)

            // fade out button + label animation:
            animations.moveAnimation([view!.orLabel, view!.loginAsGuestButton], duration: 0.8,
                    fade: .fadeIn, transition: CGPoint(x: 0, y: -200))

            // login button corner radius animation
            animations.animateCornerRadiusForthAndBack(view!.loginButton)

            // spring animation uibutton and logo
            animations.animateSpringExtendingToButton(view!.loginButton,
                    logo: view!.dribbbleLogoImageView) {
                fulfill()
            }

            view!.loginButton.setTitle(loginButtonTitle, for: .normal)
            view!.loginButton.titleLabel!.alpha = 0
            UIView.animate(withDuration: 1.5) {
                self.view!.loginButton.titleLabel!.alpha = 1
            }
        }
    }

    func slideInterfaceUp() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            let transition = CGPoint(x: 0, y: -view!.pinkOverlayView.frame.height)
            let views = [view!.pinkOverlayView, view!.logoImageView]
            animations.moveAnimation(views, duration: 0.4, fade: .fadeOut, transition: transition) {
                fulfill()
            }
        }
    }

    func sloganFadeOut() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in
            animations.moveAnimation([view!.sloganLabel], duration: 0.4,
                    fade: .fadeOut, transition: CGPoint.zero) {
                fulfill()
            }
        }
    }

    func saturateBackground() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in

            let frame = CGRect(
                x: 0,
                y: view!.frame.maxY,
                width: view!.frame.width,
                height: view!.frame.height
            )
            let transition = CGPoint(x: 0, y: -frame.height)

            let whiteView = UIView(frame: frame)
            whiteView.backgroundColor = UIColor.backgroundGrayColor()
            whiteView.alpha = 0.0
            view!.insertSubview(whiteView, belowSubview: view!.pinkOverlayView)

            animations.moveAnimation([whiteView], duration: 0.4,
                    fade: .fadeIn, transition: transition) {
                fulfill()
            }
        }
    }

    func addInbbboxLogo(fromTop: CGFloat) -> Promise<Void> {

        let logoImageView = UIImageView(image: UIImage(named: ColorModeProvider.current().logoImageName))
        logoImageView.alpha = 0.0

        let size = logoImageView.image?.size ?? CGSize.zero
        let origin = CGPoint(x: (view!.frame).midX - size.width * 0.5, y: fromTop)
        logoImageView.frame = CGRect(origin: origin, size: size)

        view!.insertSubview(logoImageView, belowSubview: view!.pinkOverlayView)

        return Promise<Void> { fulfill, _ in
            UIView.animate(withDuration: 0.5, animations: {
                logoImageView.alpha = 1
            }, completion: { _ in
                fulfill()
            })
        }
    }

    func slideOutBallWithFadingOut() -> Promise<Void> {
        return Promise<Void> { fulfill, _ in
            animations.moveAnimation([view!.dribbbleLogoImageView, view!.loginButton],
                    duration: 0.3, fade: .fadeOut, transition: CGPoint(x: 0, y: 200)) {
                fulfill()
            }
        }
    }

    func animateTabBar() -> Promise<Void> {

        let tabBarAnimator = TabBarAnimator(view: view!)
        return tabBarAnimator.animateTabBar()
    }
    
}
