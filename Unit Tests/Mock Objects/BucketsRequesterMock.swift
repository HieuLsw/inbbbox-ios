//
//  BucketsRequesterMock.swift
//  Inbbbox
//
//  Created by Peter Bruz on 28/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Dobby
import PromiseKit

@testable import Inbbbox

class BucketsRequesterMock: BucketsRequester {
    
    let postBucketStub = Stub<(String, NSAttributedString?), Promise<BucketType>>()
    let addShotStub = Stub<(ShotType, BucketType), Promise<Void>>()
    let removeShotStub = Stub<(ShotType, BucketType), Promise<Void>>()
    
    override func postBucket(_ name: String, description: NSAttributedString?) -> Promise<BucketType> {
        return try! postBucketStub.invoke(name, description)
    }
    
    override func addShot(_ shot: ShotType, toBucket bucket: BucketType) -> Promise<Void> {
        return try! addShotStub.invoke(shot, bucket)
    }
    
    override func removeShot(_ shot: ShotType, fromBucket bucket: BucketType) -> Promise<Void> {
        return try! removeShotStub.invoke(shot, bucket)
    }
}
