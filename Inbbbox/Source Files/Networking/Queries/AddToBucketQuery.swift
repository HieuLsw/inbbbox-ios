//
//  AddToBucketQuery.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct AddToBucketQuery: Query {

    let method = Method.PUT
    let path: String
    var parameters = Parameters(encoding: .json)

    /// Initialize query for adding shot to bucket.
    ///
    /// - parameter shot:   Shot that should be added.
    /// - parameter bucket: Bucket which shot should be added to.
    init(shot: ShotType, bucket: BucketType) {
        path = "/buckets/" + bucket.identifier.stringValue + "/shots"
        parameters["shot_id"] = shot.identifier as AnyObject?
    }
}
