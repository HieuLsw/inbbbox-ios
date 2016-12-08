//
//  FlashMessage.swift
//  Inbbbox
//
//  Created by Blazej Wdowikowski on 11/2/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

final class FlashMessage {
    
    static let sharedInstance = FlashMessage()
    
    /// Set a custom offset for the notification view
    var offsetHeightForMessage: CGFloat = -64.0
    
    /// Set a custom view for the notification
    var customizeMessageView: ((FlashMessageView) -> Void)?
    
    fileprivate let displayTime = 1.5
    fileprivate let extraDisplayTimePerPixel = 0.04
    fileprivate let animationDuration = 0.3
    fileprivate let minimalInset: CGFloat = 10
    fileprivate let asyncWrapper = AsyncWrapper()
    
    /// Indicates whether a notification is currently active.
    fileprivate(set) var notificationActive = false
    
    fileprivate var messages = [FlashMessageView]()

    ///  The currently queued array of FlashMessageView
    fileprivate var queuedMessages: [FlashMessageView] {
        return messages
    }
    
    // MARK: Lifecycle
    
    /// Shows a notification message in a specific view controller
    ///
    /// - parameter viewController:     The view controller to show the notification in.
    /// - parameter title:              The title of the notification view
    /// - parameter duration:           The duration of the notification being displayed  (Automatic, Endless, Custom)
    /// - parameter messagePosition:    The position of the message on the screen
    /// - parameter overrideStyle:      Override default styles using this style struct, it has highest priority.
    /// - parameter dismissingEnabled:  Should the message be dismissed when the user taps/swipes it
    /// - parameter callback:           The block that should be executed, when the user tapped on the message/
    func showNotification(inViewController viewController: UIViewController? = nil, title: String, duration: FlashMessageDuration = .automatic, atPosition messagePosition: FlashMessageNotificationPosition = .top, overrideStyle: FlashMessageView.Style? = nil, canBeDismissedByUser dismissingEnabled: Bool = true, shouldBeDisplayedInViewController: Bool = true , callback: (() -> Void)? = nil) {
        
        if let messageTitle = messages.last?.title, title == messageTitle {
            return
        }
        let messageView  = FlashMessageView(
            viewController: viewController,
            title: title,
            duration: duration,
            position: messagePosition,
            style: overrideStyle,
            dismissingEnabled: dismissingEnabled,
            displayInViewController: shouldBeDisplayedInViewController,
            callback: callback
        )
        
        messageView.fadeOut = { [weak messageView, weak self] in
            if let messageView = messageView {
                self?.fadeOutNotification(messageView)
            }
        }
        
        messages.append(messageView)
        
        if !notificationActive {
            fadeInCurrentNotification()
        }
    }
    
    /// Fades out the currently displayed notification. If another notification is in the queue,
    /// the next one will be displayed automatically
    ///
    /// - Returns: true if the currently displayed notification was successfully dismissed. NO if no notification was currently displayed.
    func dismissActiveNotification() -> Bool {
        return dismissActiveNotificationWithCompletion(nil)
    }
    
    func dismissActiveNotificationWithCompletion(_ completion: (() -> Void)?) -> Bool {
        guard !messages.isEmpty else {
            return false
        }
        DispatchQueue.main.async(execute: {
            guard let currentMessage = self.messages.first else {
                return
            }
            if currentMessage.messageIsFullyDisplayed {
                self.fadeOutNotification(currentMessage, animationFinishedBlock: completion)
            } else {
                
                Timer.scheduledTimer(timeInterval: self.animationDuration + 0.1, target: BlockOperation(block: {
                    self.fadeOutNotification(currentMessage, animationFinishedBlock: completion)
                }), selector: #selector(Operation.main), userInfo: nil, repeats: false)
                
            }
        })
        return true
    }
    
    // MARK: Animation
    
    fileprivate func fadeInCurrentNotification() {
        messages = messages.flatMap {
            $0.viewController == nil && UIApplication.shared.keyWindow == nil ? nil : $0
        }
        guard let flashMessageView = messages.first else {
            return
        }
        
        notificationActive = true
        var verticalOffset: CGFloat = 0.0

        if let viewController = flashMessageView.viewController, let currentNavigationController = navigationControllerFrom(viewController) {
            if !isNavigationBarHiddenIn(currentNavigationController) && flashMessageView.messagePosition != .navigationBarOverlay {
                flashMessageView.displayInView?.insertSubview(flashMessageView, belowSubview: currentNavigationController.navigationBar)
                verticalOffset = currentNavigationController.navigationBar.bounds.size.height
            } else {
                flashMessageView.displayInView?.addSubview(flashMessageView)
            }
            
            if checkIfViewIsUnderStatusBar(currentNavigationController) {
                verticalOffset += barHeightBasedOnMessagePositionIn(flashMessageView)
            }
        } else {
            flashMessageView.displayInView?.addSubview(flashMessageView)
            verticalOffset = flashMessageView.frame.height
        }
        
        let endPoint = calculateEndPointForFadeInBasedOn(flashMessageView, andVerticaOffset: verticalOffset)
        customizeMessageView?(flashMessageView)
        animateView(flashMessageView, toPoint: endPoint)
        fadeOutNotificationWithDelay(flashMessageView)
    }
    
    fileprivate func calculateEndPointForFadeInBasedOn(_ flashMessageView: FlashMessageView, andVerticaOffset verticalOffset: CGFloat) -> CGPoint {
        if flashMessageView.messagePosition != .bottom {
            let height = flashMessageView.frame.height - minimalInset
            let offestHeight = flashMessageView.displayInViewController ? offsetHeightForMessage : 0
            return CGPoint(x: flashMessageView.center.x, y: offestHeight + verticalOffset + (height / 2.0))
        } else {
            let height = flashMessageView.viewController?.view.bounds.size.height ?? 0.0
            var y = height - flashMessageView.frame.height / 2.0
            if let navigationController = flashMessageView.viewController?.navigationController, !navigationController.isToolbarHidden {
                y -= navigationController.toolbar.bounds.height
            }
            return CGPoint(x: flashMessageView.center.x, y: y)
        }
    }
    
    fileprivate func animateView(_ view: FlashMessageView, toPoint: CGPoint) {
        UIView.animate(withDuration: self.animationDuration + 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                view.center = toPoint
            }, completion: { finished in
                view.messageIsFullyDisplayed = true
        })
    }
    
