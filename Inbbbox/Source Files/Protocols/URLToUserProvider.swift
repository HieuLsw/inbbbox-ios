//
//  URLToUserProvider.swift
//  Inbbbox
//
//  Created by Aleksander Popko on 31.03.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

/// Provide user object from URL represantation of user.
/// Helps with using TTTAttributedLabel in the project.

protocol URLToUserProvider {

    /**
     Provide user object from URL represantation of user.

     - parameter url: url represantation of user

     - returns: user provided from URL
     */

    func userForURL(_ url: URL) -> UserType?

}
