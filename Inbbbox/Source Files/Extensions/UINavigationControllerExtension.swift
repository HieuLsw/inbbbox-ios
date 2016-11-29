//
//  UINavigationControllerExtension.swift
//  Inbbbox
//
//  Created by Patryk Kaczmarek on 18/12/15.
//  Copyright © 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

extension UINavigationController {

    /// Progress view embeding in navigation bar
    ///
    /// - returns: instance of UIProgressView
    func progressViewByEmbedingInNavigationBar() -> UIProgressView {

        let progressView = UIProgressView(progressViewStyle: .bar)
        navigationBar.addSubview(progressView)

        let bottomConstraint = NSLayoutConstraint(item: navigationBar,
                                             attribute: .bottom,
                                             relatedBy: .equal,
                                                toItem: progressView,
                                             attribute: .bottom,
                                            multiplier: 1,
                                              constant: 1)

        let leftConstraint = NSLayoutConstraint(item: navigationBar,
                                           attribute: .leading,
                                           relatedBy: .equal,
                                              toItem: progressView,
                                           attribute: .leading,
                                          multiplier: 1,
                                            constant: 0)

        let rightConstraint = NSLayoutConstraint(item: navigationBar,
                                            attribute: .trailing,
                                            relatedBy: .equal,
                                               toItem: progressView,
                                            attribute: .trailing,
                                           multiplier: 1,
                                             constant: 0)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([bottomConstraint, leftConstraint, rightConstraint])

        return progressView
    }
}
