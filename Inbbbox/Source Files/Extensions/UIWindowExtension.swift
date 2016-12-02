//
//  UIWindowExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 17.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIWindow {

    /// Set root view controller
    /// Fix for http://stackoverflow.com/a/27153956/849645
    /// Solution from http://stackoverflow.com/a/27153956/1671168
    ///
    /// - parameter newRootViewController:  new root view controller
    /// - parameter transition:             optional transition animation
    func setRootViewController(_ newRootViewController: UIViewController,
                                          transition: CATransition? = nil) {

        let previousViewController = rootViewController

        if let transition = transition {
            // Add the transition
            layer.add(transition, forKey: kCATransition)
        }

        rootViewController = newRootViewController

        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }) 
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }

        /// The presenting view controllers view doesn't get removed from the window
        /// as its currently transistioning and presenting a view controller
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}
