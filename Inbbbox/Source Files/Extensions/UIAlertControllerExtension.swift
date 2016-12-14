//
//  UIAlertControllerExtension.swift
//  Inbbbox
//
//  Created by Peter Bruz on 09/03/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import AOAlertController

extension UIAlertController {

    // MARK: Shared Settings

    class func setupSharedSettings() {
        AOAlertSettings.sharedSettings.backgroundColor = .backgroundGrayColor()
        AOAlertSettings.sharedSettings.linesColor = .backgroundGrayColor()
        AOAlertSettings.sharedSettings.defaultActionColor = .pinkColor()
        AOAlertSettings.sharedSettings.cancelActionColor = .pinkColor()

        AOAlertSettings.sharedSettings.messageFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        AOAlertSettings.sharedSettings.defaultActionFont = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        AOAlertSettings.sharedSettings.cancelActionFont = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)
        AOAlertSettings.sharedSettings.destructiveActionFont = UIFont.systemFont(ofSize: 16, weight: UIFontWeightRegular)

    }

    // MARK: Buckets

    class func provideBucketName(_ createHandler: @escaping (_ bucketName: String) -> Void)
                    -> AlertViewController {
        let alertTitle = NSLocalizedString("UIAlertControllerExtension.NewBucket",
                                  comment: "Allows user to create new bucket.")
        let alertMessage = NSLocalizedString("UIAlertControllerExtension.ProvideName",
                                    comment: "Provide name for new bucket")
        let alert = AlertViewController(title: alertTitle,
                                    message: alertMessage,
                             preferredStyle: .alert)

        let cancelActionTitle = NSLocalizedString("UIAlertControllerExtension.Cancel",
                                         comment: "Cancel creating new bucket.")
        alert.addAction(UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil))

        let createActionTitle = NSLocalizedString("UIAlertControllerExtension.Create",
                                         comment: "Create new bucket.")
        alert.addAction(UIAlertAction(title: createActionTitle, style: .default) { _ in
            if let bucketName = alert.textFields?[0].text {
                createHandler(bucketName)
            }
        })
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = NSLocalizedString("UIAlertControllerExtension.BucketName",
                                             comment: "Asks user to enter bucket name.")
        })

        return alert
    }

    // MARK: Other

    class func inappropriateContentReported() -> AOAlertController {
        let message = NSLocalizedString("UIAlertControllerExtension.InappropriateContentReported", comment: "nil")

        let okActionTitle = NSLocalizedString("UIAlertControllerExtension.OK", comment: "OK")
        let okAction = AOAlertAction(title: okActionTitle, style: .default, handler: nil)

        return UIAlertController.createAlert(message, action: okAction)
    }

    class func emailAccountNotFound() -> AOAlertController {
        let message = NSLocalizedString("UIAlertControllerExtension.EmailError",
                comment: "Displayed when user device is not capable of/configured to send emails.")

        return UIAlertController.createAlert(message)
    }

    class func willSignOutUser() -> AOAlertController {
        let message = NSLocalizedString("ShotsCollectionViewController.SignOut",
                comment: "Message informing user will be logged out because of an error.")
        let alert = AOAlertController(title: nil, message: message, style: .alert)

        let dismissActionTitle = NSLocalizedString("ShotsCollectionViewController.Dismiss",
                comment: "Dismiss error alert.")
        let dismissAction = AOAlertAction(title: dismissActionTitle, style: .default) { _ in
            Authenticator.logout()
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.rollbackToLoginViewController()
            }
        }
        alert.addAction(dismissAction)

        return alert
    }
    
    class func cantSendFeedback() -> AOAlertController {
        let message = NSLocalizedString("UIAlertControllerExtension.CantSendFeedback",
                                        comment: "Displayed when user device is not capable of/configured to send emails, shown when trying to send feedback.")
        
        return UIAlertController.createAlert(message)
    }

    // MARK: Private

    fileprivate class func defaultDismissAction(_ style: AOAlertActionStyle = .default) -> AOAlertAction {
        let title = NSLocalizedString("UIAlertControllerExtension.Dismiss", comment: "Dismiss")

        return AOAlertAction(title: title, style: style, handler: nil)
    }

    fileprivate class func createAlert(_ message: String,
                                   action: AOAlertAction = UIAlertController.defaultDismissAction(),
                                   style: AOAlertControllerStyle = .alert) -> AOAlertController {
        let alert = AOAlertController(title: nil, message: message, style: style)
        alert.addAction(action)

        return alert
    }
}
