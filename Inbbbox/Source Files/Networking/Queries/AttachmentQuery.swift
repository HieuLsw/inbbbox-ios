//
//  AttachmentQuery.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct AttachmentQuery: Query {
    
    let method = Method.GET
    var parameters = Parameters(encoding: .url)
    fileprivate(set) var path: String
    
    /// Initialize query for list of the given shots attachments.
    ///
    /// - parameter shot: Shot which attachments should be listed.
    init(shot: ShotType) {
        path = "/shots/\(shot.identifier)/attachments"
    }
}
