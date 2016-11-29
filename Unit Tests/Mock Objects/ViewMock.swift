//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import Dobby

@testable import Inbbbox

class ViewMock: UIView {

    static let animationStub = Stub<(TimeInterval, TimeInterval, UIViewAnimationOptions, () -> Void, ((Bool) -> Void)?), Void>()
    static let springAnimationStub = Stub<(TimeInterval, TimeInterval, CGFloat, CGFloat, UIViewAnimationOptions, () -> Void, ((Bool) -> Void)?), Void>()

    override class func animate(withDuration duration: TimeInterval, delay: TimeInterval, options: UIViewAnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        try! animationStub.invoke(duration, delay, options, animations, completion)
    }

    override class func animate(withDuration duration: TimeInterval, delay: TimeInterval, usingSpringWithDamping dampingRatio: CGFloat, initialSpringVelocity velocity: CGFloat, options: UIViewAnimationOptions, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        try! springAnimationStub.invoke(duration, delay, dampingRatio, velocity, options, animations, completion)
    }
}
