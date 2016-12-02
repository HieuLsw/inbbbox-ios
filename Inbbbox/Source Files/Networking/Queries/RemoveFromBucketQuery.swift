//
//  RemoveFromBucketQuery.swift
//  Inbbbox
//
//  Created by Peter Bruz on 08/01/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Foundation

struct RemoveFromBucketQuery: Query {

    let method = Method.DELETE
    let path: String
    var parameters = Parameters(encoding: .json)

    /// Initialize query for removing shot from bucket.
    ///
    /// - parameter shot:   Shot that should be removed.
    /// - parameter bucket: Bucket that shot should be removed from.
    init(shot: ShotType, bucket: BucketType) {
        path = "/buckets/" + bucket.identifier.stringValue + "/shots"
        parameters["shot_id"] = shot.identifier as AnyObject?
    }
}
