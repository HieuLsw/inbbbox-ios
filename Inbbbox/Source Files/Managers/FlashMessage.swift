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
    
    /// Use this property to set a default view controller to display the messages in
    var defaultViewController: UIViewController  {
        get {
            return _defaultViewController ?? UIApplication.sharedApplication().keyWindow!.rootViewController!
        }
        set {
            _defaultViewController = newValue
        }
    }
    
    private let displayTime = 1.5
    private let extraDisplayTimePerPixel = 0.04
    private let animationDuration = 0.3
    private let minimalInset: CGFloat = 10
    private let asyncWrapper = AsyncWrapper()
    
    /// Indicates whether a notification is currently active.
    private(set) var notificationActive = false
    
    private var messages = [FlashMessageView]()

    ///  The currently queued array of FlashMessageView
    private var queuedMessages: [FlashMessageView] {
        return messages
    }
    private weak var _defaultViewController :UIViewController?
    
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
    func showNotification(inViewController viewController: UIViewController? = nil, title: String, duration: FlashMessageDuration = .Automatic, atPosition messagePosition: FlashMessageNotificationPosition = .Top, overrideStyle: FlashMessageView.Style? = nil, canBeDismissedByUser dismissingEnabled: Bool = true, callback: (() -> Void)? = nil) {
        
        if let messageTitle = messages.last?.title where title == messageTitle {
            return
        }
        let messageView  = FlashMessageView(
            viewController: viewController ?? defaultViewController,
            title: title,
            duration: duration,
            position: messagePosition,
            style: overrideStyle,
            dismissingEnabled: dismissingEnabled,
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
    
    func dismissActiveNotificationWithCompletion(completion: (() -> Void)?) -> Bool {
        guard !messages.isEmpty else {
            return false
        }
        dispatch_async(dispatch_get_main_queue(), {
            guard let currentMessage = self.messages.first else {
                return
            }
            if currentMessage.messageIsFullyDisplayed {
                self.fadeOutNotification(currentMessage, animationFinishedBlock: completion)
            } else {
                
                NSTimer.scheduledTimerWithTimeInterval(self.animationDuration + 0.1, target: NSBlockOperation(block: {
                    self.fadeOutNotification(currentMessage, animationFinishedBlock: completion)
                }), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
                
            }
        })
        return true
    }
    
    // MARK: Animation
    
    private func fadeInCurrentNotification() {
        messages = messages.flatMap {
            $0.viewController != nil ? $0 : nil
        }
        guard let flashMessageView = messages.first, viewController = flashMessageView.viewController else {
            return
        }
        
        notificationActive = true
        var verticalOffset: CGFloat = 0.0

        if let currentNavigationController = navigationControllerFrom(viewController) {
            if !isNavigationBarHiddenIn(currentNavigationController) && flashMessageView.messagePosition != .NavigationBarOverlay {
                viewController.view?.insertSubview(flashMessageView, belowSubview: currentNavigationController.navigationBar)
                verticalOffset = currentNavigationController.navigationBar.bounds.size.height
            } else {
                viewController.view?.addSubview(flashMessageView)
            }
            
            if checkIfViewIsUnderStatusBar(currentNavigationController) {
                verticalOffset += barHeightBasedOnMessagePositionIn(flashMessageView)
            }
        } else {
            viewController.view?.addSubview(flashMessageView)
            verticalOffset = CGRectGetHeight(flashMessageView.frame)
        }
        
        let endPoint = calculateEndPointForFadeInBasedOn(flashMessageView, andVerticaOffset: verticalOffset)
        customizeMessageView?(flashMessageView)
        animateView(flashMessageView, toPoint: endPoint)
        fadeOutNotificationWithDelay(flashMessageView)
    }
    
    private func calculateEndPointForFadeInBasedOn(flashMessageView: FlashMessageView, andVerticaOffset verticalOffset: CGFloat) -> CGPoint {
        if flashMessageView.messagePosition != .Bottom {
            let height = CGRectGetHeight(flashMessageView.frame) - minimalInset
            return CGPoint(x: flashMessageView.center.x, y: offsetHeightForMessage + verticalOffset + height / 2.0)
        } else {
            let height = flashMessageView.viewController?.view.bounds.size.height ?? 0.0
            var y = height - CGRectGetHeight(flashMessageView.frame) / 2.0
            if let navigationController = flashMessageView.viewController?.navigationController where !navigationController.toolbarHidden {
                y -= CGRectGetHeight(navigationController.toolbar.bounds)
            }
            return CGPoint(x: flashMessageView.center.x, y: y)
        }
    }
    
    private func animateView(view: FlashMessageView, toPoint: CGPoint) {
        UIView.animateWithDuration(self.animationDuration + 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [.CurveEaseInOut, .BeginFromCurrentState, .AllowUserInteraction], animations: {
                view.center = toPoint
            }, completion: { finished in
                view.messageIsFullyDisplayed = true
        })
    }
    
    private func barHeightBasedOnMessagePositionIn(currentView: FlashMessageView) -> CGFloat {
        guard currentView.messagePosition != .NavigationBarOverlay else {
            return 0.0
        }
        
        let statusBarSize = UIApplication.sharedApplication().statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }
    
    private func navigationControllerFrom(viewController: UIViewController) -> UINavigationController? {
        guard (viewController is UINavigationController) || (viewController.parentViewController is UINavigationController) else {
            return nil
        }
        return viewController as? UINavigationController ?? viewController.parentViewController as! UINavigationController
    }
    
    private func checkIfViewIsUnderStatusBar(navigationController: UINavigationController) -> Bool {
        var isViewIsUnderStatusBar = (navigationController.childViewControllers.first?.edgesForExtendedLayout == .All)
        if !isViewIsUnderStatusBar && navigationController.parentViewController == nil {
            isViewIsUnderStatusBar = !isNavigationBarHiddenIn(navigationController)
        }
        return isViewIsUnderStatusBar
    }
    
    private func isNavigationBarHiddenIn(navigationController: UINavigationController) -> Bool {
        return navigationController.navigationBarHidden || navigationController.navigationBar.hidden
    }
    
    private func fadeOutNotificationWithDelay(flashMessageView: FlashMessageView) {
        var durationToPresent: NSTimeInterval?
        switch(flashMessageView.duration) {
            case .Automatic:
                durationToPresent = animationDuration + displayTime + NSTimeInterval(flashMessageView.frame.size.height) * extraDisplayTimePerPixel
            case .Custom(let timeInterval):
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
    
    @objc private func fadeOutNotification(flashMessageView: FlashMessageView) {
        fadeOutNotification(flashMessageView, animationFinishedBlock: nil)
    }
    
    @objc private func fadeOutNotification(flashMessageView: FlashMessageView, animationFinishedBlock animationFinished: (() -> Void)?) {
        guard let viewController = flashMessageView.viewController else {
            if self.messages.count > 0 {
                self.messages.removeAtIndex(0)
            }
            notificationActive = false
            return
        }
        
        flashMessageView.messageIsFullyDisplayed = false
        NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(fadeOutNotification(_:)), object: flashMessageView)
        var fadeOutToPoint: CGPoint
        if flashMessageView.messagePosition != .Bottom {
            fadeOutToPoint = CGPointMake(flashMessageView.center.x, -CGRectGetHeight(flashMessageView.frame) / 2.0)
        } else {
            fadeOutToPoint = CGPointMake(flashMessageView.center.x, viewController.view.bounds.size.height + CGRectGetHeight(flashMessageView.frame) / 2.0)
        }
        UIView.animateWithDuration(animationDuration, animations: {
                flashMessageView.center = fadeOutToPoint
            }, completion: { finished in
                flashMessageView.removeFromSuperview()
                if self.messages.count > 0 {
                    self.messages.removeAtIndex(0)
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
