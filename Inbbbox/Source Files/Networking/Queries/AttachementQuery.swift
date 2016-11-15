//
//  AttachementQuery.swift
//  Inbbbox
//
//  Created by Marcin Siemaszko on 15.11.2016.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct AttachementQuery: Query {
    
    let method = Method.GET
    var parameters = Parameters(encoding: .URL)
    private(set) var path: String
    
    /// Initialize query for list of the given shots attachements.
    ///
    /// - parameter shot: Shot which attachements should be listed.
    init(shot: ShotType) {
        path = "/shots/\(shot.identifier)/attachments"
    }
}
