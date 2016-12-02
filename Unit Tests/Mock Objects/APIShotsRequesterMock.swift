//
//  APIShotsRequesterMock.swift
//  Inbbbox
//
//  Created by Peter Bruz on 29/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Dobby
import PromiseKit

@testable import Inbbbox

class APIShotsRequesterMock: APIShotsRequester {
    
    let userBucketsForShotStub = Stub<ShotType, Promise<[BucketType]?>>()
    
    override func userBucketsForShot(_ shot: ShotType) -> Promise<[BucketType]?> {
        return try! userBucketsForShotStub.invoke(shot)
    }
}
