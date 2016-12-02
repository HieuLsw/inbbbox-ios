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
    fileprivate var alertWindow: UIWindow? = UIWindow()
    fileprivate var rootViewController: UIViewController? = UIViewController()
    
    func show(_ animated:Bool = true) {
        guard let alertWindow = alertWindow, let rootViewController = rootViewController else {
            return
        }
        alertWindow.backgroundColor = .clear
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        rootViewController.view.backgroundColor = .clear
        alertWindow.rootViewController = rootViewController
        alertWindow.makeKeyAndVisible()
        rootViewController.present(self, animated: animated, completion: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alertWindow?.isHidden = true
        alertWindow = nil
        rootViewController = nil
    }

}
