//
//  URLSessionExtension.swift
//  Inbbbox
//
//  Created by Lukasz Pikor on 08.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

extension URLSession {

    class func inbbboxDefaultSession() -> URLSession {
        return URLSession(configuration: URLSessionConfiguration.inbbboxDefaultSessionConfiguration())
    }
}
