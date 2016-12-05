//
//  NSURLSessionConfigurationExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 08.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

extension NSURLSessionConfiguration {

    class func inbbboxDefaultSessionConfiguration() -> NSURLSessionConfiguration {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.requestCachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        return configuration
    }
}
