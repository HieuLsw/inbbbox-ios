//
//  AlertViewController.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 19.10.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

/// This class adds convenient way to show alert controller
/// Also deals with a problem where UIActionItem handler was 
/// not called because UIWindows problems
public final class AlertViewController: UIAlertController {
    private var alertWindow: UIWindow? = UIWindow()
    private var rootViewController: UIViewController? = UIViewController()
    
    func show(animated:Bool = true) {
        guard let alertWindow = alertWindow, rootViewController = rootViewController else {
            return
        }
        alertWindow.backgroundColor = .clearColor()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        rootViewController.view.backgroundColor = .clearColor()
        alertWindow.rootViewController = rootViewController
        alertWindow.makeKeyAndVisible()
        rootViewController.presentViewController(self, animated: animated, completion: nil)
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        alertWindow?.hidden = true
        alertWindow = nil
        rootViewController = nil
    }

}
