//
//  URLSessionConfigurationExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 08.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Overlog

extension URLSessionConfiguration {

    class func inbbboxDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        Overlog.shared.enableNetworkDebugging(inConfiguration: configuration)
        return configuration
    }
}
