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
    func loadViewWithClass<T: UIView>(_ viewType: T.Type) -> T {

        view = T(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin,
                                 .flexibleBottomMargin, .flexibleTopMargin]
        return (view as? T)!
    }
}

extension UIViewController {
    
    /// Registers a given view as a source for receiving 3D Touch events. There can be
    /// multiple views registered inside one view controllers but one view cannot be 
    /// registered multiple times.
    ///
    /// - parameter view: UIView to be registered as a source
    ///
    /// - returns: Boolean value which describes if a registration succeeded
    func registerTo3DTouch(_ view: UIView) -> Bool {
        if traitCollection.forceTouchCapability == .available {
            if let previewingSelf = self as? UIViewControllerPreviewingDelegate {
                registerForPreviewing(with: previewingSelf, sourceView: view)
                return true
            }
        }
        return false
    }
    
}
