//
// Copyright (c) 2016 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import Dobby

@testable import Inbbbox

class PanGestureRecognizerMock: UIPanGestureRecognizer {

    let velocityInViewStub = Stub<UIView?, CGPoint>()
    let translationInViewStub = Stub<UIView?, CGPoint>()
    let stateStub = Stub<Void, UIGestureRecognizerState>()


    override func velocity(in view: UIView?) -> CGPoint {
        return try! velocityInViewStub.invoke(view)
    }

    override func translation(in view: UIView?) -> CGPoint {
        return try! translationInViewStub.invoke(view)
    }

    override var state: UIGestureRecognizerState {
        get {
            return try! stateStub.invoke()
        }
        set {
            
        }
    }
}
