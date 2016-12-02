//
//  MFMailComposeViewControllerExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 20.04.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import MessageUI

extension MFMailComposeViewController {
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return nil
    }
}
