//
// Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Dobby

@testable import Inbbbox

class ShotsAnimatorMock: ShotsAnimator {

    let startAnimationWithCompletionStub = Stub<(() -> Void)?, Void>()

    override func startAnimationWithCompletion(_ completion: (() -> Void)?) {
        try! startAnimationWithCompletionStub.invoke(completion)
    }
}
