//
//  UIViewControllerExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UIViewController {

    /// Loads view with type of UIView
    ///
    /// - parameter viewType: Type of UIView to be loaded.
    ///
    /// - returns: View based on given class.
    func loadViewWithClass<T: UIView>(viewType: T.Type) -> T {

        view = T(frame: UIScreen.mainScreen().bounds)
        view.autoresizingMask = [.FlexibleRightMargin, .FlexibleLeftMargin,
                                 .FlexibleBottomMargin, .FlexibleTopMargin]
        return (view as? T)!
    }
}

extension UIViewController {
    func registerTo3DTouch(view: UIView) -> Bool {
        if traitCollection.forceTouchCapability == .Available {
            if let previewingSelf = self as? UIViewControllerPreviewingDelegate {
                registerForPreviewingWithDelegate(previewingSelf, sourceView: view)
                return true
            }
        }
        return false
    }
}
