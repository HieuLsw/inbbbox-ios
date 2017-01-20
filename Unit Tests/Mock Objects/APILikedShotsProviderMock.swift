//
//  APILikedShotsProviderMock.swift
//  Inbbbox
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import Foundation
import Dobby
import PromiseKit

@testable import Inbbbox

class APILikedShotsProviderMock: APILikedShotsProvider {

    let provideLikedShotsStub = Stub<Void, Promise<[LikedShot]?>>()

    override func provideLikedShots() -> Promise<[LikedShot]?> {
        return try! provideLikedShotsStub.invoke()
    }
}
