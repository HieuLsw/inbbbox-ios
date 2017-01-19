//
//  ManagedShotsProviderMock.swift
//  Inbbbox
//
//  Created by Lukasz Wolanczyk on 3/1/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Dobby
import PromiseKit

@testable import Inbbbox

class ManagedShotsProviderMock: ManagedShotsProvider {

    let provideMyLikedShotsStub = Stub<Void, Promise<[ShotType]?>>()
    let provideLikedShotsStub = Stub<Void, Promise<[LikedShot]?>>()

    override func provideMyLikedShots() -> Promise<[ShotType]?> {
        return try! provideMyLikedShotsStub.invoke()
    }

    override func provideManagedLikedShots() -> Promise<[LikedShot]?> {
        return try! provideLikedShotsStub.invoke()
    }
}