    fileprivate func barHeightBasedOnMessagePositionIn(_ currentView: FlashMessageView) -> CGFloat {
        guard currentView.messagePosition != .navigationBarOverlay else {
            return 0.0
        }
        
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }
    
    fileprivate func navigationControllerFrom(_ viewController: UIViewController) -> UINavigationController? {
        guard (viewController is UINavigationController) || (viewController.parent is UINavigationController) else {
            return nil
        }
        return viewController as? UINavigationController ?? viewController.parent as! UINavigationController
    }
    
    fileprivate func checkIfViewIsUnderStatusBar(_ navigationController: UINavigationController) -> Bool {
        var isViewIsUnderStatusBar = (navigationController.childViewControllers.first?.edgesForExtendedLayout == .all)
        if !isViewIsUnderStatusBar && navigationController.parent == nil {
            isViewIsUnderStatusBar = !isNavigationBarHiddenIn(navigationController)
        }
        return isViewIsUnderStatusBar
    }
    
    fileprivate func isNavigationBarHiddenIn(_ navigationController: UINavigationController) -> Bool {
        return navigationController.isNavigationBarHidden || navigationController.navigationBar.isHidden
    }
    
    fileprivate func fadeOutNotificationWithDelay(_ flashMessageView: FlashMessageView) {
        var durationToPresent: TimeInterval?
        switch(flashMessageView.duration) {
            case .automatic:
                durationToPresent = animationDuration + displayTime + TimeInterval(flashMessageView.frame.size.height) * extraDisplayTimePerPixel
            case .custom(let timeInterval):
                durationToPresent = timeInterval
            default:
                break
        }
        
        if let durationToPresent = durationToPresent {
            asyncWrapper.main(after: durationToPresent) {
                self.fadeOutNotification(flashMessageView)
            }
        }
    }
    
    @objc fileprivate func fadeOutNotification(_ flashMessageView: FlashMessageView) {
        fadeOutNotification(flashMessageView, animationFinishedBlock: nil)
    }
    
    @objc fileprivate func fadeOutNotification(_ flashMessageView: FlashMessageView, animationFinishedBlock animationFinished: (() -> Void)?) {
        guard let view = flashMessageView.displayInView else {
            if self.messages.count > 0 {
                self.messages.remove(at: 0)
            }
            notificationActive = false
            return
        }
        
        flashMessageView.messageIsFullyDisplayed = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fadeOutNotification(_:)), object: flashMessageView)
        var fadeOutToPoint: CGPoint
        if flashMessageView.messagePosition != .bottom {
            fadeOutToPoint = CGPoint(x: flashMessageView.center.x, y: -flashMessageView.frame.height / 2.0)
        } else {
            fadeOutToPoint = CGPoint(x: flashMessageView.center.x, y: view.bounds.size.height + flashMessageView.frame.height / 2.0)
        }
        UIView.animate(withDuration: animationDuration, animations: {
                flashMessageView.center = fadeOutToPoint
            }, completion: { finished in
                flashMessageView.removeFromSuperview()
                if self.messages.count > 0 {
                    self.messages.remove(at: 0)
                }
                self.notificationActive = false
                if self.messages.count > 0 {
                    self.fadeInCurrentNotification()
                }
                if finished {
                    animationFinished?()
                }
        })
    }
}
