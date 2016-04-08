//
// Created by Lukasz Pikor on 31.03.2016.
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import HockeySDK

/// CrashManger class is used to handle integration with HockeyApp SDK.
final class CrashManager {

    class func setup() {
        guard let identifier = Dribbble.HockeySDKIdentifier else {
            return
        }

        BITHockeyManager.sharedHockeyManager().configureWithIdentifier(identifier)
        BITHockeyManager.sharedHockeyManager().crashManager.crashManagerStatus = .AutoSend
        BITHockeyManager.sharedHockeyManager().startManager()
    }
}
