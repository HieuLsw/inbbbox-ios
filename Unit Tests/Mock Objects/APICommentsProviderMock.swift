//
//  CommentsProviderMock.swift
//  Inbbbox
//
//  Created by Peter Bruz on 22/02/16.
//  Copyright © 2016 Netguru Sp. z o.o. All rights reserved.
//

import Dobby
import PromiseKit

@testable import Inbbbox

class APICommentsProviderMock: APICommentsProvider {
    
    let provideCommentsForShotStub = Stub<ShotType, Promise<[CommentType]?>>()
    let nextPageStub = Stub<Void, Promise<[CommentType]?>>()

    override func provideCommentsForShot(_ shot: ShotType) -> Promise<[CommentType]?> {
        return try! provideCommentsForShotStub.invoke(shot)
    }
    
    override func nextPage() -> Promise<[CommentType]?> {
        return try! nextPageStub.invoke()
    }
}
